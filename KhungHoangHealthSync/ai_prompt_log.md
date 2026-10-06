# Nhật ký sử dụng AI trong quá trình thiết kế cơ sở dữ liệu

## Prompt 1

**Prompt:**

Trong thiết kế cơ sở dữ liệu quan hệ, tại sao dùng một cột Boolean như `is_active` để theo dõi vòng đời của một lịch hẹn có nhiều trạng thái lại không phù hợp? Nên thay thế bằng cấu trúc nào?

**Kết luận áp dụng:**

Boolean chỉ biểu diễn được hai trạng thái. Trong bài HealthSync, lịch hẹn có năm trạng thái khác nhau nên em thay `is_active` bằng cột `status` sử dụng `ENUM`.

---

## Prompt 2

**Prompt:**

Khi lưu tiền cọc và phí phạt trong MySQL, nên sử dụng `FLOAT`, `DOUBLE` hay `DECIMAL`? Tại sao?

**Kết luận áp dụng:**

Em chọn `DECIMAL(12,2)` vì đây là dữ liệu tài chính cần giá trị chính xác. `FLOAT` và `DOUBLE` có thể xuất hiện sai số biểu diễn số thực, không phù hợp cho tính toán tiền.

---

## Prompt 3

**Prompt:**

Cú pháp MySQL để dùng `ALTER TABLE` xóa một cột cũ và thêm cột `status` kiểu `ENUM` vào bảng hiện có là gì?

**Kết luận áp dụng:**

Em sử dụng `ALTER TABLE Appointments` để xóa `is_active` và bổ sung các trường `status`, `deposit_amount`, `penalty_fee` và `cancel_reason` mà không cần tạo lại toàn bộ cơ sở dữ liệu.

---

## Prompt 4

**Prompt:**

Làm thế nào để dùng câu lệnh `JOIN` giữa `Appointments`, `Patients`, `Doctors` và `Prescriptions` để kiểm tra các lịch hẹn đã hoàn tất và đơn thuốc tương ứng?

**Kết luận áp dụng:**

Em sử dụng các khóa ngoại để JOIN các bảng và lọc `status = 'COMPLETED'`, từ đó kiểm tra được bệnh nhân, bác sĩ, lịch khám và thông tin đơn thuốc trong cùng một kết quả.

---

## Prompt 5

**Prompt:**

Foreign Key có đủ để ngăn việc tạo đơn thuốc cho một lịch hẹn chưa hoàn tất không? Nếu không thì có thể dùng Trigger như thế nào?

**Kết luận áp dụng:**

Foreign Key chỉ đảm bảo lịch hẹn tồn tại, không kiểm tra được trạng thái nghiệp vụ. Em sử dụng `BEFORE INSERT TRIGGER` trên bảng `Prescriptions`; nếu lịch hẹn chưa có trạng thái `COMPLETED` thì trigger sử dụng `SIGNAL SQLSTATE '45000'` để từ chối thao tác.

---

## Prompt 6

**Prompt:**

Trong quan hệ giữa `Appointments` và `Prescriptions`, `ON DELETE RESTRICT` và `ON DELETE CASCADE` khác nhau như thế nào và trường hợp này nên chọn cách nào?

**Kết luận áp dụng:**

Em chọn `ON DELETE RESTRICT` để tránh việc xóa một lịch hẹn làm mất đơn thuốc liên quan một cách tự động. Đây là dữ liệu y tế nên cần hạn chế mất dữ liệu ngoài ý muốn.