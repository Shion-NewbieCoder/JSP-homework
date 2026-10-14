-- FLASHMART: Bai thuc hanh JOIN (file khung de hoc vien hoan thien)
-- MySQL 8.x. Chay LAN DAU tren database flashmart_db chua co 3 bang nay.
-- Khong chay lai cac INSERT neu du lieu mau da ton tai.

CREATE DATABASE IF NOT EXISTS flashmart_db;
USE flashmart_db;

-- Du lieu de kiem chung ca nhung ban ghi khong co giao dich
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT
);

INSERT INTO Customers (customer_id, name) VALUES
    (1, 'Alice'),
    (2, 'Bob'),
    (3, 'Charlie');

INSERT INTO Products (product_id, product_name) VALUES
    (101, 'Laptop'),
    (102, 'Mouse'),
    (103, 'Keyboard');

INSERT INTO Orders (order_id, customer_id, product_id) VALUES
    (1001, 1, 101),
    (1002, 1, 102),
    (1003, 2, 101);

-- ======================================================
-- BAO CAO 1 - MARKETING
-- Yeu cau: tat ca khach hang, ke ca khach hang khong co don
-- TODO-1: Thay __LOAI_JOIN__ bang loai JOIN giu lai Customers.
-- TODO-2: Thay __BIEN_DEM__ bang cot cua Orders (KHONG dung *).
-- Ket qua dung: Alice 2, Bob 1, Charlie 0; 3 dong.
-- ======================================================
SELECT c.customer_id, c.name,
       COUNT(__BIEN_DEM__) AS total_orders
FROM Customers AS c
__LOAI_JOIN__ Orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY c.customer_id;

-- ======================================================
-- BAO CAO 2 - KHO VAN
-- Yeu cau: chi san pham chua tung duoc ban
-- TODO-3: Thay __LOAI_JOIN__ bang loai JOIN giu lai Products.
-- TODO-4: Thay __COT_DON_HANG__ bang cot khong NULL cua Orders
--         khi co giao dich, de loc cac dong khong match.
-- Ket qua dung: product_id=103, product_name=Keyboard; 1 dong.
-- ======================================================
SELECT p.product_id, p.product_name
FROM Products AS p
__LOAI_JOIN__ Orders AS o ON p.product_id = o.product_id
WHERE __COT_DON_HANG__ IS NULL
ORDER BY p.product_id;
