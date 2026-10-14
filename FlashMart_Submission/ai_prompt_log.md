# Nhật ký trao đổi AI — FlashMart

> Ghi đúng những nội dung đã thực sự trao đổi/kiểm chứng; không ghi rằng đã kiểm thử thành công trước khi chạy MySQL.

## 14/10/2026 — Phân tích JOIN và COUNT

**Ngữ cảnh:** Phân tích bài FlashMart, yêu cầu giữ đủ khách hàng và tìm sản phẩm chưa bán.

**Câu hỏi kỹ thuật:** Khi dùng `JOIN` không ghi `LEFT` hoặc `RIGHT`, điều gì xảy ra với các dòng không có bản ghi phù hợp? Vì sao không dùng `COUNT(*)` để đếm đơn của khách hàng chưa mua?

**Tóm tắt giải thích của AI:** `JOIN` không có tiền tố là `INNER JOIN`, chỉ giữ cặp dòng khớp điều kiện. `LEFT JOIN` giữ toàn bộ bảng bên trái; với dòng không khớp, cột bảng bên phải nhận `NULL`. `COUNT(*)` đếm mọi dòng kể cả dòng không khớp được tạo bởi `LEFT JOIN`, còn `COUNT(o.order_id)` chỉ đếm giá trị khóa đơn không `NULL`.

**Kết luận cho học viên:** Chọn bảng bên trái dựa theo tập đối tượng cần giữ; sử dụng `LEFT JOIN ... WHERE o.order_id IS NULL` để tìm đối tượng chưa có giao dịch.

## Học viên bổ sung sau khi thực hành

- Kết quả báo cáo Marketing trong MySQL: _chưa kiểm tra_.
- Kết quả báo cáo Kho vận trong MySQL: _chưa kiểm tra_.
- Điều rút ra sau khi sửa truy vấn: _tự ghi sau khi chạy thử_.

## Câu hỏi mở rộng để hỏi thêm (chưa trao đổi)

- MySQL sử dụng Nested-Loop Join trong trường hợp nào? Index trên khóa JOIN giúp gì?
- `NOT EXISTS` có khác `NOT IN` khi subquery chứa `NULL` không?
