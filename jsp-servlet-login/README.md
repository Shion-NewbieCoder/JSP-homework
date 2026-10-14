# JSP Servlet Login — Java Web POST/GET (CodeGym)

Dự án Maven Webapp với **JDK 17**, **Jakarta Servlet 6.0**, **JSP 3.1**, **Tomcat 10.1+**.

## Yêu cầu và kết quả

- `/` hiển thị form từ `index.jsp`, gồm `username`, `password` và nút **Login**.
- Form dùng `method="POST"` và `action="login"`.
- `LoginServlet` được ánh xạ bằng `@WebServlet(urlPatterns = {"/login"})`, đọc dữ liệu qua `request.getParameter`.
- **admin / admin** → `Welcome admin to website`.
- Sai bất kỳ trường nào → `Login Error`.
- GET `/login` chuyển về trang form. Mật khẩu không truyền trong URL.
- Đây là bài học minh họa, **không phải hệ thống đăng nhập thật**: thông tin demo được hardcode, không có database hoặc phiên đăng nhập.

## Cấu trúc thư mục

```text
jsp-servlet-login/
├── pom.xml
├── .gitignore
├── README.md
└── src/main/
    ├── java/com/codegym/LoginServlet.java
    └── webapp/
        ├── index.jsp
        ├── css/styles.css
        └── WEB-INF/web.xml
```

## Cách build và chạy

**Yêu cầu:** JDK 17+ (`java -version`), Apache Maven (`mvn -version`), Apache Tomcat **10.1.x** (không dùng Tomcat 9, do package `jakarta.servlet`).

1. Mở Terminal tại thư mục `jsp-servlet-login` chứa `pom.xml`.
2. Chạy:

   ```bash
   mvn clean package
   ```

3. Nếu báo `BUILD SUCCESS`, lấy `target/jsp-servlet-login.war`.
4. Copy WAR vào thư mục `webapps` của Tomcat 10.1 rồi khởi động Tomcat (Windows: `bin/startup.bat`).
5. Mở `http://localhost:8080/jsp-servlet-login/` (nếu Tomcat dùng port 8080).
6. Thử 3 trường hợp:

   | Username | Password | Kết quả |
   |---|---|---|
   | `admin` | `admin` | `Welcome admin to website` |
   | `admin` | `wrong` | `Login Error` |
   | `wrong` | `admin` | `Login Error` |

**Lưu ý:** Không mở trực tiếp `index.jsp` như file HTML. JSP cần Tomcat xử lý trên server. Nếu đổi context path của WAR thì URL sẽ thay đổi tương ứng.

## Tại sao dùng POST thay vì GET?

`GET` mang tham số qua URL/query string, không nên dùng để gửi mật khẩu. Form sử dụng `POST` để đặt username/password vào request body, rồi `doPost()` nhận dữ liệu. **POST không mã hóa mật khẩu:** trong ứng dụng thật cần HTTPS, mật khẩu băm, session và CSRF protection.

## Đọc mã nhanh / một link GitHub

README này nhúng **toàn bộ nội dung cốt lõi** để hệ thống chấm hoặc người xem có thể đọc mà không cần mở nhiều link. Các file thực thi nằm trong cây thư mục bên trên.

### `pom.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.codegym</groupId>
    <artifactId>jsp-servlet-login</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <name>JSP Servlet Login</name>

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
    </dependencies>

    <build>
        <finalName>jsp-servlet-login</finalName>
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

### `index.jsp`

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>System Login | JSP &amp; Servlet</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <main class="login-shell">
        <div class="login-card">
            <div class="brand-icon" aria-hidden="true">J</div>
            <p class="eyebrow">CODEGYM · JAVA WEB</p>
            <h1>System Login</h1>
            <p class="description">Đăng nhập để kiểm tra luồng gửi form từ JSP sang Servlet.</p>

            <%-- Form POST: 'login' duoc anh xa toi @WebServlet("/login") --%>
            <form action="login" method="POST">
                <label for="username">Tên đăng nhập</label>
                <input id="username" name="username" type="text"
                       placeholder="Enter username" autocomplete="username" required autofocus>

                <label for="password">Mật khẩu</label>
                <input id="password" name="password" type="password"
                       placeholder="Enter password" autocomplete="current-password" required>

                <button type="submit">Login <span aria-hidden="true">→</span></button>
            </form>
            <p class="hint">Tài khoản demo: <code>admin</code> / <code>admin</code></p>
        </div>
        <p class="footer-note">JSP Form + POST Servlet · Tomcat 10.1+ · Java 17</p>
    </main>
</body>
</html>

```

### `LoginServlet.java`

```java
package com.codegym;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Login minh hoa JSP/Servlet - tai khoan co dinh admin/admin theo de bai.
 * KHONG dung mau hard-coded password nay cho ung dung that.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        boolean validCredentials = "admin".equals(username) && "admin".equals(password);

        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html lang='vi'>");
            out.println("<head>");
            out.println("<meta charset='UTF-8'>");
            out.println("<meta name='viewport' content='width=device-width, initial-scale=1'>");
            out.println("<title>Login Result</title>");
            out.println("<link rel='stylesheet' href='css/styles.css'>");
            out.println("</head>");
            out.println("<body><main class='login-shell'>");
            out.println("<section class='login-card result-card'>");
            out.println("<div class='brand-icon' aria-hidden='true'>J</div>");
            if (validCredentials) {
                out.println("<div class='result-badge success'>Đăng nhập thành công</div>");
                out.println("<h1 class='result-heading success-text'>Welcome admin to website</h1>");
                out.println("<p class='description'>Bạn đã gửi đúng username và password bằng HTTP POST.</p>");
            } else {
                out.println("<div class='result-badge error'>Đăng nhập thất bại</div>");
                out.println("<h1 class='result-heading error-text'>Login Error</h1>");
                out.println("<p class='description'>Tên đăng nhập hoặc mật khẩu không đúng.</p>");
            }
            out.println("<a class='back-link' href='index.jsp'>← Quay lại trang đăng nhập</a>");
            out.println("</section></main></body></html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Truy cap /login bang GET chi quay lai form; khong nhan mat khau tren URL.
        response.sendRedirect(request.getContextPath() + "/");
    }
}

```

### `web.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">
    <display-name>JSP Servlet Login</display-name>
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
</web-app>

```

### `styles.css`

```css
/* JSP/Servlet login demo - giao dien don gian, co responsive */
:root {
    color-scheme: light;
    --ink: #17233e;
    --accent: #243c83;
    --muted: #6c7890;
    --border: #dfe4ec;
}

* { box-sizing: border-box; }
html, body { min-height: 100%; margin: 0; }
body {
    background: radial-gradient(circle at 12% 8%, #e1eafd, transparent 36%),
                radial-gradient(circle at 94% 86%, #f2e9ff, transparent 36%),
                #f6f8fc;
    font-family: Arial, Helvetica, sans-serif;
    color: var(--ink);
}
.login-shell {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 22px;
    padding: 32px 16px;
}
.login-card {
    width: 100%;
    max-width: 410px;
    background: #fff;
    border: 1px solid #ebeff6;
    border-radius: 18px;
    box-shadow: 0 20px 50px rgba(28, 45, 89, .10);
    padding: 36px;
}
.brand-icon {
    width: 52px;
    height: 52px;
    display: grid;
    place-items: center;
    margin-bottom: 18px;
    border-radius: 14px;
    background: var(--accent);
    color: white;
    font-size: 31px;
    font-weight: bold;
}
.eyebrow { margin: 0 0 8px; color: var(--accent); font-size: 11px; font-weight: bold; letter-spacing: 1.8px; }
h1 { margin: 0 0 10px; font-size: 30px; line-height: 1.2; }
.description { margin: 0 0 26px; color: var(--muted); line-height: 1.65; font-size: 14px; }
form { display: flex; flex-direction: column; }
label { font-size: 13px; font-weight: bold; margin: 0 0 8px; }
input {
    height: 44px;
    border: 1px solid var(--border);
    border-radius: 9px;
    padding: 0 13px;
    margin: 0 0 20px;
    font: inherit;
    font-size: 14px;
    background: #fff;
    width: 100%;
}
input:focus { outline: 2px solid #c5d5ff; border-color: var(--accent); }
button, .back-link {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    min-height: 46px;
    width: 100%;
    border: none;
    border-radius: 9px;
    padding: 12px 16px;
    background: var(--accent);
    color: white;
    font: inherit;
    font-size: 15px;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    transition: background .15s;
}
button:hover, .back-link:hover { background: #142763; }
.hint { margin: 22px 0 0; padding-top: 18px; border-top: 1px solid var(--border); color: var(--muted); font-size: 12px; text-align: center; }
.hint code { color: var(--ink); background: #f0f3f9; padding: 3px 5px; border-radius: 4px; }
.footer-note { margin: 0; color: #8792a7; font-size: 12px; text-align: center; }
.result-card { text-align: center; }
.result-card .brand-icon { margin: 0 auto 16px; }
.result-card .description { margin-bottom: 22px; }
.result-heading { font-size: 26px; overflow-wrap: anywhere; }
.result-badge { display: inline-block; padding: 7px 13px; margin: 0 0 16px; border-radius: 999px; font-size: 12px; font-weight: bold; }
.result-badge.success { background: #dff6e9; color: #176a42; }
.result-badge.error { background: #ffe7e7; color: #a02b2b; }
.success-text { color: #176a42; }
.error-text { color: #c23030; }
@media (max-width: 440px) {
    .login-card { padding: 26px 22px; border-radius: 15px; }
    h1 { font-size: 26px; }
}

```

