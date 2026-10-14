# Stored Procedure với tham số IN / OUT / INOUT (MySQL)

Bài thực hành dựa trên cơ sở dữ liệu `classicmodels`, phần Stored Procedure Parameters của CodeGym.

## Nội dung bài

File `stored_procedure_parameters.sql` chứa ba thủ tục:

| Thủ tục | Tham số | Chức năng |
| --- | --- | --- |
| `getCusById(IN cusNum INT)` | IN | Lấy thông tin khách hàng theo `customerNumber`; chạy ví dụ `175`. |
| `GetCustomersCountByCity(IN in_city VARCHAR(50), OUT total INT)` | IN + OUT | Đếm khách hàng tại thành phố `Lyon` và đưa kết quả ra biến `@total`. |
| `SetCounter(INOUT counter INT, IN inc INT)` | INOUT + IN | Thay đổi trực tiếp biến `@counter`; cộng lần lượt 1, 1, 5 từ giá trị ban đầu 1. |

## Cách chạy trong MySQL Workbench

1. Bảo đảm đã import database `classicmodels` chứa bảng `customers` từ bài trước.
2. Mở `stored_procedure_parameters.sql` bằng **File → Open SQL Script**.
3. Chạy **toàn bộ** nội dung file (nút Execute All); không chỉ chạy phần bên trong `CREATE PROCEDURE`, vì cần `DELIMITER`.
4. Kiểm tra các tab Result Grid:
   - `CALL getCusById(175)` trả về khách hàng có `customerNumber = 175` (nếu dữ liệu mẫu chuẩn chưa bị đổi).
   - `SELECT @total` là số khách hàng tại Lyon, phụ thuộc dữ liệu bảng.
   - Ba kết quả `@counter`: **2**, **3**, **8**.
   - Lệnh cuối `SHOW PROCEDURE STATUS` liệt kê các thủ tục đã tạo.

Script có `DROP PROCEDURE IF EXISTS`, do đó có thể chạy lại mà không gặp lỗi trùng thủ tục. Script **không chèn, sửa hoặc xóa bản ghi** bảng `customers`. Lưu ý: việc thay thế các procedure có cùng tên sẽ ghi đè procedure của bài tập cũ nếu chúng đã tồn tại.

## Nộp bài GitHub

Giải nén thư mục `StoredProcedure_Parameters_ClassicModels` vào repo `JSP-homework`, rồi trong terminal tại thư mục repo chạy:

```powershell
git add StoredProcedure_Parameters_ClassicModels/
git commit -m "feat: add stored procedure parameter practice"
git push origin main
```

Nộp link trực tiếp tới file SQL (chỉ dùng **sau khi đã push thành công**):

https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/StoredProcedure_Parameters_ClassicModels/stored_procedure_parameters.sql

## Ghi chú

- `DELIMITER` là lệnh của MySQL client/Workbench, không phải lệnh SQL gửi trực tiếp tới server.
- Tham số `OUT` cung cấp đầu ra; `INOUT` cần giá trị đầu vào và ghi kết quả trở lại biến.
- `INT(11)` trong bài tham khảo được viết gọn thành `INT` vì MySQL 8.0 đã bỏ ý nghĩa chiều rộng hiển thị integer.
