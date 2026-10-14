-- QUICKFEED: DOI CHIEU DUNG LUONG VA TOI UU HOA INDEX (MySQL 8+)
-- DUNG CHO CSDL THUC HANH/LOCAL. KHONG CHAY TREN MAY CHU PRODUCTION.
-- Kich thuoc truoc/sau duoc DO TU MYSQL, KHONG PHAN DOAN.
-- Chay toan bo file trong mot session MySQL Workbench.

CREATE DATABASE IF NOT EXISTS quickfeed_db
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE quickfeed_db;

-- 1. Chuan bi bang mau neu chua co. Khong xoa du lieu hien huu.
CREATE TABLE IF NOT EXISTS Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    post_type VARCHAR(10),
    is_visible BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- 2. Chuan bi tinh huong legacy 5 secondary indexes.
-- Chi tao index NEU chua ton tai; them 10,000 bai viet gia lap NEU bang rong.
-- 10,000 dong la du lieu demo, KHONG PHAI 5 trieu dong production.
-- Chay tren database thuc hanh; tao index tren bang lon co the rat ton kem.
DROP PROCEDURE IF EXISTS quickfeed_prepare_demo;
DELIMITER //
CREATE PROCEDURE quickfeed_prepare_demo()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Posts'
          AND INDEX_NAME = 'idx_user_id'
    ) THEN
        CREATE INDEX idx_user_id ON Posts(user_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Posts'
          AND INDEX_NAME = 'idx_content'
    ) THEN
        CREATE INDEX idx_content ON Posts(content(255));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Posts'
          AND INDEX_NAME = 'idx_post_type'
    ) THEN
        CREATE INDEX idx_post_type ON Posts(post_type);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Posts'
          AND INDEX_NAME = 'idx_is_visible'
    ) THEN
        CREATE INDEX idx_is_visible ON Posts(is_visible);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Posts'
          AND INDEX_NAME = 'idx_created_at'
    ) THEN
        CREATE INDEX idx_created_at ON Posts(created_at);
    END IF;

    IF (SELECT COUNT(*) FROM Posts) = 0 THEN
        INSERT INTO Posts (user_id, content, post_type, is_visible, created_at)
        SELECT
            MOD(seq, 2000) + 1,
            CONCAT('QuickFeed demo #', seq, ': ', RPAD('Noi dung bai viet ', 300, 'x')),
            ELT(MOD(seq, 3) + 1, 'TEXT', 'IMAGE', 'VIDEO'),
            IF(MOD(seq, 100) = 0, 0, 1),
            TIMESTAMP('2026-01-01 00:00:00') + INTERVAL seq MINUTE
        FROM (
            SELECT (a.n + b.n * 10 + c.n * 100 + d.n * 1000 + 1) AS seq
            FROM (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS a
            CROSS JOIN (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS b
            CROSS JOIN (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS c
            CROSS JOIN (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS d
        ) AS numbers;
    END IF;
END //
DELIMITER ;

CALL quickfeed_prepare_demo();
DROP PROCEDURE quickfeed_prepare_demo;

-- 3. THONG KE TRUOC KHI XOA INDEX.
-- Lam moi thong ke sau khi tao index va nhap du lieu demo.
ANALYZE TABLE Posts;
SHOW INDEX FROM Posts;
SHOW TABLE STATUS LIKE 'Posts';

-- Bang tam ghi 2 moc DO THUC TE trong cung phien lam viec.
DROP TEMPORARY TABLE IF EXISTS quickfeed_storage_log;
CREATE TEMPORARY TABLE quickfeed_storage_log (
    stage VARCHAR(10) PRIMARY KEY,
    table_rows_est BIGINT,
    data_length_bytes BIGINT,
    index_length_bytes BIGINT
);

INSERT INTO quickfeed_storage_log
    (stage, table_rows_est, data_length_bytes, index_length_bytes)
SELECT 'BEFORE', TABLE_ROWS, DATA_LENGTH, INDEX_LENGTH
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Posts';

SELECT 'BEFORE' AS phase, TABLE_NAME,
       ROUND(DATA_LENGTH / 1024 / 1024, 4) AS data_mb,
       ROUND(INDEX_LENGTH / 1024 / 1024, 4) AS index_mb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Posts';

-- 4. LOAI BO CHINH XAC 3 INDEX KHONG PHU HOP VOI WORKLOAD DA CHO.
-- GIU idx_user_id, idx_created_at va PRIMARY KEY.
ALTER TABLE Posts DROP INDEX idx_content;
ALTER TABLE Posts DROP INDEX idx_post_type;
ALTER TABLE Posts DROP INDEX idx_is_visible;

-- 5. THONG KE SAU KHI XOA INDEX.
ANALYZE TABLE Posts;
SHOW INDEX FROM Posts;
SHOW TABLE STATUS LIKE 'Posts';

INSERT INTO quickfeed_storage_log
    (stage, table_rows_est, data_length_bytes, index_length_bytes)
SELECT 'AFTER', TABLE_ROWS, DATA_LENGTH, INDEX_LENGTH
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Posts';

SELECT 'AFTER' AS phase, TABLE_NAME,
       ROUND(DATA_LENGTH / 1024 / 1024, 4) AS data_mb,
       ROUND(INDEX_LENGTH / 1024 / 1024, 4) AS index_mb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Posts';

-- 6. BANG DOI CHIEU TRUOC / SAU: copy so lieu vao report .md.
SELECT stage AS phase,
       table_rows_est,
       ROUND(data_length_bytes / 1048576, 4) AS data_mb,
       ROUND(index_length_bytes / 1048576, 4) AS index_mb
FROM quickfeed_storage_log
ORDER BY CASE stage WHEN 'BEFORE' THEN 1 ELSE 2 END;

SELECT ROUND((b.index_length_bytes - a.index_length_bytes) / 1048576, 4)
           AS index_mb_difference_before_minus_after,
       ROUND(100.0 * (b.index_length_bytes - a.index_length_bytes)
             / NULLIF(b.index_length_bytes, 0), 2)
           AS estimated_index_reduction_percent
FROM quickfeed_storage_log AS b
CROSS JOIN quickfeed_storage_log AS a
WHERE b.stage = 'BEFORE' AND a.stage = 'AFTER';

-- Xac minh: CHI con cac index PRIMARY, idx_user_id, idx_created_at.
-- Canh bao: DATA_LENGTH / INDEX_LENGTH cua InnoDB la uoc luong.
-- Tren bang rong, ket qua co the la 0; giai phong file vat ly khong
-- nhat thiet dien ra ngay khi DROP INDEX. Khong bao gio bia so lieu.
