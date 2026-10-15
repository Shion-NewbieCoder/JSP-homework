# User Management — Java Web MVC + JDBC (scaffold)

Dự án thực hành CodeGym: tạo **khung Maven Webapp** theo MVC để chuẩn bị xây dựng quản lý User với JSP/Servlet, MySQL và JDBC. Tương thích **Java 17, Tomcat 10.1+, Jakarta Servlet 6.0, JSTL 3.0**.

> **Quan trọng:** Đây là bản **khung (scaffold), không phải phần mềm CRUD hoàn chỉnh**. Yêu cầu ra lệnh AI Agent tại Bước 2 ghi rõ *chỉ tạo cấu hình hoàn chỉnh và Java/JSP rỗng hoặc khung có Javadoc*, không viết logic CRUD hay HTML/JSTL giao diện. Vì vậy `/users` hiện chưa hiển thị được danh sách và các trang JSP đang rỗng có chủ đích. Phần hướng dẫn sau đó trong đề là mã để học viên tự triển khai.

## Cấu trúc thư mục

```text
user-management/
├── pom.xml
├── .gitignore
├── database/
│   └── init.sql
└── src/main/
    ├── java/com/codegym/
    │   ├── model/User.java
    │   ├── dao/IUserDAO.java
    │   ├── dao/UserDAO.java
    │   └── controller/UserServlet.java
    └── webapp/
        ├── WEB-INF/web.xml
        └── user/
            ├── list.jsp
            ├── create.jsp
            ├── edit.jsp
            └── delete.jsp
```

## Chuẩn bị môi trường

Cài JDK 17+, Maven 3.8+, Tomcat 10.1+, MySQL 8.0+ và một IDE (VS Code/IntelliJ). Kiểm tra bằng `java -version`, `mvn -version`.

Trong MySQL Workbench, chạy lần lượt toàn bộ lệnh từ `database/init.sql` để tạo `demo.users` và thêm 2 dòng mẫu Minh / Kante. Script không xóa dữ liệu và tránh chèn lại hai email mẫu nếu chúng đã có.

Chạy lệnh tại thư mục chứa `pom.xml`:

```powershell
mvn clean package
```

Nếu Maven tải đủ dependency và `BUILD SUCCESS`, tệp `target/user-management.war` sẵn sàng triển khai Tomcat. Sau này, khi tự hoàn thiện servlet và các JSP, truy cập:

```text
http://localhost:8080/user-management/users
```

**Hiện tại endpoint chưa có doGet/doPost: phản hồi 405 là bình thường với scaffold**, không phải chức năng CRUD đã chạy.

## Danh sách việc tự thực hành tiếp theo

1. Bổ sung constructor/getter/setter cho `User`.
2. Cho `UserDAO implements IUserDAO` và viết 5 phương thức JDBC (câu SQL có dấu `?` bằng `PreparedStatement`).
3. Kết nối database `demo` từ cấu hình trên máy, không commit user/password vào GitHub. Có thể dùng biến môi trường `JDBC_URL`, `JDBC_USER`, `JDBC_PASSWORD` khi viết DAO.
4. Bổ sung `doGet`/`doPost` tại `UserServlet`, xử lý các action list/create/edit/delete và các trường hợp ID không tồn tại.
5. Hoàn thiện 4 file JSP và dùng `<%@ taglib prefix="c" uri="jakarta.tags.core" %>` với Tomcat 10.1/JSTL 3.0.
6. Kiểm thử cả 4 tác vụ CRUD trên MySQL, báo lỗi nhập liệu, 404 và truy vấn có tham số chống SQL injection.

## Sơ đồ luồng MVC dự kiến

```text
Browser → UserServlet (/users) → IUserDAO / UserDAO → MySQL demo.users
             ↓                                  
        JSP (list/create/edit/delete)  ← request attributes
```

## Vì sao code còn trống?

**Hai nội dung trong đề dễ gây nhầm:** Phần *lệnh bắt buộc cho AI Agent* yêu cầu chỉ tạo khung. Phần *mã nguồn mẫu ở bước sau* thể hiện triển khai CRUD dành cho học viên. Bộ ZIP này cố ý theo **phần yêu cầu bắt buộc về tạo khung**, không nhận là đã hoàn thiện CRUD.

## Chú ý về tài liệu SQL

`INT(3)` trong script cũ được thay bằng `INT`: số `(3)` trước đây là display width, không giới hạn ID còn 3 chữ số; cú pháp mới tương thích MySQL 8. Script dùng `CREATE TABLE IF NOT EXISTS` nên nếu bảng `users` cũ đã tồn tại, cần kiểm tra cấu trúc trước khi chạy tiếp.

## Trạng thái kiểm tra

Đã kiểm tra XML, thư mục, source Java 17 bằng `javac` (Servlet được kiểm tra bằng API giả lập). **Chưa build Maven thực tế, chưa kết nối MySQL, chưa chạy WAR trên Tomcat**. Không ghi nhận kết quả CRUD vì chưa triển khai logic.
