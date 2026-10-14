# Phân tích lựa chọn JOIN và COUNT

Trong báo cáo Marketing, `Customers` phải là bảng gốc vì cần giữ cả khách hàng chưa mua hàng. `INNER JOIN` chỉ giữ các cặp bản ghi khớp nên loại mất Charlie. Với `LEFT JOIN`, Charlie vẫn xuất hiện dù không có đơn hàng, các cột của `Orders` là `NULL`.

Không thể dùng `COUNT(*)` để đếm đơn hàng ở đây: khách hàng không có đơn vẫn tạo ra một dòng kết quả sau `LEFT JOIN`, nên `COUNT(*)` trả về 1. Ngược lại, `COUNT(o.order_id)` bỏ qua `NULL`, trả về đúng 0.

Đối với Kho vận, dùng `Products` làm bảng gốc; áp dụng `LEFT JOIN` rồi kiểm tra khóa đơn hàng `IS NULL` để xác định sản phẩm chưa phát sinh giao dịch.
