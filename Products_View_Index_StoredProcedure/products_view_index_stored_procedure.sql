-- CODEGYM - THUC HANH TONG HOP: VIEW, INDEX, STORED PROCEDURE
-- He QTCSDL: MySQL 8.0+ | CSDL demo: demo
-- Chay toan bo trong MySQL Workbench; khong can classicmodels.
-- Script khong DROP bang hay xoa du lieu mau da co.

-- ================================================================
-- BUOC 1-2: TAO CSDL, TAO BANG PRODUCTS, THEM DU LIEU MAU
-- ================================================================
CREATE DATABASE IF NOT EXISTS demo
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE demo;

CREATE TABLE IF NOT EXISTS Products (
    Id INT NOT NULL AUTO_INCREMENT,
    productCode VARCHAR(20) NOT NULL,
    productName VARCHAR(100) NOT NULL,
    productPrice DECIMAL(12, 2) NOT NULL,
    productAmount INT NOT NULL DEFAULT 0,
    productDescription TEXT,
    productStatus TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (Id),
    CONSTRAINT chk_products_price CHECK (productPrice >= 0),
    CONSTRAINT chk_products_amount CHECK (productAmount >= 0)
) ENGINE=InnoDB;

-- Chi chen dong mau neu chua co ma san pham; co the chay lai.
-- INSERT ... SELECT voi LEFT JOIN cho phep doc cung bang ma khong
-- dung subquery tham chieu Products ngay trong WHERE.
INSERT INTO Products (productCode, productName, productPrice,
                      productAmount, productDescription, productStatus)
SELECT s.productCode, s.productName, s.productPrice,
       s.productAmount, s.productDescription, s.productStatus
FROM (
    SELECT 'SP001' AS productCode, 'Ban phim co' AS productName,
           850000 AS productPrice, 25 AS productAmount,
           'Ban phim co cho may tinh' AS productDescription, 1 AS productStatus
    UNION ALL SELECT 'SP002', 'Chuot khong day', 350000, 40,
                     'Chuot ket noi Bluetooth', 1
    UNION ALL SELECT 'SP003', 'Man hinh', 3200000, 12,
                     'Man hinh 24 inch', 1
    UNION ALL SELECT 'SP004', 'Tai nghe', 650000, 30,
                     'Tai nghe co day', 1
    UNION ALL SELECT 'SP005', 'Ban phim co', 1250000, 15,
                     'Ban phim co cao cap', 1
    UNION ALL SELECT 'SP006', 'Webcam', 990000, 18,
                     'Webcam Full HD', 1
    UNION ALL SELECT 'SP007', 'Loa Bluetooth', 740000, 22,
                     'Loa di dong', 1
    UNION ALL SELECT 'SP008', 'Chuot khong day', 590000, 20,
                     'Chuot cong thai hoc', 0
) AS s
LEFT JOIN Products AS existing ON existing.productCode = s.productCode
WHERE existing.Id IS NULL;

SELECT * FROM Products ORDER BY Id;

-- ================================================================
-- BUOC 3: EXPLAIN TRUOC INDEX; TAO UNIQUE / COMPOSITE INDEX;
--         EXPLAIN SAU INDEX
-- ================================================================
-- Lan chay DAU TIEN: truoc khi co hai index moi.
SELECT 'EXPLAIN TRUOC - tim theo productCode' AS giai_doan;
EXPLAIN
SELECT * FROM Products WHERE productCode = 'SP001';

SELECT 'EXPLAIN TRUOC - tim theo productName va productPrice' AS giai_doan;
EXPLAIN
SELECT * FROM Products
WHERE productName = 'Ban phim co' AND productPrice >= 800000;

-- MySQL khong ho tro cu phap CREATE INDEX IF NOT EXISTS.
-- Kiem tra information_schema va chi tao index neu chua co.
SELECT COUNT(*) INTO @has_unique_code
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'Products'
  AND INDEX_NAME = 'idx_products_code';

SET @ddl_unique := IF(
    @has_unique_code = 0,
    'CREATE UNIQUE INDEX idx_products_code ON Products (productCode)',
    'SELECT ''idx_products_code already exists'' AS index_notice'
);
PREPARE stmt_unique FROM @ddl_unique;
EXECUTE stmt_unique;
DEALLOCATE PREPARE stmt_unique;

SELECT COUNT(*) INTO @has_name_price
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'Products'
  AND INDEX_NAME = 'idx_products_name_price';

SET @ddl_composite := IF(
    @has_name_price = 0,
    'CREATE INDEX idx_products_name_price ON Products (productName, productPrice)',
    'SELECT ''idx_products_name_price already exists'' AS index_notice'
);
PREPARE stmt_composite FROM @ddl_composite;
EXECUTE stmt_composite;
DEALLOCATE PREPARE stmt_composite;

SHOW INDEX FROM Products;

SELECT 'EXPLAIN SAU - tim theo productCode' AS giai_doan;
EXPLAIN
SELECT * FROM Products WHERE productCode = 'SP001';

SELECT 'EXPLAIN SAU - tim theo productName va productPrice' AS giai_doan;
EXPLAIN
SELECT * FROM Products
WHERE productName = 'Ban phim co' AND productPrice >= 800000;

-- Co it du lieu, Optimizer co the van chon ALL. Minh hoa dung index:
EXPLAIN
SELECT * FROM Products FORCE INDEX (idx_products_name_price)
WHERE productName = 'Ban phim co' AND productPrice >= 800000;
-- FORCE INDEX chi de minh hoa; KHONG khang dinh nhanh hon.

-- ================================================================
-- BUOC 4: TAO VIEW, SUA VIEW, XOA VIEW
-- ================================================================
CREATE OR REPLACE VIEW product_view AS
SELECT productCode, productName, productPrice, productStatus
FROM Products;

SELECT * FROM product_view ORDER BY productCode;

-- Sua view: bo sung productAmount va chi hien thi san pham dang ban.
CREATE OR REPLACE VIEW product_view AS
SELECT productCode, productName, productPrice,
       productAmount, productStatus
FROM Products
WHERE productStatus = 1;

SELECT * FROM product_view ORDER BY productCode;

DROP VIEW IF EXISTS product_view;
-- View duoc xoa theo yeu cau; bang Products KHONG bi xoa.

-- ================================================================
-- BUOC 5: STORED PROCEDURE - XEM, THEM, SUA, XOA SAN PHAM (CRUD)
-- ================================================================
DROP PROCEDURE IF EXISTS getAllProducts;
DROP PROCEDURE IF EXISTS addProduct;
DROP PROCEDURE IF EXISTS updateProduct;
DROP PROCEDURE IF EXISTS deleteProduct;

DELIMITER //
CREATE PROCEDURE getAllProducts()
BEGIN
    SELECT * FROM Products ORDER BY Id;
END //

CREATE PROCEDURE addProduct(
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(12, 2),
    IN p_amount INT,
    IN p_description TEXT,
    IN p_status TINYINT
)
BEGIN
    INSERT INTO Products (productCode, productName, productPrice,
                          productAmount, productDescription, productStatus)
    VALUES (p_code, p_name, p_price, p_amount, p_description, p_status);
END //

CREATE PROCEDURE updateProduct(
    IN p_id INT,
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(12, 2),
    IN p_amount INT,
    IN p_description TEXT,
    IN p_status TINYINT
)
BEGIN
    UPDATE Products
    SET productCode = p_code,
        productName = p_name,
        productPrice = p_price,
        productAmount = p_amount,
        productDescription = p_description,
        productStatus = p_status
    WHERE Id = p_id;
END //

CREATE PROCEDURE deleteProduct(IN p_id INT)
BEGIN
    DELETE FROM Products WHERE Id = p_id;
END //
DELIMITER ;

-- KIEM THU CRUD: dung mot san pham TAM va XOA SAU KHI TEST.
CALL getAllProducts();

CALL addProduct('TEST999', 'San pham thu nghiem', 100000, 5,
                'Demo INSERT bang procedure', 1);
SET @test_product_id = LAST_INSERT_ID();

SELECT * FROM Products WHERE Id = @test_product_id;

CALL updateProduct(@test_product_id, 'TEST999', 'San pham da cap nhat',
                   120000, 9, 'Demo UPDATE bang procedure', 1);
SELECT * FROM Products WHERE Id = @test_product_id;

CALL deleteProduct(@test_product_id);
SELECT COUNT(*) AS so_san_pham_test_con_lai
FROM Products WHERE Id = @test_product_id;
-- Ket qua mong doi: so_san_pham_test_con_lai = 0.

-- Kiem tra cac thu tuc va so du lieu mau sau khi test.
SHOW PROCEDURE STATUS WHERE Db = 'demo';
SELECT COUNT(*) AS total_products FROM Products;
-- Neu ban dau bang trong: total_products = 8.
