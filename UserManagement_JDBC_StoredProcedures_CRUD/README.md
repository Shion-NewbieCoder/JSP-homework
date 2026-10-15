# CodeGym — JDBC CallableStatement: List, Edit & Delete Users

Bài này nâng cấp **User Management (Java 17 + JSP/JSTL + Servlet + MySQL)**, tiếp nối các bài CRUD, tìm Country, sắp xếp Name, gán Permission, Stored Procedure cho Create/Edit-form và JDBC Transaction.

## 1. Yêu cầu và cách thực hiện

| Chức năng | Stored Procedure | JDBC |
| --- | --- | --- |
| Danh sách User | `get_all_users(IN filter_country, IN sort_order)` | `CallableStatement.executeQuery()` |
| Sửa thông tin | `update_user(IN id, IN name, IN email, IN country, OUT exists)` | `CallableStatement.execute()` và `getInt(5)` |
| Xóa User | `delete_user(IN id, OUT deleted_count)` | `CallableStatement.execute()` và `getInt(2)` |
| Mở form Edit/Delete | `get_user_by_id(IN id)` (bài trước) | `CallableStatement.executeQuery()` |
| Thêm User kèm quyền | `addUserTransaction()` (bài trước) | `PreparedStatement` trong một transaction |

Trong ứng dụng này, `searchAndSort()` cũng ủy quyền cho `get_all_users()`, để **kể cả khi lọc country hoặc đổi A–Z/Z–A, danh sách vẫn lấy từ Stored Procedure**. Mọi dữ liệu do người dùng nhập được truyền qua tham số JDBC, không nối trực tiếp thành lệnh SQL.

Procedure `delete_user` xóa các bản ghi `user_permission` trước khi xóa `users`, vì bảng phân quyền hiện có foreign key ràng buộc. Hai bước được đóng trong transaction ở MySQL: lỗi ở bước sau sẽ rollback bước trước.

## 2. Cấu trúc chính

```text
UserManagement_JDBC_StoredProcedures_CRUD/
├── README.md
└── user-management/
    ├── pom.xml
    ├── database/
    │   ├── init.sql
    │   ├── transaction_permissions.sql
    │   ├── stored_procedures.sql
    │   └── stored_procedures_crud.sql    <-- BÀI MỚI
    ├── src/main/java/com/codegym/
    │   ├── model/User.java
    │   ├── dao/IUserDAO.java             <-- BỔ SUNG 3 HÀM
    │   ├── dao/UserDAO.java              <-- CALLABLESTATEMENT
    │   └── controller/UserServlet.java   <-- CẬP NHẬT LUỒNG
    ├── src/main/webapp/user/
    │   ├── list.jsp                      <-- TÌM COUNTRY + SORT NAME
    │   ├── create.jsp
    │   ├── edit.jsp
    │   └── delete.jsp
    └── tests/                          <-- KIỂM THỬ MÔ PHỎNG
```

## 3. Chạy MySQL Workbench

Chạy lần lượt các file SQL sau trên **MySQL dùng để học tập**. Các file `CREATE TABLE IF NOT EXISTS` không chủ động xóa dữ liệu hiện có; nhưng hãy sao lưu trước khi thao tác.

```text
1. database/init.sql
2. database/transaction_permissions.sql
3. database/stored_procedures.sql
4. database/stored_procedures_crud.sql
```

Sau đó kiểm tra:

```sql
USE demo;
SHOW PROCEDURE STATUS WHERE Db = 'demo';
CALL get_all_users('', 'asc');
CALL get_all_users('Viet Nam', 'desc');
CALL get_user_by_id(1);
```

Thao tác sửa/xóa cũng có thể thử bằng `CALL update_user(..., @updated); SELECT @updated;` và `CALL delete_user(..., @deleted); SELECT @deleted;` nhưng **chỉ thử trên User test**, vì đây là thao tác thay đổi dữ liệu thật.

## 4. Cấu hình MySQL và Tomcat

Cài JDK 17+, Maven, MySQL 8.0+, Tomcat 10.1+.

Ứng dụng dùng biến môi trường để không lưu mật khẩu vào GitHub:

```powershell
$env:DB_URL = "jdbc:mysql://localhost:3306/demo?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh"
$env:DB_USER = "root"
$env:DB_PASSWORD = "YOUR_LOCAL_MYSQL_PASSWORD"
```

Lưu ý: Tomcat phải được **khởi chạy trong môi trường nhận được các biến trên**, không chỉ terminal dùng để build Maven. `DB_PASSWORD` là biến môi trường **trên máy của bạn**, không commit mật khẩu thật lên GitHub.

Từ thư mục `user-management/`:

```powershell
mvn clean package
```

Copy `target/user-management.war` vào `webapps/` của Tomcat, khởi động/redeploy lại, rồi mở:

- `http://localhost:8080/user-management/users`
- `http://localhost:8080/user-management/users?action=create`
- `http://localhost:8080/user-management/users?action=edit&id=1`
- `http://localhost:8080/user-management/users?action=delete&id=1` (không xác nhận xóa nếu chỉ muốn xem)

## 5. Test từng chức năng

1. Mở danh sách: kiểm tra User từ database hiển thị theo tên A–Z.
2. Chọn Country và Z–A: kết quả phải được lọc và sắp xếp như lựa chọn.
3. Tạo một User **dùng để test**, quay lại danh sách và bấm **Sửa**: dữ liệu cũ xuất hiện, lưu lại và kiểm tra thay đổi trong MySQL.
4. Bấm **Xóa** trên User test có ít nhất 1 quyền, xác nhận xóa: cả `users` và `user_permission` không còn bản ghi liên quan.
5. ID không tồn tại phải cho trang 404, không làm thay đổi dữ liệu.

Kiểm tra nhanh MySQL (điền ID của User test):

```sql
USE demo;
SELECT * FROM users ORDER BY id;
SELECT * FROM user_permission ORDER BY user_id, permission_id;
```

## 6. Phân biệt Stored Procedure và PreparedStatement

`PreparedStatement` thực thi câu SQL có placeholder trực tiếp từ Java. `CallableStatement` gọi thủ tục đã đăng ký trong MySQL qua cú pháp `{CALL procedure_name(?, ...)}`; nó hỗ trợ `IN` và `OUT` parameters. Cả hai đều hỗ trợ truyền tham số an toàn. `CallableStatement` không tự đảm bảo transaction: đó là trách nhiệm của cấu trúc procedure và transaction tương ứng.

Các hàm `updateUser`, `deleteUser` và query JDBC cũ được giữ nguyên trong DAO phục vụ tham khảo/kiểm thử hồi quy, nhưng **luồng Servlet thực tế sử dụng `updateUserStore` và `deleteUserStore`**.

## 7. Kết quả kiểm thử và giới hạn

Mã Java có thể được kiểm tra qua JDK 17 và các test mock trong `tests/`; những bài test này **không thay thế** cho kiểm thử tích hợp MySQL + Tomcat. Cần chạy các bước mục 5 trên máy để xác nhận thực tế.

Chủ đề: Java JSP / Servlet / JDBC / MySQL Stored Procedures — CodeGym.
