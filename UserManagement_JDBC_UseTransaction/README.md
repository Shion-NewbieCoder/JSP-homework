# JDBC Transaction — Commit & Rollback (User Management MVC)

**Bài nộp thực hành**: hai INSERT vào `demo.Employee` và một UPDATE phải cùng thành công hoặc cùng thất bại. Dự án kế thừa đầy đủ User Management (CRUD, tìm kiếm country, sắp xếp name, Stored Procedures, gán quyền bằng transaction) và bài không dùng Transaction.

## So sánh và audit mã mẫu

| | Không dùng Transaction | Có Transaction: fail | Có Transaction: success |
|---|---|---|---|
| JDBC auto-commit | true | **false** | **false** |
| INSERT Quynh, Ngan | hai commit riêng | nằm trong giao dịch chưa commit | nằm trong giao dịch chưa commit |
| UPDATE Quynh | thiếu tham số #1 → lỗi | thiếu tham số #1 → lỗi | gán salary parameter #1 đúng |
| Lệnh cuối | SQLException, không rollback | **rollback() tường minh** | **commit()** |
| Bảng Employee sau khi khởi đầu từ rỗng | 2 dòng: 10.00, 20.00 | **0 dòng** | 2 dòng: **999.99**, **20.00** |

**Hai sửa đổi so với mã gợi ý của bài:** (1) `DROP/CREATE TABLE` là DDL MySQL gây implicit commit nên không được xem là thao tác có thể rollback. Việc khởi tạo bảng và làm rỗng bảng nằm ở các script Workbench riêng, thực hiện trước transaction. (2) Dùng `connection.rollback()` rõ ràng trong `catch`, không dựa vào hành vi khi `Connection.close()` bởi driver/pool có thể khác nhau. `SQLException` vẫn truyền lên controller và được hiển thị an toàn.

## Cấu trúc nộp bài

```text
UserManagement_JDBC_UseTransaction/
├── README.md
└── user-management/
    ├── pom.xml
    ├── src/main/java/com/codegym/
    │   ├── model/User.java
    │   ├── dao/IUserDAO.java
    │   ├── dao/UserDAO.java
    │   └── controller/UserServlet.java
    ├── src/main/webapp/user/
    │   ├── use-transaction.jsp
    │   ├── without-transaction.jsp
    │   └── list.jsp, create.jsp, edit.jsp, delete.jsp
    ├── database/
    │   ├── employee_transaction.sql
    │   ├── reset_employee_demo.sql
    │   ├── verify_employee_transaction.sql
    │   └── ... (các script User Management cũ)
    └── tests/
        ├── UseTransactionMockTest.java
        ├── ServletUseTransactionMockTest.java
        └── ... (kiểm thử bài trước)
```

## Cách chạy MySQL + Tomcat

**Chỉ trên máy thực hành, không dùng trên production.** Cần Java 17+, Maven, MySQL 8+ với bảng `demo.Employee` dùng InnoDB, Tomcat 10.1+. Nếu mới tạo ứng dụng từ đầu, chạy `database/init.sql`, `stored_procedures.sql`, `transaction_permissions.sql` (nếu muốn dùng các chức năng cũ); sau đó chạy `database/employee_transaction.sql`.

Cấu hình biến môi trường khi Tomcat khởi động: `DB_URL` (mặc định `jdbc:mysql://localhost:3306/demo?...`), `DB_USER` (mặc định `root`), `DB_PASSWORD`. Không lưu password trong source.

Ở thư mục `user-management/`:

```powershell
mvn clean package
```

Triển khai `target/user-management.war` vào Tomcat và mở `http://localhost:8080/user-management/users`.

### Lần 1: chứng minh rollback

1. Mở MySQL Workbench, chạy `database/reset_employee_demo.sql` và xác nhận `baseline_rows=0`.
2. Gọi `http://localhost:8080/user-management/users?action=test-use-tran` (tương đương `&mode=fail`).
3. Java thiếu parameter #1 trong `UPDATE Employee SET salary=? WHERE name=?`, ném `SQLException`. Code trong DAO **gọi rollback()**.
4. Chạy `database/verify_employee_transaction.sql`: **bảng vẫn 0 dòng**.

### Lần 2: chứng minh commit

1. **Chạy lại** `database/reset_employee_demo.sql` và xác nhận `baseline_rows=0`.
2. Gọi `http://localhost:8080/user-management/users?action=test-use-tran&mode=success`.
3. Lúc này code có `psUpdate.setBigDecimal(1, new BigDecimal("999.99"))` đúng parameter; 2 INSERT và UPDATE xong mới gọi commit.
4. Chạy `database/verify_employee_transaction.sql`: **2 dòng**: Quynh salary **999.99**, Ngan **20.00**.

Chế độ `mode=success` cho kết quả giống như học viên sửa index `2` thành `1` rồi biên dịch lại, nhưng không phải sửa mã qua lại nhiều lần. Nếu muốn thực hành sửa code, hãy chuyển đoạn `if (failUpdate)` trong `UserDAO.java` để tự quan sát.

### Đối chiếu bài trước

Bài **không dùng Transaction** ở `?action=test-without-tran` sẽ reset bảng Employee bằng DROP/CREATE rồi tự commit từng INSERT, nên cuối cùng vẫn còn 2 dòng mặc dù UPDATE lỗi. Đây là hành vi **cố ý để học**. Với bài hiện tại không DROP/CREATE bảng trong Transaction và có rollback tường minh, 2 INSERT sẽ biến mất khi lỗi.

**Cảnh báo:** Endpoint thực hành dùng GET để tác động dữ liệu; chỉ chạy LOCAL. Không nhấn liên tiếp, không đưa lên hosting public. Chỉ reset `demo.Employee` khi chắc chắn đây là dữ liệu thử nghiệm.

## Kiểm thử và giới hạn

Bộ kiểm thử `UseTransactionMockTest` dùng JDBC dynamic proxy để ghi nhận các thao tác `setAutoCommit(false)`, INSERT, UPDATE, commit, rollback và mô phỏng trạng thái ban đầu của bảng. `ServletUseTransactionMockTest` kiểm tra route `test-use-tran` và phân biệt fail/success. Các test này **không thay thế kiểm chứng với MySQL thật**. `mvn clean package` và Tomcat vẫn cần chạy trên máy học viên; môi trường chuẩn bị mã nguồn chưa có Maven.

### Nơi tìm mã nguồn chính

- [`IUserDAO.java`](user-management/src/main/java/com/codegym/dao/IUserDAO.java) — hai chữ ký method có/không tham số.
- [`UserDAO.java`](user-management/src/main/java/com/codegym/dao/UserDAO.java) — transaction + rollback tường minh.
- [`UserServlet.java`](user-management/src/main/java/com/codegym/controller/UserServlet.java) — route `test-use-tran`.
- [`use-transaction.jsp`](user-management/src/main/webapp/user/use-transaction.jsp) — kết quả và SQL để xác minh.
- [`employee_transaction.sql`](user-management/database/employee_transaction.sql) và [`verify_employee_transaction.sql`](user-management/database/verify_employee_transaction.sql).

## Mã trọng tâm DAO (rút gọn)

```java
con.setAutoCommit(false);
try {
    // Hai INSERT Quynh và Ngan trên CÙNG Connection...
    // fail: psUpdate.setBigDecimal(2, new BigDecimal("999.99"));
    // success: psUpdate.setBigDecimal(1, new BigDecimal("999.99"));
    psUpdate.setString(2, "Quynh");
    psUpdate.executeUpdate();
    con.commit();
} catch (SQLException | RuntimeException ex) {
    try { con.rollback(); } catch (SQLException rollbackEx) { ex.addSuppressed(rollbackEx); }
    throw ex;
}
```

Bản mã hoàn chỉnh nằm trong source links phía trên; báo cáo không tuyên bố đã chạy MySQL thật hay đã push GitHub.

### Chạy lại toàn bộ kiểm thử Java trên Windows

Mở PowerShell trong thư mục `user-management` và chạy `powershell -ExecutionPolicy Bypass -File tests/run_mock_tests.ps1` (yêu cầu JDK 17+). Bộ test ghi nhận luồng JDBC qua mock; chỉ chạy MySQL Workbench + Tomcat thật mới chứng minh được hành vi cơ sở dữ liệu InnoDB.
