-- BAI THUC HANH: SU DUNG CHI MUC (INDEX) TRONG MYSQL
-- CSDL mau: classicmodels (MySQLTutorial.org)
-- Chay mot lan sau khi da import mysqlsampledatabase.sql.
-- Script KHONG tao lai hoac xoa du lieu customers.

USE classicmodels;

-- 0. Kiem tra so luong khach hang va chi muc ban dau.
SELECT COUNT(*) AS total_customers FROM customers;
SHOW INDEX FROM customers;

-- 1. Truy van tim khach hang va EXPLAIN TRUOC khi tao index.
SELECT *
FROM customers
WHERE customerName = 'Land of Toys Inc.';

EXPLAIN
SELECT *
FROM customers
WHERE customerName = 'Land of Toys Inc.';

-- 2. Tao chi muc B-Tree cho cot customerName.
ALTER TABLE customers
    ADD INDEX idx_customerName (customerName);

ANALYZE TABLE customers;
SHOW INDEX FROM customers;

-- EXPLAIN SAU khi tao index: xem type, possible_keys, key, rows, Extra.
EXPLAIN
SELECT *
FROM customers
WHERE customerName = 'Land of Toys Inc.';

-- Minh hoa truy cap thong qua index khi bang mau qua nho va
-- Optimizer tu chon ALL; FORCE INDEX chi de hoc, khong mac dinh nhanh hon.
EXPLAIN
SELECT *
FROM customers FORCE INDEX (idx_customerName)
WHERE customerName = 'Land of Toys Inc.';

-- 3. Tao composite index cho ho + ten lien he.
ALTER TABLE customers
    ADD INDEX idx_full_name (contactFirstName, contactLastName);

-- Dieu kien loc theo cot DAU tien cua composite index.
EXPLAIN
SELECT *
FROM customers
WHERE contactFirstName = 'Jean'
   OR contactFirstName = 'King';

-- Cung y nghia voi IN; chi muc co the duoc su dung.
SELECT customerNumber, customerName, contactFirstName, contactLastName
FROM customers
WHERE contactFirstName IN ('Jean', 'King');

-- 4. Thuc hanh xoa composite index, giu lai index customerName.
ALTER TABLE customers
    DROP INDEX idx_full_name;

-- Xac minh: idx_customerName con; idx_full_name da duoc xoa.
SHOW INDEX FROM customers;

-- Chu y: Khong chay lai toan bo script lan thu hai vi idx_customerName
-- da ton tai. Muon chay lai tu dau, thuc thi rieng:
-- ALTER TABLE customers DROP INDEX idx_customerName;
-- Sau do chay lai script. KHONG can xoa / import lai CSDL.
