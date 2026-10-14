# PayFlow — Phân tích EXPLAIN trước và sau tối ưu

**Môi trường:** MySQL 8.x, dữ liệu mô phỏng trong `payflow_optimized.sql` (không phải 5 triệu giao dịch thật).

| Chỉ số | Trước khi thêm index | Sau khi thêm index |
|---|---|---|
| `type` | [Điền theo EXPLAIN thực tế] | [Điền theo EXPLAIN thực tế] |
| `possible_keys` | [Điền] | [Điền] |
| `key` | [Điền] | [Điền] |
| `rows` | [Điền] | [Điền] |
| `Extra` | [Điền] | [Điền] |

**Nhận xét:** Truy vấn cũ bọc `created_at` trong `YEAR()` và `MONTH()`, làm điều kiện thời gian không SARGable đối với B-tree index thông thường. Truy vấn mới lọc `transaction_type = 'DEPOSIT'` và khoảng ngày nửa mở từ `2026-06-01` đến trước `2026-07-01`. Index ghép `(transaction_type, created_at)` phù hợp với điều kiện bằng trên cột đầu và khoảng trên cột sau. Trong `EXPLAIN`, `type = ALL` là quét toàn bảng; `range` cho thấy quét một khoảng khóa, còn `rows` chỉ là ước lượng. Cần chụp kết quả MySQL thật và ghi các chỉ số vào bảng; không được tự khẳng định mức cải thiện khi chưa đo. Hai tổng `old_total` và `optimized_total` phải bằng nhau.
