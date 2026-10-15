# UserManagement_JDBC — CodeGym

Bài thực hành: **Luyện tập sử dụng JDBC kết nối cơ sở dữ liệu trong ứng dụng Java Web**.

**Phạm vi bàn giao:** Bộ khung MVC theo yêu cầu bắt buộc của Bước 2. Chưa viết các chức năng CRUD; chúng là nội dung học viên sẽ thực hiện. Xem [hướng dẫn dự án](user-management/README.md) để triển khai tiếp.

## Đã có sẵn

- Cấu hình Maven WAR Java 17 / Jakarta Servlet 6.0 / JSTL 3.0 / MySQL Connector/J 8.3.0.
- `User` model (4 thuộc tính), `IUserDAO` interface với 5 chữ ký CRUD, class `UserDAO` để trống có hướng dẫn TODO.
- `UserServlet` ánh xạ `/users` nhưng chưa implement `doGet/doPost`.
- Bốn file JSP trống đúng quy định: `list.jsp`, `create.jsp`, `edit.jsp`, `delete.jsp`.
- `web.xml`, `.gitignore` và script `database/init.sql` tạo bảng MySQL `demo.users` cùng 2 bản ghi mẫu.

## Mô hình MVC

```text
[Trình duyệt] → UserServlet (Controller) → UserDAO (DAO/JDBC) → MySQL
                  ↓
             JSP (View)
                  ↕
             User (Model)
```

## Chạy khi hoàn thành logic

Mở `user-management/`, chạy `mvn clean package`, triển khai `target/user-management.war` lên Tomcat 10.1+, rồi truy cập `http://localhost:8080/user-management/users`.

> **Lưu ý:** Chưa thể demo CRUD từ bản nộp khung. Nếu giảng viên yêu cầu ứng dụng hoạt động đầy đủ, bạn phải hoàn thiện các lớp Java/JSP theo hướng dẫn bài học trước khi nộp. Không đẩy thông tin đăng nhập MySQL lên GitHub.

## Mã cấu hình Maven

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.codegym</groupId>
    <artifactId>user-management</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <name>User Management MVC + JDBC (scaffold)</name>
    <properties>
        <maven.compiler.release>17</maven.compiler.release>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    <dependencies>
        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>6.0.0</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>jakarta.servlet.jsp</groupId>
            <artifactId>jakarta.servlet.jsp-api</artifactId>
            <version>3.1.1</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>jakarta.servlet.jsp.jstl</groupId>
            <artifactId>jakarta.servlet.jsp.jstl-api</artifactId>
            <version>3.0.0</version>
        </dependency>
        <dependency>
            <groupId>org.glassfish.web</groupId>
            <artifactId>jakarta.servlet.jsp.jstl</artifactId>
            <version>3.0.1</version>
        </dependency>
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <version>8.3.0</version>
        </dependency>
    </dependencies>
    <build>
        <finalName>user-management</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.13.0</version>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.4.0</version>
            </plugin>
        </plugins>
    </build>
</project>
```

## Mã giao diện / controller (khung)

`UserServlet.java`:

```java
package com.codegym.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;

/**
 * Controller MVC: ánh xạ /users.
 * TODO: Bổ sung doGet/doPost, dispatch action và gọi DAO.
 * Cố ý chưa xử lý HTTP do đề yêu cầu chỉ tạo khung sườn.
 */
@WebServlet(name = "UserServlet", urlPatterns = "/users")
public class UserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
}
```

`IUserDAO.java`:

```java
package com.codegym.dao;

import com.codegym.model.User;
import java.sql.SQLException;
import java.util.List;

/**
 * Hợp đồng JDBC CRUD cho người dùng.
 * Chỉ khai báo chữ ký, chưa có xử lý nghiệp vụ.
 */
public interface IUserDAO {
    void insertUser(User user) throws SQLException;
    User selectUser(int id) throws SQLException;
    List<User> selectAllUsers() throws SQLException;
    boolean deleteUser(int id) throws SQLException;
    boolean updateUser(User user) throws SQLException;
}
```

## Tạo database

```sql
-- Chạy trong MySQL Workbench; script phục vụ bài thực hành.
-- Không xóa hoặc ghi đè database demo sẵn có.
CREATE DATABASE IF NOT EXISTS demo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE demo;

CREATE TABLE IF NOT EXISTS users (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(220) NOT NULL,
    country VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Giữ hai dữ liệu mẫu của đề; tránh nhân đôi khi chạy script lần thứ hai.
INSERT INTO users (name, email, country)
SELECT 'Minh', 'minh@codegym.vn', 'Viet Nam'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'minh@codegym.vn');

INSERT INTO users (name, email, country)
SELECT 'Kante', 'kante@che.uk', 'Kenia'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'kante@che.uk');

SELECT id, name, email, country FROM users ORDER BY id;
```
