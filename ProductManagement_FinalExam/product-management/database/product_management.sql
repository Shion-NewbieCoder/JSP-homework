-- CodeGym Final Exam: run in MySQL Workbench or the MySQL CLI.
-- Uses InnoDB, utf8mb4 and DECIMAL for precise prices.
CREATE DATABASE IF NOT EXISTS product_management
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE product_management;

CREATE TABLE IF NOT EXISTS products (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT chk_price_non_negative CHECK (price >= 0),
    CONSTRAINT chk_quantity_non_negative CHECK (quantity >= 0)
) ENGINE=InnoDB;

-- Add demo records only if the table is currently empty (safe to run again).
INSERT INTO products (name, price, quantity)
SELECT seed.name, seed.price, seed.quantity
FROM (
    SELECT 'Bàn phím cơ Keychron K2' AS name, 1590000.00 AS price, 18 AS quantity
    UNION ALL SELECT 'Chuột Logitech M650', 649000.00, 32
    UNION ALL SELECT 'Tai nghe Sony WH-CH520', 1190000.00, 12
    UNION ALL SELECT 'USB Kingston 64GB', 165000.00, 56
    UNION ALL SELECT 'Màn hình Dell 24 inch', 3290000.00, 8
    UNION ALL SELECT 'Laptop Asus Vivobook', 14990000.00, 5
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM products LIMIT 1);

-- Verify:
SELECT id, name, price, quantity FROM products ORDER BY id DESC;
