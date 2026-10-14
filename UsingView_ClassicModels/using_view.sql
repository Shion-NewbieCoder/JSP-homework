-- BAI THUC HANH: TAO, CAP NHAT VA XOA VIEW TRONG MYSQL
-- Du lieu: classicmodels, bang customers
-- Chu y: Khong tao lai database va khong sua du lieu goc.
-- Co the chay lai file nhieu lan.

USE classicmodels;

-- 1. Xoa view cu (neu co) de lan chay sau khong bi trung ten.
DROP VIEW IF EXISTS customer_views;

-- 2. Tao view chi lay 3 truong thong tin khach hang.
CREATE VIEW customer_views AS
SELECT customerNumber, customerName, phone
FROM customers;

-- 3. Doc du lieu tu view vua tao.
SELECT *
FROM customer_views;

-- 4. Cap nhat dinh nghia view: them ho va ten nguoi lien he,
--    va chi lay khach hang co city = 'Nantes'.
--    CREATE OR REPLACE VIEW thay dinh nghia, khong sua du lieu customers.
CREATE OR REPLACE VIEW customer_views AS
SELECT customerNumber, customerName,
       contactFirstName, contactLastName, phone
FROM customers
WHERE city = 'Nantes';

-- 5. Doc lai du lieu tu view sau khi cap nhat.
SELECT *
FROM customer_views;

-- 6. Xoa view theo yeu cau bai tap.
DROP VIEW customer_views;

-- 7. Kiem tra view da bi xoa: ket qua du kien 0.
SELECT COUNT(*) AS so_view_con_lai
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'classicmodels'
  AND TABLE_NAME = 'customer_views';
