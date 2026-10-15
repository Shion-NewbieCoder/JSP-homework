# JDBC Without Transaction — Bài thực hành Auto-Commit và lỗi UPDATE

Dự án Maven Webapp kế thừa **User Management JDBC Transaction**: Java 17, JSP/JSTL (Jakarta), Servlet, MySQL Connector/J, Tomcat 10.1+. Vẫn giữ chức năng CRUD User, tìm kiếm theo country, sắp xếp theo name, Stored Procedures, gán permission bằng Transaction.

## Mục tiêu và điều cần quan sát

Bài này **cố ý viết sai một dòng SQL parameter**, không phải một bug chưa được phát hiện. Chạy GET `?action=test-without-tran` sẽ:

1. **Xóa và tạo lại duy nhất bảng `Employee`** thuộc schema `demo` để làm sạch dữ liệu thí nghiệm.
2. Để JDBC `autoCommit=true` (mặc định), INSERT `Quynh` (salary 10) và `Ngan` (salary 20).
3. UPDATE `Employee SET salary=? WHERE name=?` nhưng **không gán tham số 1**, thay vào đó gán tham số 2 hai lần. JDBC ném `SQLException` (thường là *No value specified for parameter 1*).
4. Hai bản ghi `Employee` đã chèn **vẫn còn**, vì trước đó mỗi INSERT đã tự commit; Quynh không được cập nhật thành 999.99.

> **CẢNH BÁO:** Đường dẫn thử nghiệm có tính phá hủy dữ liệu. Nó `DROP TABLE Employee` mỗi lần gọi. Chỉ chạy trên cơ sở dữ liệu **demo ở máy cá nhân**. Không triển khai endpoint GET thay đổi dữ liệu trên ứng dụng công khai hoặc môi trường production. Không có bảng `users`/`permission`/`user_permission` nào bị DROP bởi đoạn demo mới.

## Cấu trúc dự án

```text
UserManagement_JDBC_WithoutTransaction/
├── README.md                     <- file tổng hợp để nộp CodeGym
└── user-management/
    ├── pom.xml                    <- WAR: Java 17, JSP/Servlet/JSTL, MySQL JDBC
    ├── database/
    │   ├── init.sql               <- users + dữ liệu mẫu
    │   ├── stored_procedures.sql   <- get_user_by_id, insert_user
    │   ├── transaction_permissions.sql
    │   ├── employee_no_transaction.sql <- TẠO và KIỂM TRA Employee
    │   └── ...
    ├── src/main/java/com/codegym/
    │   ├── model/User.java
    │   ├── dao/IUserDAO.java
    │   ├── dao/UserDAO.java         <- phương thức insertUpdateWithoutTransaction
    │   └── controller/UserServlet.java <- GET action=test-without-tran
    ├── src/main/webapp/
    │   ├── user/without-transaction.jsp <- trang hiển thị kết quả lỗi
    │   ├── user/list.jsp, create.jsp, edit.jsp, delete.jsp
    │   ├── assets/styles.css
    │   └── WEB-INF/web.xml
    └── tests/NoTransactionMockTest.java <- kiểm tra không auto-rollback
```

## Hướng dẫn chạy thực tế

**Cần:** JDK 17+, Maven, MySQL 8+, Tomcat 10.1+. Chạy SQL trong MySQL Workbench (KHÔNG dùng Maven để chạy SQL):

- Nếu **chưa có** DB demo cũ: chạy `database/init.sql`, rồi `database/stored_procedures.sql`, `database/transaction_permissions.sql`, cuối cùng `database/employee_no_transaction.sql`.
- Nếu đang **kế thừa từ bài Transaction trước**: chỉ cần chạy thêm `database/employee_no_transaction.sql` (các bảng cũ giữ nguyên).

Cấu hình `DB_URL`, `DB_USER`, `DB_PASSWORD` trong môi trường chạy Tomcat (không lưu mật khẩu trong source). Mặc định JDBC URL là `jdbc:mysql://localhost:3306/demo?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh`, user `root`, password rỗng nếu không cấu hình.

Từ thư mục `user-management`:

```powershell
mvn clean package
```

Copy `target/user-management.war` vào `webapps/` của Tomcat 10.1 rồi khởi động/redeploy. Trang User cũ: `http://localhost:8080/user-management/users`.

**Gọi chính xác URL demo mới một lần**:

```text
http://localhost:8080/user-management/users?action=test-without-tran
```

Servlet in stack trace lỗi SQL ra console và hiển thị trang kết quả có hướng dẫn kiểm tra. Chạy tiếp trên Workbench:

```sql
USE demo;
SELECT id, name, salary, created_Date
FROM Employee
ORDER BY id;
```

**Dự kiến, sau khi chạy thành công 2 INSERT và gặp lỗi UPDATE:**

| id | name | salary |
|---|---|---|
| 1 | Quynh | 10.00 |
| 2 | Ngan | 20.00 |

Dấu hiệu cần nhớ: dữ liệu bị lưu một nửa vì không có Transaction. Kết quả chỉ là dự kiến; nếu lỗi kết nối, quyền MySQL hoặc SQL DDL, phải sửa môi trường rồi kiểm tra lại chứ không tự khẳng định hai INSERT đã tồn tại.

## Điểm thay đổi trong mã Java

### 1. `IUserDAO.java`

```java
/** Demo JDBC cố tình tạo lỗi UPDATE, chạy riêng trên demo.Employee. */
void insertUpdateWithoutTransaction() throws SQLException;
```

### 2. `UserDAO.java` — không bọc INSERT/UPDATE vào transaction

```java
@Override
public void insertUpdateWithoutTransaction() throws SQLException {
    try (Connection con = getConnection()) {
        if (!con.getAutoCommit()) {
            throw new SQLException("Demo yêu cầu JDBC autoCommit=true");
        }

        try (Statement ddl = con.createStatement()) {
            ddl.execute(SQL_EMPLOYEE_DROP);
            ddl.execute(SQL_EMPLOYEE_CREATE);
        }

        try (PreparedStatement psInsert = con.prepareStatement(SQL_EMPLOYEE_INSERT);
             PreparedStatement psUpdate = con.prepareStatement(SQL_EMPLOYEE_UPDATE)) {
            psInsert.setString(1, "Quynh");
            psInsert.setBigDecimal(2, new BigDecimal("10"));
            psInsert.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
            psInsert.executeUpdate();

            psInsert.setString(1, "Ngan");
            psInsert.setBigDecimal(2, new BigDecimal("20"));
            psInsert.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
            psInsert.executeUpdate();

            // LỖI ĐƯỢC CỐ Ý GIỮ LẠI để học JDBC auto-commit:
            psUpdate.setBigDecimal(2, new BigDecimal("999.99"));
            psUpdate.setString(2, "Quynh");
            psUpdate.executeUpdate(); // parameter 1 chưa được set
        }
    }
}
```

Các hằng SQL thực tế trong DAO: `DROP TABLE IF EXISTS Employee`, `CREATE TABLE Employee (...)`, `INSERT INTO Employee (name, salary, created_Date) VALUES (?, ?, ?)`, `UPDATE Employee SET salary=? WHERE name=?`. Kiểu salary là `DECIMAL(15,2)` để minh họa cả giá trị thập phân. **Dùng `BigDecimal("999.99")` thay vì `BigDecimal(999.99)` để tránh sai số nhị phân.**

### 3. `UserServlet.java` — thêm action không ảnh hưởng CRUD

```java
// Trong doGet:
} else if ("test-without-tran".equals(action)) {
    testWithoutTran(req, resp);
} else if ("create".equals(action)) {

// Phương thức mới:
private void testWithoutTran(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {
    try {
        dao.insertUpdateWithoutTransaction();
        req.setAttribute("unexpectedSuccess", true);
    } catch (SQLException ex) {
        ex.printStackTrace(System.err);
        req.setAttribute("demoError", ex.getMessage());
    }
    forward(req, resp, "/user/without-transaction.jsp");
}
```

Trang `without-transaction.jsp` sử dụng `<c:out>` để hiển thị thông báo SQL một cách an toàn và chứa lệnh SELECT kiểm chứng.

## Kiểm thử và giới hạn

Bộ mock tests chỉ mô phỏng API JDBC, **không chứng minh InnoDB thực sự commit trên một MySQL server**. Các bài kiểm tra đã chạy ở môi trường tạo bài: `NoTransactionMockTest` (14/14 assertions), `TxMockTest` kế thừa từ bài trước (44/44 assertions) và `ServletTransactionMockTest` cập nhật action (17/17 assertions). Câu lệnh chạy lại từ thư mục dự án bằng Git Bash/Linux:

```bash
mkdir -p tests/build
javac --release 17 -d tests/build $(find tests/stubs -name '*.java') \
  $(find src/main/java -name '*.java') \
  tests/NoTransactionMockTest.java tests/TxMockTest.java tests/ServletTransactionMockTest.java
java -cp tests/build NoTransactionMockTest
java -cp tests/build TxMockTest
java -cp tests/build com.codegym.controller.ServletTransactionMockTest
```

Chưa thực hiện `mvn clean package` hoặc chạy Tomcat + MySQL thật trong môi trường tạo bài (không có Maven tại đây). Kiểm thử tích hợp là bước cần làm trên máy người học.

## Vấn đáp: Vì sao có rác dữ liệu?

`autoCommit=true` nghĩa là từng câu lệnh SQL được commit độc lập. Hai `INSERT` đã thành công thì bản ghi bền vững, ngay cả khi câu `UPDATE` sau đó thất bại. Với JDBC transaction, ta sẽ gọi `setAutoCommit(false)`, dùng cùng một `Connection` để thực thi cả ba bước, rồi `commit()` khi tất cả thành công hoặc `rollback()` nếu có lỗi. Bảng InnoDB hỗ trợ transaction. **MySQL DDL `DROP/CREATE TABLE` gây implicit commit**, vì vậy thao tác reset bảng chỉ phục vụ thí nghiệm và không thuộc quy trình transaction production.

*Repo học tập CodeGym. Đây không phải ứng dụng quản lý người dùng đã được bảo mật để chạy công khai.*
