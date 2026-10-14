-- PAYFLOW: EXPLAIN + COMPOSITE INDEX + RANGE QUERY
-- MySQL 8.0+. Chay trong MySQL Workbench tren database thu nghiem.
-- Chi chay CREATE INDEX mot lan. Khong ap dung truc tiep tren CSDL production.

CREATE DATABASE IF NOT EXISTS payflow_db;
USE payflow_db;

-- 1. Bang nghiep vu theo de bai (chi tao neu chua co).
CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(15,2),
    transaction_type VARCHAR(20),
    created_at DATETIME
) ENGINE=InnoDB;

-- 2. Du lieu MO PHONG (10,000 giao dich), chi them neu bang dang rong.
-- De bai gia dinh 5 trieu dong; day KHONG PHAI so lieu production.
-- Bang co so dong qua it thi optimizer co the van chon type = ALL.
DROP TEMPORARY TABLE IF EXISTS payflow_digits;
CREATE TEMPORARY TABLE payflow_digits (n INT PRIMARY KEY);
INSERT INTO payflow_digits (n)
VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

INSERT INTO Transactions (user_id, amount, transaction_type, created_at)
SELECT
    MOD(s.n, 500) + 1,
    10000.00 + MOD(s.n, 3000) * 100.00,
    CASE
        WHEN MOD(s.n, 5) = 0 THEN 'DEPOSIT'
        WHEN MOD(s.n, 5) = 1 THEN 'WITHDRAW'
        ELSE 'TRANSFER'
    END,
    CASE
        WHEN MOD(s.n, 20) = 0
            THEN DATE_ADD('2026-06-01 00:00:00', INTERVAL MOD(s.n, 28) DAY)
        WHEN MOD(s.n, 2) = 0
            THEN DATE_ADD('2026-05-01 00:00:00', INTERVAL MOD(s.n, 28) DAY)
        ELSE DATE_ADD('2026-07-01 00:00:00', INTERVAL MOD(s.n, 28) DAY)
    END
FROM (
    SELECT d0.n + 10*d1.n + 100*d2.n + 1000*d3.n AS n
    FROM payflow_digits d0
    CROSS JOIN payflow_digits d1
    CROSS JOIN payflow_digits d2
    CROSS JOIN payflow_digits d3
) AS s
WHERE NOT EXISTS (SELECT 1 FROM Transactions LIMIT 1);

DROP TEMPORARY TABLE payflow_digits;
SELECT COUNT(*) AS total_transactions FROM Transactions;

-- 3. EXPLAIN truoc toi uu (chay TRUOC khi tao index).
-- YEAR/MONTH bao quanh created_at: khong tan dung duoc range tren B-tree date.
EXPLAIN
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND YEAR(created_at) = 2026
  AND MONTH(created_at) = 6;

-- 4. Them composite index. Chay mot lan, khong chay lai khi da co index.
CREATE INDEX idx_type_date
ON Transactions (transaction_type, created_at);

ANALYZE TABLE Transactions;

-- 5. EXPLAIN sau toi uu: dieu kien khoang nua mo [01/06, 01/07).
EXPLAIN
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND created_at >= '2026-06-01 00:00:00'
  AND created_at <  '2026-07-01 00:00:00';

-- 6. Kiem tra tong tien cu va moi khop nhau.
SELECT
    (SELECT COALESCE(SUM(amount), 0)
     FROM Transactions
     WHERE transaction_type = 'DEPOSIT'
       AND YEAR(created_at) = 2026
       AND MONTH(created_at) = 6) AS old_total,
    (SELECT COALESCE(SUM(amount), 0)
     FROM Transactions
     WHERE transaction_type = 'DEPOSIT'
       AND created_at >= '2026-06-01 00:00:00'
       AND created_at <  '2026-07-01 00:00:00') AS optimized_total;

-- Ghi chu: EXPLAIN 'rows' la UOC LUONG cua optimizer, khong phai so dong
-- da doc thuc te. Tren bang nho, MySQL co the chon ALL du co index.
