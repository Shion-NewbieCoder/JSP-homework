/*
==========================================================================
SMARTFACTORY | BAI NOP DAY DU CHO HE THONG CHAM DOC 1 FILE SQL
==========================================================================
File nay giu NGUYEN cac lenh SQL va nhung truy van kiem chung.
De he thong cham DOC 1 DUONG LINK van thay du cac minh chung, phan
bao cao Trade-off va nhat ky Prompt Log duoc nhung duoi dang SQL COMMENT.
Hai tai lieu .md rieng van duoc giu trong ZIP dung yeu cau nop bai.

CHU Y: Phan so do INDEX_LENGTH va EXPLAIN thuc te can chay tren May
MySQL cua hoc vien. Khong tu dat so lieu, khong khang dinh benchmark
INSERT nhanh gap 5 lan hoac INDEX_LENGTH giam dung 70%.

================ 1. INDEX TRADE-OFF REPORT =================
# SmartFactory — Báo cáo đánh đổi Index / Read–Write–Storage

**CSDL:** `smartfactory_db` • **Bảng:** `SensorLogs` (InnoDB).  
**Thời điểm / phiên bản MySQL:** *Điền sau khi chạy trong MySQL Workbench.*  
**Số bản ghi:** *Điền từ `actual_log_count` (nếu bảng rỗng, script sinh 50.000 dòng).*  

## Đo dung lượng thực tế

| Giai đoạn | Data Length (MB) | Index Length (MB) |
|---|---:|---:|
| Trước — `idx_fat_covering` | *Điền `data_mb` BEFORE* | *Điền `index_mb` BEFORE* |
| Sau — `idx_lean_search` | *Điền `data_mb` AFTER* | *Điền `index_mb` AFTER* |
| Chênh lệch Index | — | *Điền `index_mb_saved`* |

**EXPLAIN thực đo:** Trước: `type = ___`, `key = ___`, `Extra = ___`; sau: `type = ___`, `key = ___`, `Extra = ___`.

## Nhận xét kỹ thuật (khoảng 200 từ)

`idx_fat_covering(sensor_id, recorded_at, temperature, humidity, status)` giúp truy vấn Dashboard lấy cả cột lọc và cột trả về ngay trong secondary index. `Extra = Using index` thường cho biết truy vấn đã được bao phủ; tuy nhiên điều đó không có nghĩa dữ liệu chắc chắn không phải đọc từ đĩa, bởi các trang Index cũng chịu tác động của bộ đệm InnoDB.

Đổi lại, mỗi bản ghi cảm biến mới phải được thêm vào cây Index chứa nhiều giá trị. Entry rộng hơn làm giảm số entry trên một trang, tăng lượng trang và chi phí bảo trì, có thể gây thêm I/O, cache misses và page splits. Index rộng không nhất thiết khiến một lệnh `INSERT` chậm đúng một tỷ lệ cố định.

Tôi bỏ `idx_fat_covering` và dùng `idx_lean_search(sensor_id, recorded_at)`, vì đây là hai trường cần lọc theo cảm biến và thời gian. Truy vấn vẫn có khả năng dùng `range` hoặc `ref`, nhưng thường phải truy cập clustered index theo khóa chính để lấy `temperature`, `humidity` và `status`. Như vậy đọc có thể chậm hơn, trong khi mỗi entry Index gọn hơn và giảm áp lực lưu trữ cũng như ghi.

So sánh `INDEX_LENGTH` trước/sau từ `information_schema.TABLES` chỉ là phép đo ước lượng theo page; không nên khẳng định giảm 70% dung lượng hay tăng INSERT 5 lần nếu chưa có benchmark. Nếu dùng cho bảng ít thay đổi, Covering Index có thể vẫn là lựa chọn hợp lý.

**Minh chứng cần giữ:** ảnh hai Result Grid của `EXPLAIN`, bảng `BEFORE/AFTER`, danh sách `SHOW INDEX` cuối script.

================ 2. AI PROMPT LOG (KIEN THUC) =================
# AI Prompt Log — SmartFactory Covering Index vs Lean Index

**Phạm vi:** Trao đổi khái niệm dựa trên đề bài SmartFactory. Những trả lời dưới đây là phân tích lý thuyết của AI, **không phải kết quả benchmark MySQL**. Để biến thành nhật ký học tập cá nhân, học viên có thể tự chạy lại các prompt và bổ sung nhận xét, ảnh thực nghiệm.

### Prompt 1 — Covering Index là gì?

**Câu hỏi:** “Covering Index trong MySQL khác gì Index bình thường và tại sao `EXPLAIN.Extra` lại hiện `Using index`?”

**AI giải thích:** Covering Index chứa tất cả giá trị cột cần thiết để xử lý SELECT (bao gồm cột WHERE và cột trả về). Với `idx_fat_covering(sensor_id, recorded_at, temperature, humidity, status)`, InnoDB có thể lấy các cột truy vấn Dashboard ngay trên secondary index. `Using index` là chỉ dấu covering; không có nghĩa hoàn toàn không cần I/O vật lý.

### Prompt 2 — Clustered và Secondary Index lưu gì?

**Câu hỏi:** “Trong InnoDB, PRIMARY KEY (Clustered Index) khác Secondary Index thế nào? Nếu bỏ các cột hiển thị khỏi Index thì hệ quản trị lấy chúng ở đâu?”

**AI giải thích:** Clustered Index lưu hàng dữ liệu chính theo khóa chính `log_id`. Secondary Index lưu khóa chỉ mục và giá trị khóa chính tương ứng. Với Lean Index `(sensor_id, recorded_at)`, MySQL tìm hàng phù hợp rồi dùng `log_id` để truy cập clustered index lấy `temperature`, `humidity`, `status`. Khi đó Extra có thể hiện `Using index condition`; đây là Index Condition Pushdown, **khác** `Using index` (covering).

### Prompt 3 — Đánh đổi Read / Write / Storage?

**Câu hỏi:** “Tại sao Index 5 cột có thể làm chậm INSERT so với Index 2 cột, dù số lượng Index vẫn chỉ là một?”

**AI giải thích:** Mỗi bản ghi phải cập nhật secondary B-Tree. Index 5 cột có entry lớn hơn nên mỗi page chứa ít entry hơn, tiêu hao buffer pool và dung lượng, có thể phát sinh ghi page, page split và redo log nhiều hơn. Không thể suy ra tốc độ tăng gấp 5 chỉ từ độ rộng Index.

### Prompt 4 — Ước lượng Byte của Index?

**Câu hỏi:** “Ước tính phần giá trị logic của mỗi entry với BIGINT, INT, DATETIME, DECIMAL(5,2), VARCHAR(20) trong MySQL như thế nào?”

**AI giải thích:** Theo kiểu lưu trữ thông thường: `INT` 4 byte, `DATETIME` không có phần thập phân 5 byte, `DECIMAL(5,2)` khoảng 3 byte mỗi cột, và khóa chính `BIGINT` 8 byte cũng nằm trong secondary entry. Lean Index có xấp xỉ 4 + 5 + 8 = 17 byte **giá trị logic**; Fat Index thêm khoảng 3 + 3 byte của hai DECIMAL và kích thước biến thiên của `status` (phụ thuộc văn bản, collation, encoding). Các số này **chưa** tính đầy đủ overhead record, độ dài biến thiên, NULL bitmap, tổ chức page, và page fill; không được dùng làm Index Length thực đo.

### Prompt 5 — Đo dung lượng với information_schema?

**Câu hỏi:** “Lấy `DATA_LENGTH` và `INDEX_LENGTH` từ `information_schema.TABLES` như thế nào, và khi DROP INDEX liệu file vật lý tự co lại?”

**AI giải thích:** Lọc `TABLE_SCHEMA = 'smartfactory_db'` và `TABLE_NAME = 'SensorLogs'` trong `information_schema.TABLES`, chia các giá trị byte cho 1024² để ra MB. InnoDB báo dung lượng theo page và có thể thay đổi/ước lượng khác với lượng ổ đĩa vật lý thực sự được giải phóng; drop index không bảo đảm cloud bill hoặc file `.ibd` giảm ngay.

### Prompt 6 — Khi nào nên dùng Covering Index?

**Câu hỏi:** “Nếu bảng ít INSERT/UPDATE mà chủ yếu phục vụ báo cáo, Covering Index có còn gây hại không?”

**AI giải thích:** Với bảng hầu như chỉ đọc, chi phí ghi nhỏ nên lợi ích tránh lookup bảng có thể lớn hơn chi phí lưu trữ. Cần quyết định bằng tần suất truy vấn, selectivity, dung lượng Index và benchmark của tải công việc thực tế.

================ 3. TRA LOI VAN DAP NHANH =================
Q: Tai sao Covering Index co the lam cham INSERT?
A: InnoDB phai ghi vao clustered index va cap nhat secondary index;
   entry index rong hon lam giam page fan-out, tang bo dem va I/O, co the
   phat sinh page splits. Khong phai moi INSERT deu toc do giam nhu nhau.

Q: Neu bang danh muc Countries rat hiem khi ghi thi sao?
A: Covering Index co the hop ly cho workload doc nhieu; loi ich SELECT
   co the lon hon chi phi cap nhat va luu tru. Can do bang benchmark.

Q: Neu doi status VARCHAR(20) sang TINYINT thi sao?
A: Gia tri TINYINT chi can 1 byte (khong tinh overhead), co the giam
   kich thuoc cot va entry Index neu cot tham gia index. Can mapping
   ma so trang thai, khong nen thay doi schema khi chua kiem tra su dung.

Q: Tai sao Lean Index khong con 'Using index'?
A: (sensor_id, recorded_at) chi phu cac cot loc; temperature, humidity,
   status khong o index nay, nen phai tra clustered index de lay du lieu.
   'Using index condition' la Index Condition Pushdown, KHONG PHAI
   Covering Index. Truoc/sau phai doi chieu EXPLAIN thuc te.
==========================================================================
*/

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
