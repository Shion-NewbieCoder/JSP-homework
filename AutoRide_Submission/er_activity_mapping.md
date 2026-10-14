# AutoRide – Đối chiếu Activity Diagram và ERD

Quy trình thuê xe gồm đặt xe và đóng cọc (`BOOKED`), nhận xe (`ACTIVE`), kiểm tra khi trả xe và hoàn tất (`COMPLETED`). Cơ sở dữ liệu cũ không lưu tiền cọc, phí trả trễ và phí hư hỏng nên không thể đối soát chính xác số tiền phải hoàn cho khách. Đặc biệt, **`damage_fee` là bắt buộc** vì nếu thiếu khoản này, trường hợp xe hư hỏng vẫn có thể bị hoàn trả toàn bộ tiền cọc, gây thất thoát và thiếu căn cứ kế toán.

Bảng `Rentals` được bổ sung `security_deposit`, `late_fee`, `damage_fee` kiểu `DECIMAL(12,2)` và trạng thái `ENUM` để giới hạn giá trị hợp lệ. Số tiền hoàn tính theo công thức **tiền cọc − phí trễ − phí hư hỏng**.

Bảng `Inspections` lưu ngày kiểm tra, nhân viên và mô tả hư hỏng, liên kết với `Rentals` qua khóa ngoại `ON DELETE RESTRICT`. Việc tách bảng giúp lưu nhiều lần kiểm tra mà không trộn dữ liệu kiểm tra vào hợp đồng. Kịch bản kiểm thử: cọc 10.000.000 đồng, phí hư hỏng 2.000.000 đồng, hoàn **8.000.000 đồng**.
