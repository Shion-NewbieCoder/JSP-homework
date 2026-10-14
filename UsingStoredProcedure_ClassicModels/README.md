# Thực hành MySQL Stored Procedure — classicmodels

## Yêu cầu

- Đã có cơ sở dữ liệu `classicmodels` và bảng `customers` từ bài thực hành Index trước.
- Sử dụng **MySQL Workbench** (không cần import lại database).

## Cách chạy

1. Mở `using_stored_procedure.sql` trong MySQL Workbench.
2. Chạy **toàn bộ script** bằng nút tia sét.
3. Kiểm tra hai kết quả `CALL findAllCustomers()`:
   - Lần gọi thứ nhất: hiển thị tất cả khách hàng.
   - Lần gọi thứ hai: chỉ khách hàng có `customerNumber = 175` (nếu mẫu có mã 175).
4. `SHOW CREATE PROCEDURE` hiển thị định nghĩa cuối cùng, có điều kiện `WHERE customerNumber = 175`.

**Lưu ý:** File có `DROP PROCEDURE IF EXISTS findAllCustomers`, tức sẽ thay thế procedure **cùng tên** nếu đã tồn tại. Không xóa hoặc sửa dữ liệu trong bảng `customers`. Có thể chạy lại trên database bài tập.

## Nội dung thực hành

- `CREATE PROCEDURE`, `BEGIN ... END`, `DELIMITER`.
- `CALL` thủ tục đã tạo.
- `DROP PROCEDURE IF EXISTS` rồi tạo lại để thay đổi phần thân thủ tục.

## Đưa lên GitHub

Đặt cả thư mục `UsingStoredProcedure_ClassicModels` vào repo `JSP-homework`, sau đó chạy trong terminal ở thư mục repo:

```powershell
git add UsingStoredProcedure_ClassicModels/
git commit -m "feat: add MySQL stored procedure practice"
git push origin main
```

Nộp link trực tiếp tới `using_stored_procedure.sql` trên GitHub.
