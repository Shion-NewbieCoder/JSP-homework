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
