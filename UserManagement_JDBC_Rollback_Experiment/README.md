# CodeGym — JDBC Transaction: Gây lỗi SQL để kiểm chứng Rollback

Bài nộp này **tiếp nối dự án User Management JDBC** đã làm: Model–DAO–Servlet–JSP, quản lý users, tìm country, sắp xếp name, Stored Procedures, phân quyền. Bài mới nhất yêu cầu sửa cách kiểm thử `addUserTransaction()` để **cố tình gây lỗi SQL rồi kiểm tra `rollback()` có hoàn tác INSERT hay không**.

> **Phạm vi:** Chỉ chạy trên MySQL `demo` phục vụ học tập. Chưa chạy tích hợp trên MySQL/Tomcat thật ở môi trường tạo bài; các kết quả test bên dưới sử dụng JDBC/Servlet mock.

## 1. Cách vận hành và các file cần chấm

| Yêu cầu | File | Ý nghĩa |
| --- | --- | --- |
| Tạo User + phân quyền chung một giao dịch | [`UserDAO.java`](user-management/src/main/java/com/codegym/dao/UserDAO.java) | `addUserTransaction()` gọi `setAutoCommit(false)`, lấy ID, gán quyền, `commit()` hoặc `rollback()` |
| Khai báo phương thức DAO | [`IUserDAO.java`](user-management/src/main/java/com/codegym/dao/IUserDAO.java) | `addUserTransaction(User, int[])`, `countUsersByEmail()` |
| Tạo tình huống lỗi theo chủ đích | [`UserServlet.java`](user-management/src/main/java/com/codegym/controller/UserServlet.java) | `POST ?action=test-user-rollback` gọi DAO với quyền `1` và `Integer.MAX_VALUE` |
| Giao diện và thông báo kết quả | [`rollback-experiment.jsp`](user-management/src/main/webapp/user/rollback-experiment.jsp) | Nút POST, kết quả, thông báo lỗi, mã truy vấn kiểm tra |
| SQL kiểm tra điều kiện | [`rollback_demo_precheck.sql`](user-management/database/rollback_demo_precheck.sql) | Kiểm tra ENGINE InnoDB + FK + permission hợp lệ/vô hiệu |
| SQL kiểm chứng | [`verify_user_rollback.sql`](user-management/database/verify_user_rollback.sql) | Dùng email ngẫu nhiên để SELECT user và quyền còn tồn tại |
| Test mô phỏng | [`RollbackExperimentMockTest.java`](user-management/tests/RollbackExperimentMockTest.java) và [`ServletRollbackExperimentMockTest.java`](user-management/tests/ServletRollbackExperimentMockTest.java) | Test cả luồng rollback và không báo đạt giả |

Không sửa logic CRUD cũ thành lỗi cố định: ứng dụng thật vẫn thêm User bình thường. **Chỉ URL thí nghiệm** chủ động truyền dữ liệu làm phát sinh SQLException. GET không ghi dữ liệu; phải bấm POST mới thử nghiệm.

## 2. Tại sao lỗi SQL phát sinh?

Bảng `permission` trong dữ liệu demo có các ID `1`, `2`, `3`, `4` và bảng `user_permission` có khóa ngoại `permission_id` tham chiếu `permission(id)`.

Một lượt chạy sử dụng email độc nhất `tx-rollback-<UUID>@example.invalid`:

1. Tắt auto-commit: `connection.setAutoCommit(false)`.
2. Thực hiện `INSERT INTO users ...`, đọc `Statement.RETURN_GENERATED_KEYS` để lấy `user_id`.
3. Chèn `user_permission(user_id, 1)` — đúng, nhưng **chưa được commit**.
4. Chèn `user_permission(user_id, 2147483647)` — sai vì quyền này **không tồn tại** trong dữ liệu demo; MySQL với FK trả `SQLState 23000`, mã lỗi 1452.
5. `catch(SQLException ...)` gọi `connection.rollback()` rồi **ném lỗi trở lại** Servlet.
6. Servlet chạy `SELECT COUNT(*) FROM users WHERE email = ?` qua **Connection mới**. Kết quả `0` cùng lỗi FK 1452 chứng minh giao dịch không để lại User test.

**Điều kiện:** Bảng phải dùng InnoDB, tồn tại ràng buộc FK, permission `1` có thật và ID `2147483647` không tồn tại. Trước khi chạy, kiểm tra bằng `rollback_demo_precheck.sql`. Nếu schema chưa đúng hoặc thiếu mật khẩu, chương trình phải hiển thị **chưa kiểm chứng**, không được ghi nhận là rollback thành công.

### Code cốt lõi trong `UserDAO.java`

```java
@Override
public void addUserTransaction(User user, int[] permissionIds) throws SQLException {
    if (user == null) {
        throw new IllegalArgumentException("User không được null");
    }
    int[] selected = permissionIds == null ? new int[0] : permissionIds;
    final String sqlAssign =
            "INSERT INTO user_permission (user_id, permission_id) VALUES (?, ?)";

    try (Connection con = getConnection()) {
        con.setAutoCommit(false);
        try {
            int newUserId;
            try (PreparedStatement ps = con.prepareStatement(
                    SQL_INSERT, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, user.getName());
                ps.setString(2, user.getEmail());
                ps.setString(3, user.getCountry());
                if (ps.executeUpdate() != 1) {
                    throw new SQLException("Không tạo được User mới");
                }
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new SQLException("MySQL không trả ID cho User mới");
                    }
                    newUserId = keys.getInt(1);
                }
            }
            if (selected.length > 0) {
                try (PreparedStatement ps = con.prepareStatement(sqlAssign)) {
                    for (int permissionId : selected) {
                        ps.setInt(1, newUserId);
                        ps.setInt(2, permissionId);
                        if (ps.executeUpdate() != 1) {
                            throw new SQLException("Không gán được quyền: " + permissionId);
                        }
                    }
                }
            }
            con.commit();
        } catch (SQLException | RuntimeException failure) {
            try {
                con.rollback();
            } catch (SQLException rollbackError) {
                failure.addSuppressed(rollbackError);
            }
            throw failure;
        }
    }
}
```

### Mã tạo lỗi trong `UserServlet.java`

```java
// POST /users?action=test-user-rollback
String email = "tx-rollback-" + UUID.randomUUID().toString().replace("-", "")
        + "@example.invalid";
User testUser = new User("JDBC Rollback Demo", email, "VN");
try {
    // INSERT User + gán quyền đúng #1, sau đó quyền vô hiệu -> lỗi FK
    dao.addUserTransaction(testUser, new int[] {1, Integer.MAX_VALUE});
    req.setAttribute("unexpectedCommit", true); // Nếu không hề có lỗi: KHÔNG ĐẠT
} catch (SQLException ex) {
    boolean expectedFk = ex.getErrorCode() == 1452
            && ex.getSQLState() != null && ex.getSQLState().startsWith("23");
    req.setAttribute("expectedForeignKey", expectedFk);
    req.setAttribute("sqlError", ex.getMessage());
}
// Sau lỗi: xác minh lại bằng SELECT COUNT(*) WHERE email = ? ở connection mới.
```

**Lưu ý:** Đoạn Servlet ở trên tóm tắt phần cốt lõi. Mã nguồn thực có kiểm tra lại số bản ghi, nhận biết lỗi xác minh và chỉ báo đạt khi lỗi FK đúng **và** số dòng bằng 0.

## 3. Tạo database và chạy project

Cài **JDK 17+**, **Maven**, **MySQL 8.0+**, **Apache Tomcat 10.1+**. Trong MySQL Workbench chạy lần lượt các file:

```text
user-management/database/init.sql
user-management/database/transaction_permissions.sql
user-management/database/stored_procedures.sql
user-management/database/stored_procedures_crud.sql
user-management/database/rollback_demo_precheck.sql     # Chỉ SELECT kiểm tra
```

Chạy `rollback_demo_precheck.sql`: cả ba bảng phải là **InnoDB**; quyền `1` tồn tại, quyền `2147483647` không tồn tại; bảng trung gian phải có foreign keys.

Đặt biến môi trường (PowerShell) trong phiên khởi chạy Tomcat:

```powershell
$env:DB_URL = "jdbc:mysql://localhost:3306/demo?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh"
$env:DB_USER = "root"
$env:DB_PASSWORD = "YOUR_LOCAL_MYSQL_PASSWORD"
```

Từ thư mục `user-management`, chạy:

```powershell
mvn clean package
```

Deploy `target/user-management.war` vào `webapps` của Tomcat 10.1 và truy cập:

**http://localhost:8080/user-management/users?action=test-user-rollback**

Bấm nút **Chạy thử: INSERT → lỗi FK → ROLLBACK**. Website sẽ cho xem email ngẫu nhiên, SQLException và kết quả truy vấn đếm từ kết nối mới. Trên MySQL Workbench, mở `database/verify_user_rollback.sql`, thay chuỗi mẫu trong `SET @test_email` bằng email test vừa hiển thị, chạy script.

```sql
USE demo;
SET @test_email = 'tx-rollback-PASTE_UUID_FROM_WEB@example.invalid';
SELECT id, name, email, country FROM users WHERE email = @test_email;
SELECT up.user_id, up.permission_id
FROM user_permission AS up
JOIN users AS u ON u.id = up.user_id
WHERE u.email = @test_email;
```

**Kết quả mong đợi:** 2 câu SELECT đều **0 dòng**; console có lỗi khóa ngoại 1452, nhưng HTTP vẫn hiển thị báo cáo vì đó là lỗi SQL được chủ động thử nghiệm.

Để đối chứng, vào `http://localhost:8080/user-management/users?action=create` và thêm một User thông thường với quyền Add + View. Chức năng CRUD này vẫn commit hợp lệ. Cần tự xóa User đối chứng nếu không muốn giữ trong MySQL demo.

## 4. Kiểm tra, giới hạn và lời giải thích ACID

- **Atomicity:** tất cả INSERT User và permission là một transaction. Hỏng một bước → `rollback()` bỏ tất cả thay đổi chưa commit.
- **Consistency:** khóa ngoại giúp từ chối quyền không có thật.
- **Isolation:** các giao dịch khác không nhìn thấy dữ liệu chưa commit ở mức cô lập mặc định của InnoDB; mức độ quan sát tùy isolation level.
- **Durability:** sau `commit()`, MySQL lưu dữ liệu theo cơ chế bền vững của InnoDB.

Dù transaction rollback, **giá trị AUTO_INCREMENT có thể tăng**; điều đó không có nghĩa User đã được lưu.

### Kiểm thử mô phỏng (không cần DB)

Tại thư mục `user-management`, chạy:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_mock_tests.ps1
```

Các file mock xác minh việc bật transaction, gọi rollback đúng một lần, không commit, ràng buộc mã lỗi và kiểm tra số dòng bằng kết nối khác; đồng thời chạy lại các test của bài trước. Java được biên dịch với `javac --release 17`.

**Phân biệt:** Kết quả mock không chứng minh MySQL thực tế đã rollback. Bắt buộc chạy SQL kiểm tra trong MySQL Workbench để hoàn thành bước quan sát dữ liệu theo đề.

## 5. Cập nhật GitHub và nộp bài

Sau khi giải nén thư mục `UserManagement_JDBC_Rollback_Experiment` vào repository `JSP-homework`, chạy trong thư mục gốc repo:

```powershell
git add UserManagement_JDBC_Rollback_Experiment/
git commit -m "feat: test SQL error and JDBC user transaction rollback"
git push origin main
```

Đường dẫn dự kiến sau khi push:

`https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/UserManagement_JDBC_Rollback_Experiment/README.md`

> Đường dẫn trên chỉ truy cập được sau khi bạn đã đưa thư mục lên repo; file ZIP và README ở đây chưa được push tự động.
