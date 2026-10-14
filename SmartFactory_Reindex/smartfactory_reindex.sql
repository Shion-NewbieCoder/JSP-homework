-- SMARTFACTORY - REINDEX: FAT COVERING INDEX -> LEAN INDEX (MySQL 8.0+)
-- Bai thuc hanh CodeGym. CHI CHAY TREN MYSQL LOCAL / DATABASE DEMO.
-- Chay TOAN BO FILE trong CUNG MOT connection / tab MySQL Workbench.
-- Script khong DROP bang SensorLogs, nhung thay doi chi muc tren bang nay.
-- Neu bang rong, tao 50.000 dong gia lap de EXPLAIN va INDEX_LENGTH co y nghia.
-- Ket qua INDEX_LENGTH la SO DO THUC TE tu instance MySQL, KHONG CO SO GIA DINH.

-- ===================== 1. DATABASE & LEGACY =====================
CREATE DATABASE IF NOT EXISTS smartfactory_db
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smartfactory_db;

CREATE TABLE IF NOT EXISTS SensorLogs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sensor_id INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    status VARCHAR(20)
) ENGINE = InnoDB;

-- Khoi phuc baseline de co the chay lai tren DATABASE DEMO:
-- Neu lean index cua lan chay truoc con ton tai, bo no truoc khi do BEFORE.
SET @sf_has_lean := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'SensorLogs'
      AND INDEX_NAME = 'idx_lean_search'
);
SET @sf_sql := IF(@sf_has_lean > 0,
    'ALTER TABLE SensorLogs DROP INDEX idx_lean_search',
    'SELECT 1 AS lean_index_not_present');
PREPARE sf_stmt FROM @sf_sql;
EXECUTE sf_stmt;
DEALLOCATE PREPARE sf_stmt;

-- Tao FAT index neu chua co (neu da chay Legacy SQL thi khong tao trung).
SET @sf_has_fat := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'SensorLogs'
      AND INDEX_NAME = 'idx_fat_covering'
);
SET @sf_sql := IF(@sf_has_fat = 0,
    CONCAT('CREATE INDEX idx_fat_covering ON SensorLogs ',
           '(sensor_id, recorded_at, temperature, humidity, status)'),
    'SELECT 1 AS fat_index_already_present');
PREPARE sf_stmt FROM @sf_sql;
EXECUTE sf_stmt;
DEALLOCATE PREPARE sf_stmt;

-- ===================== 2. OPTIONAL TEST DATA =====================
-- Chi chen du lieu neu bang dang trong. Neu co du lieu cu, GIU NGUYEN.
SET @sf_seed_needed := (SELECT NOT EXISTS (SELECT 1 FROM SensorLogs));
-- MySQL 8.0+: dung CTE chu so, khong phai tao bang phu; CTE co the
-- tham chieu nhieu lan trong cung mot cau lenh, khac TEMPORARY TABLE.
-- 50.000 ban ghi tren 10.000 cam bien; du ngay 01-30/06/2026.
INSERT INTO SensorLogs (sensor_id, recorded_at, temperature, humidity, status)
WITH digits AS (
    SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2
    UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9
), seq AS (
    SELECT d0.d + 10*d1.d + 100*d2.d + 1000*d3.d + 10000*d4.d AS n
    FROM digits AS d0
    CROSS JOIN digits AS d1
    CROSS JOIN digits AS d2
    CROSS JOIN digits AS d3
    CROSS JOIN digits AS d4
)
SELECT
    MOD(seq.n, 10000) + 1 AS sensor_id,
    DATE_ADD('2026-06-01 00:00:00',
        INTERVAL MOD(seq.n * 53, 2592000) SECOND) AS recorded_at,
    CAST((2000 + MOD(seq.n, 3500)) / 100 AS DECIMAL(5,2)) AS temperature,
    CAST((3000 + MOD(seq.n * 7, 6000)) / 100 AS DECIMAL(5,2)) AS humidity,
    CASE
        WHEN MOD(seq.n, 1000) < 970 THEN 'NORMAL'
        WHEN MOD(seq.n, 1000) < 995 THEN 'WARNING'
        ELSE 'CRITICAL'
    END AS status
FROM seq
WHERE @sf_seed_needed = 1 AND seq.n < 50000;

SELECT COUNT(*) AS actual_log_count FROM SensorLogs;
ANALYZE TABLE SensorLogs;

-- Bang do rieng giu snapshot BEFORE va AFTER trong cung mot session.
DROP TEMPORARY TABLE IF EXISTS sf_storage_snapshots;
CREATE TEMPORARY TABLE sf_storage_snapshots (
    stage VARCHAR(10) PRIMARY KEY,
    data_bytes BIGINT UNSIGNED NOT NULL,
    index_bytes BIGINT UNSIGNED NOT NULL,
    estimated_rows BIGINT UNSIGNED
);

-- ===================== 3. BEFORE: FAT COVERING INDEX =====================
SHOW INDEX FROM SensorLogs;
SHOW TABLE STATUS LIKE 'SensorLogs';

INSERT INTO sf_storage_snapshots (stage, data_bytes, index_bytes, estimated_rows)
SELECT 'BEFORE', COALESCE(DATA_LENGTH, 0), COALESCE(INDEX_LENGTH, 0), TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'SensorLogs';

-- Ky vong: key=idx_fat_covering; Extra co the co 'Using index' (covering).
EXPLAIN
SELECT temperature, humidity, status
FROM SensorLogs
WHERE sensor_id = 105
  AND recorded_at >= '2026-06-20';

-- ===================== 4. DROP FAT / CREATE LEAN =====================
-- Dung 2 lenh DDL dung nhu yeu cau bai hoc.
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id, recorded_at);

ANALYZE TABLE SensorLogs;
SHOW INDEX FROM SensorLogs;
SHOW TABLE STATUS LIKE 'SensorLogs';

INSERT INTO sf_storage_snapshots (stage, data_bytes, index_bytes, estimated_rows)
SELECT 'AFTER', COALESCE(DATA_LENGTH, 0), COALESCE(INDEX_LENGTH, 0), TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'SensorLogs';

-- Ky vong: key=idx_lean_search, type=range/ref.
-- Extra KHONG con 'Using index' (co the la 'Using index condition').
-- Truy van van dung key de loc, sau do doc gia tri tu clustered index.
EXPLAIN
SELECT temperature, humidity, status
FROM SensorLogs
WHERE sensor_id = 105
  AND recorded_at >= '2026-06-20';

-- ===================== 5. COMPARISON OUTPUT =====================
-- Sao chep so do BEFORE/AFTER trong bang nay vao report.md.
SELECT stage,
       estimated_rows AS estimated_table_rows,
       ROUND(data_bytes / 1024 / 1024, 3) AS data_mb,
       ROUND(index_bytes / 1024 / 1024, 3) AS index_mb,
       index_bytes
FROM sf_storage_snapshots
ORDER BY FIELD(stage, 'BEFORE', 'AFTER');

-- Delta duoc tinh co dau; khong gia dinh luon giam theo dung mot ty le.
SELECT
    ROUND((CAST(b.index_bytes AS SIGNED) - CAST(a.index_bytes AS SIGNED))
          / 1024 / 1024, 3) AS index_mb_saved,
    CASE WHEN b.index_bytes = 0 THEN NULL
         ELSE ROUND(100.0 * (CAST(b.index_bytes AS SIGNED)
                                - CAST(a.index_bytes AS SIGNED))
                    / b.index_bytes, 2)
    END AS index_percent_change
FROM sf_storage_snapshots AS b
CROSS JOIN sf_storage_snapshots AS a
WHERE b.stage = 'BEFORE' AND a.stage = 'AFTER';

-- Kiem tra index sau cung: PRIMARY va idx_lean_search, khong con fat.
SHOW INDEX FROM SensorLogs;

-- Ghi chu:
-- 1. INDEX_LENGTH cua InnoDB la so uoc luong theo page; khong bao dam
--    file .ibd thu nho ngay sau ALTER TABLE; doi phan tram tuy du lieu.
-- 2. EXPLAIN la KE HOACH du tinh, khong la phep do ms SELECT/INSERT.
-- 3. 'Using index condition' KHAC 'Using index' (covering index).
-- 4. Neu chay lai, script khoi phuc FAT index truoc khi do BEFORE.
--    Tuyet doi khong chay quy trinh demo nay tren database production.
