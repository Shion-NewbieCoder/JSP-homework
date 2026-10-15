# User Management — JDBC Stored Procedures (List/Edit/Delete)

Đây là bản kế thừa từ **JDBC Use Transaction**. Toàn bộ các chức năng cũ vẫn còn.

- `GET /users`: `get_all_users(?, ?)` nhận bộ lọc quốc gia và thứ tự tên.
- `GET /users?action=edit&id=...`: `get_user_by_id(?)` đọc thông tin để điền form.
- `POST /users?action=edit`: `update_user(?, ?, ?, ?, OUT)` cập nhật.
- `GET /users?action=delete&id=...`: `get_user_by_id(?)` hiển thị xác nhận.
- `POST /users?action=delete`: `delete_user(?, OUT)` xóa mapping quyền rồi xóa user trong một transaction.
- `POST /users?action=create`: dùng `addUserTransaction()` để tạo user và gán quyền trong một transaction như bài trước.

**Quan trọng:** Chạy `database/stored_procedures_crud.sql` sau khi đã chạy `database/init.sql`, `database/transaction_permissions.sql`, `database/stored_procedures.sql`. Đừng chạy lại `init.sql` trên dữ liệu production.

Build từ thư mục này bằng `mvn clean package`, deploy `target/user-management.war` lên Tomcat 10.1+ và mở `http://localhost:8080/user-management/users`.

Xem [README tổng hợp và mã nguồn](../README.md) ở thư mục nộp bài.
