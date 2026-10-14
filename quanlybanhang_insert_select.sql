-- BAI THUC HANH: INSERT VA SELECT - QUAN LY BAN HANG
-- Dua tren schema QuanLyBanHang_MySQL.sql da tao o bai truoc.
-- Chay 1 lan tren cac bang dang trong. Khong chay lai len data da them.
-- Ten cot thuc te: Customer.cName (khong phai Name trong mo ta).
-- `Order` la tu khoa SQL, phai su dung backticks.

USE QuanLyBanHang;

-- De bai yeu cau oTotalPrice = NULL o thoi diem tao hoa don.
-- Schema truoc day khai bao NOT NULL DEFAULT 0, nen can cho phep NULL.
ALTER TABLE `Order`
    MODIFY COLUMN oTotalPrice DECIMAL(14,2) NULL DEFAULT NULL;

-- 1. Them 3 khach hang.
INSERT INTO Customer (cID, cName, cAge) VALUES
    (1, 'Minh Quan', 10),
    (2, 'Ngoc Oanh', 20),
    (3, 'Hong Ha', 50);

-- 2. Them 5 san pham.
INSERT INTO Product (pID, pName, pPrice) VALUES
    (1, 'May Giat', 3),
    (2, 'Tu Lanh', 5),
    (3, 'Dieu Hoa', 7),
    (4, 'Quat', 1),
    (5, 'Bep Dien', 2);

-- 3. Them 3 hoa don. Ngay da chuyen sang YYYY-MM-DD.
INSERT INTO `Order` (oID, cID, oDate, oTotalPrice) VALUES
    (1, 1, '2006-03-21 00:00:00', NULL),
    (2, 2, '2006-03-23 00:00:00', NULL),
    (3, 1, '2006-03-16 00:00:00', NULL);

-- 4. Them 7 dong chi tiet hoa don.
INSERT INTO OrderDetail (oID, pID, odQTY) VALUES
    (1, 1, 3),
    (1, 3, 7),
    (1, 4, 2),
    (2, 1, 1),
    (3, 1, 8),
    (2, 5, 4),
    (2, 3, 3);

-- A. Hien thi ma hoa don, ngay mua va cot tong tien luu tru.
-- oPrice la ten hien thi theo de bai; du lieu oTotalPrice ban dau la NULL.
SELECT oID, oDate, oTotalPrice AS oPrice
FROM `Order`
ORDER BY oID;

-- B1. Danh sach khach hang da mua hang (khong lap khach hang).
SELECT DISTINCT c.cID, c.cName
FROM Customer AS c
INNER JOIN `Order` AS o ON o.cID = c.cID
ORDER BY c.cID;

-- B2. Chi tiet san pham ma tung khach hang da mua.
SELECT c.cID, c.cName, o.oID, p.pID, p.pName, od.odQTY
FROM Customer AS c
INNER JOIN `Order` AS o ON o.cID = c.cID
INNER JOIN OrderDetail AS od ON od.oID = o.oID
INNER JOIN Product AS p ON p.pID = od.pID
ORDER BY c.cID, o.oID, p.pID;

-- C. Khach hang chua mua bat ky san pham nao.
SELECT c.cID, c.cName
FROM Customer AS c
LEFT JOIN `Order` AS o ON o.cID = c.cID
WHERE o.oID IS NULL
ORDER BY c.cID;

-- D. Tong tien THUC TE cho moi hoa don = SUM(so luong * don gia).
-- LEFT JOIN va COALESCE giup hoa don khong co chi tiet hien 0.
SELECT o.oID, o.oDate,
       COALESCE(SUM(od.odQTY * p.pPrice), 0) AS oPrice
FROM `Order` AS o
LEFT JOIN OrderDetail AS od ON od.oID = o.oID
LEFT JOIN Product AS p ON p.pID = od.pID
GROUP BY o.oID, o.oDate
ORDER BY o.oID;

-- Kiem tra so dong trong cac bang (3, 3, 5, 7).
SELECT 'Customer' AS table_name, COUNT(*) AS total FROM Customer
UNION ALL SELECT 'Order', COUNT(*) FROM `Order`
UNION ALL SELECT 'Product', COUNT(*) FROM Product
UNION ALL SELECT 'OrderDetail', COUNT(*) FROM OrderDetail;
