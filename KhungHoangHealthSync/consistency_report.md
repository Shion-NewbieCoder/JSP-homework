# Báo cáo phân tích tính nhất quán giữa nghiệp vụ và cơ sở dữ liệu

Sau khi đối chiếu quy trình đặt lịch và khám bệnh với cơ sở dữ liệu cũ của HealthSync, em nhận thấy một số điểm không nhất quán nghiêm trọng.

Thứ nhất, bảng `Appointments` sử dụng cột `is_active` kiểu Boolean để biểu diễn trạng thái lịch hẹn. Cách thiết kế này chỉ thể hiện được hai trạng thái đúng/sai, trong khi quy trình nghiệp vụ yêu cầu năm trạng thái gồm `PENDING`, `CONFIRMED`, `CHECKED_IN`, `COMPLETED` và `CANCELLED`. Vì vậy, cột này được thay bằng `status` sử dụng kiểu `ENUM`.

Thứ hai, cơ sở dữ liệu cũ không có các trường lưu tiền cọc, phí phạt và lý do hủy. Điều này khiến hệ thống không thể xử lý nghiệp vụ hủy lịch sau khi đã xác nhận cọc, đồng thời gây khó khăn cho việc đối soát tài chính. Các trường `deposit_amount`, `penalty_fee` và `cancel_reason` đã được bổ sung. Hai trường tiền sử dụng kiểu `DECIMAL` để hạn chế sai số khi tính toán.

Thứ ba, hệ thống cũ hoàn toàn không có bảng lưu đơn thuốc. Bảng `Prescriptions` được bổ sung và liên kết với `Appointments` bằng khóa ngoại.

Ngoài ra, trigger được sử dụng để ngăn việc tạo đơn thuốc cho các lịch hẹn chưa ở trạng thái `COMPLETED`, giúp đảm bảo tính toàn vẹn nghiệp vụ ngay tại tầng cơ sở dữ liệu.