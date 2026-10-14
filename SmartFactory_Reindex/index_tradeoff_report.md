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
