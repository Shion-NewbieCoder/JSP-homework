# Bài 5 - ERD quản lý đơn đặt hàng

Đã xây dựng mô hình ERD cho hệ thống quản lý đơn đặt hàng và giao hàng.

Sau khi chuẩn hóa, Đơn vị đặt hàng và Đơn vị khách hàng được gộp thành thực thể Đơn vị khách.

Các thực thể chính:
- Đơn vị khách
- Hàng
- Người đặt
- Người nhận
- Người giao
- Nơi giao
- Đơn đặt hàng
- Phiếu giao hàng
- Chi tiết đơn hàng
- Chi tiết phiếu giao

Người đặt thuộc Đơn vị khách.
Người nhận thuộc Đơn vị khách.

Quan hệ Đặt được biểu diễn qua Đơn đặt hàng và Chi tiết đơn hàng.
Quan hệ Giao được biểu diễn qua Phiếu giao hàng và Chi tiết phiếu giao.

Ảnh ERD hoàn chỉnh nằm trong thư mục Screen Shots.