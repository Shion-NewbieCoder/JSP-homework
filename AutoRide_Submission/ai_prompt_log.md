# AutoRide – Nhật ký hỗ trợ kỹ thuật bằng AI

> Ghi chú: Đây là **bản tóm tắt nội dung thực tế đã trao đổi**, không phải trích nguyên văn toàn bộ prompt. Các bước SQL được chạy và kiểm tra trong MySQL Workbench bởi học viên.

| Chủ đề đã trao đổi | Nội dung hỗ trợ từ AI | Kết quả học viên kiểm tra |
|---|---|---|
| Kiểu dữ liệu tài chính | Vì sao nên dùng `DECIMAL(12,2)` thay vì `FLOAT` cho tiền cọc, phí trả trễ và phí hư hỏng? `DECIMAL` tránh sai số nhị phân khi tính tiền. | Lệnh `ALTER TABLE Rentals` chạy thành công; `DESCRIBE Rentals` hiển thị ba cột DECIMAL. |
| Trạng thái vòng đời | Thay `VARCHAR(50)` bằng `ENUM('BOOKED','ACTIVE','COMPLETED','CANCELLED')` để giới hạn trạng thái hợp lệ. | `DESCRIBE Rentals` xác nhận kiểu ENUM. |
| Quan hệ kiểm tra xe | Phân tích bảng `Inspections` riêng thay vì thêm mỗi `damage_description` vào `Rentals`; liên kết bằng khóa ngoại và `ON DELETE RESTRICT`. | Tạo bảng `Inspections` thành công; có khóa ngoại `rental_id`. |
| Biến ID sau INSERT | Sử dụng `LAST_INSERT_ID()` cho `@car_id`, `@rental_id` thay vì nhập ID thủ công. | Ban đầu `rental_id` bị `NULL` khi chèn biên bản; sau khi tạo và gán đúng mã hợp đồng, tiếp tục được. |
| Xử lý lỗi khi thử dữ liệu | Phân biệt lỗi `1048` (`rental_id` không được `NULL`) và lỗi `1062` (trùng `license_plate`). Không lặp lại `INSERT` xe đã tồn tại. | Học viên kiểm tra `Cars`, `Rentals`, `Inspections` rồi bổ sung biên bản bị thiếu. |
| Truy vấn đối soát | Dùng `JOIN` từ `Rentals` sang `Inspections`, tính `security_deposit - late_fee - damage_fee`. Cần cân nhắc `NULL` nếu thiết kế cho phép giá trị trống; bài này dùng `NOT NULL DEFAULT 0`. | Truy vấn trả về một dòng của Nguyen Van A: hoàn 8.000.000 đồng, trạng thái `COMPLETED`. |

## Nhận xét sau kiểm tra

- Đã kiểm tra **một kịch bản thành công**: nhận xe, kiểm tra vỡ đèn pha trái và hoàn tiền sau khấu trừ.
- Chưa kiểm thử đầy đủ các nhánh `CANCELLED`, trả xe trễ, hay giới hạn lỗi nghiệp vụ bằng trigger.
- Với yêu cầu nâng cao *không cho kiểm tra xe khi hợp đồng còn `BOOKED`*, có thể nghiên cứu `BEFORE INSERT` trigger tra trạng thái của `Rentals` và báo lỗi bằng `SIGNAL SQLSTATE '45000'`. Đây là hướng thiết kế đề xuất, **chưa triển khai/kiểm thử** trong script nộp.
