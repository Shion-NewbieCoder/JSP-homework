# JSP/Servlet Demo — Thời gian máy chủ (CodeGym)

Dự án Java Web đầu tiên: hiển thị **thời gian hiện tại của máy chủ** bằng JSP, kèm đường dẫn `/hello` tới `HelloServlet` (Jakarta Servlet). Đây là thời gian máy chạy Tomcat; **không phải đồng hồ của trình duyệt**. Refresh trang để cập nhật.

## Yêu cầu và công nghệ

- JDK **17 trở lên**; Apache Maven 3.8+; Apache Tomcat **10.1.x** (Servlet 6.0 / JSP 3.1).
- `groupId=com.codegym`, `artifactId=jsp-servlet-demo`, đóng gói `war`.
- **Quan trọng:** Tomcat 10+ dùng `jakarta.servlet.*` thay cho `javax.servlet.*`. Đừng deploy lên Tomcat 9.
- Không cần database và không cần tải thư viện JavaScript hay CSS bên ngoài.

## Cấu trúc thư mục

```text
jsp-servlet-demo/
├── pom.xml
├── .gitignore
├── README.md
└── src/main/
    ├── java/com/codegym/HelloServlet.java
    └── webapp/
        ├── index.jsp
        ├── assets/style.css
        └── WEB-INF/web.xml
```

## Chạy trên Windows / VS Code / IntelliJ / Antigravity

1. Cài JDK 17+ và Apache Maven; cài và giải nén **Tomcat 10.1**. Kiểm tra `java -version`, `mvn -version` trong terminal. Phải bảo đảm môi trường Maven dùng Java 17+.
2. Giải nén `jsp-servlet-demo/` ở bất kỳ vị trí nào trên máy (ví dụ `C:\Workspace\jsp-servlet-demo`). Mở Terminal **tại thư mục có `pom.xml`**.
3. Biên dịch: `mvn clean package`. Khi thấy `BUILD SUCCESS`, WAR ở `target/jsp-servlet-demo.war`.
4. Đưa WAR vào `webapps` của Tomcat 10.1, chẳng hạn chạy trong PowerShell:
   ```powershell
   Copy-Item .\target\jsp-servlet-demo.war "C:\Tomcat10\webapps\jsp-servlet-demo.war"
   & "C:\Tomcat10\bin\startup.bat"
   ```
   **Đổi `C:\Tomcat10` thành thư mục Tomcat thực tế**. Nếu dùng IDE Server connector, có thể chọn Add Deployment → WAR thay bước copy. Không cần chạy lệnh khởi động lần nữa nếu Tomcat đã chạy.
5. Truy cập:
   - JSP: http://localhost:8080/jsp-servlet-demo/
   - Servlet: http://localhost:8080/jsp-servlet-demo/hello
6. Tải lại trang để thấy thời gian máy chủ cập nhật. Có thể đổi múi giờ của Tomcat nếu muốn, nhưng không nên ép mặc định thành giờ Việt Nam khi kiểm thử trên máy chủ nước ngoài.

> **Lưu ý:** Không mở trực tiếp `index.jsp` bằng `file://` hoặc extension Live Server: JSP cần được Tomcat dịch và chạy phía server. Mở URL `localhost:8080/...` như trên.

## Giải thích kỹ thuật

- `index.jsp` dùng `ZonedDateTime.now()` và `DateTimeFormatter` tại thời điểm xử lý request, thể hiện nội dung động của JSP.
- `@WebServlet(urlPatterns = {"/hello"})` ánh xạ Servlet. `web.xml` Jakarta 6.0 khai báo trang mặc định `index.jsp` mà không đăng ký Servlet trùng nhau.
- `pom.xml` khai báo `jakarta.servlet-api:6.0.0` và `jakarta.servlet.jsp-api:3.1.1` với scope `provided` vì Tomcat cung cấp chúng.
- `assets/style.css` tạo giao diện gọn và responsive. Tính năng hiển thị thời gian vẫn do **Java phía server** đảm nhiệm.

## Khắc phục lỗi phổ biến

| Triệu chứng | Cách xử lý |
|---|---|
| `mvn` is not recognized | Cài Maven, đưa thư mục `bin` vào PATH rồi mở terminal mới |
| `invalid target release: 17` | Maven đang dùng JDK cũ, chỉnh `JAVA_HOME` về JDK 17+ |
| `ClassNotFoundException: javax.servlet...` | Dùng sai Tomcat/API; với dự án này dùng Tomcat **10.1** và `jakarta.*` |
| HTTP 404 `/jsp-servlet-demo/hello` | Kiểm tra WAR đã deploy đúng tên, Servlet annotation đã được quét và server đã khởi động |
| Trang JSP in nguyên `<% ... %>` | Đang mở file tĩnh thay vì chạy qua Tomcat |
| Cổng 8080 bị chiếm | Đổi cổng trong `conf/server.xml` hoặc tắt dịch vụ đang dùng 8080 |

## Minh chứng nên chụp khi nộp

Chụp dòng `BUILD SUCCESS`, trang `/jsp-servlet-demo/`, trang `/jsp-servlet-demo/hello`. Đừng đưa thư mục `target/` vào GitHub (đã có `.gitignore`).

## Mã nguồn đầy đủ (để giảng viên đọc ngay trên GitHub)

### `pom.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.codegym</groupId>
    <artifactId>jsp-servlet-demo</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <name>CodeGym JSP/Servlet Demo</name>

    <properties>
        <maven.compiler.release>17</maven.compiler.release>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- Tomcat 10.1+ provides Servlet/JSP at runtime. -->
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
        <finalName>jsp-servlet-demo</finalName>
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

### `src/main/java/com/codegym/HelloServlet.java`

```java
package com.codegym;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/** Displays a simple dynamic HTML page from a Jakarta Servlet. */
@WebServlet(name = "HelloServlet", urlPatterns = {"/hello"})
public class HelloServlet extends HttpServlet {

    private static final DateTimeFormatter TIME_FORMAT =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss z", Locale.forLanguageTag("vi-VN"));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        String currentTime = ZonedDateTime.now().format(TIME_FORMAT);
        String contextPath = request.getContextPath();

        String page = """
                <!DOCTYPE html>
                <html lang="vi">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <title>Hello Servlet | CodeGym</title>
                    <link rel="stylesheet" href="%s/assets/style.css">
                </head>
                <body>
                <main class="page-shell">
                    <section class="card">
                        <div class="eyebrow">JAVA WEB / JAKARTA SERVLET</div>
                        <div class="icon-mark" aria-hidden="true">J</div>
                        <h1>Chào mừng đến với Servlet đầu tiên!</h1>
                        <p class="lead">Nội dung này được tạo bởi
                           <strong>HelloServlet.java</strong> trên Tomcat.</p>
                        <div class="time-panel">
                            <span>Thời gian hiện tại của máy chủ</span>
                            <strong>%s</strong>
                        </div>
                        <p class="hint">Mỗi lần tải lại, Servlet sẽ lấy thời gian mới từ hệ thống máy chủ.</p>
                        <div class="actions">
                            <a class="button button-primary" href="%s/">Về trang JSP</a>
                            <a class="button button-secondary" href="%s/hello">Làm mới thời gian</a>
                        </div>
                    </section>
                </main>
                </body>
                </html>
                """.formatted(contextPath, currentTime, contextPath, contextPath);

        try (PrintWriter out = response.getWriter()) {
            out.print(page);
        }
    }
}
```

### `src/main/webapp/index.jsp`

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.time.ZonedDateTime,java.time.format.DateTimeFormatter,java.util.Locale" %>
<%
    // Server-side time is evaluated when the JSP request is processed by Tomcat.
    ZonedDateTime serverNow = ZonedDateTime.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern(
            "dd/MM/yyyy HH:mm:ss z", Locale.forLanguageTag("vi-VN"));
    String formattedServerTime = serverNow.format(formatter);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Bài thực hành JSP/Servlet: thời gian hiện tại của máy chủ.">
    <title>Trang chủ JSP | CodeGym Java Web</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/style.css">
</head>
<body>
<main class="page-shell">
    <section class="card">
        <div class="eyebrow">BÀI THỰC HÀNH ĐẦU TIÊN · JSP / SERVLET</div>
        <div class="icon-mark" aria-hidden="true">J</div>
        <h1>Chào mừng tới lớp học Java Web!</h1>
        <p class="lead">Trang JSP lấy thời gian thực tế từ <strong>máy chủ Tomcat</strong>, không phải đồng hồ JavaScript của trình duyệt.</p>
        <div class="time-panel" role="status">
            <span>Thời gian hiện tại của máy chủ</span>
            <strong><%= formattedServerTime %></strong>
        </div>
        <p class="hint">Thời gian được cập nhật mỗi khi bạn tải lại trang.</p>
        <div class="actions">
            <a class="button button-primary" href="<%= request.getContextPath() %>/hello">Mở HelloServlet →</a>
            <a class="button button-secondary" href="<%= request.getContextPath() %>/">Làm mới thời gian</a>
        </div>
        <div class="stack-note">Java 17+ <span>·</span> Maven WAR <span>·</span> Jakarta EE <span>·</span> Tomcat 10.1+</div>
    </section>
</main>
</body>
</html>
```

### `src/main/webapp/WEB-INF/web.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">
    <display-name>jsp-servlet-demo</display-name>
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
    <!-- /hello mapping is registered by @WebServlet in HelloServlet.java. -->
</web-app>
```

### `src/main/webapp/assets/style.css`

```css
:root {
    color-scheme: light;
    --ink: #18253d;
    --muted: #607187;
    --brand: #254bb4;
    --bg: #eff4ff;
}
* { box-sizing: border-box; }
html { min-height: 100%; }
body {
    margin: 0;
    min-height: 100vh;
    font-family: Arial, "Helvetica Neue", sans-serif;
    color: var(--ink);
    background: radial-gradient(circle at 12% 15%, #d9e9ff, transparent 39%),
                radial-gradient(circle at 90% 85%, #d6e0fb, transparent 40%), var(--bg);
}
.page-shell { min-height: 100vh; display: grid; place-items: center; padding: 32px 18px; }
.card {
    width: min(100%, 670px);
    padding: clamp(28px, 6vw, 58px);
    border: 1px solid #d6e2f4;
    border-radius: 22px;
    background: #fff;
    box-shadow: 0 20px 55px rgba(34, 70, 144, .1);
    text-align: center;
}
.eyebrow { color: var(--brand); font-size: 11px; font-weight: 700; letter-spacing: .14em; }
.icon-mark {
    width: 56px; height: 56px; margin: 26px auto 22px;
    display: grid; place-items: center;
    border-radius: 16px;
    color: white; font-weight: 900; font-size: 28px;
    background: linear-gradient(135deg, #315cd9, #193481);
    box-shadow: 0 10px 20px rgba(42, 82, 176, .23);
}
h1 { margin: 0 0 14px; font-size: clamp(27px, 4.8vw, 38px); line-height: 1.2; letter-spacing: -.03em; }
.lead { color: var(--muted); font-size: 16px; line-height: 1.7; margin: 0 auto 25px; max-width: 540px; }
.lead strong { color: var(--ink); }
.time-panel { padding: 23px 18px; border: 1px solid #dbe6fb; border-radius: 14px; background: #f2f7ff; }
.time-panel span { color: #516888; display: block; font-size: 13px; margin-bottom: 10px; }
.time-panel strong { color: #2049a6; display: block; font-size: clamp(19px, 4.5vw, 25px); overflow-wrap: anywhere; }
.hint { margin: 16px 0 25px; color: var(--muted); font-size: 13px; }
.actions { display: flex; align-items: center; justify-content: center; flex-wrap: wrap; gap: 11px; }
.button { display: inline-block; min-width: 164px; text-decoration: none; padding: 13px 17px; font-size: 14px; font-weight: 700; border-radius: 9px; transition: transform .15s ease, background .15s ease; }
.button:hover { transform: translateY(-1px); }
.button:focus-visible { outline: 3px solid #90b1ff; outline-offset: 2px; }
.button-primary { background: var(--brand); color: #fff; }
.button-primary:hover { background: #1a378d; }
.button-secondary { color: #25458e; background: #eaf0fc; }
.button-secondary:hover { background: #dbe7ff; }
.stack-note { color: #8b97a8; font-size: 12px; margin-top: 32px; }
.stack-note span { padding: 0 5px; }
@media (max-width: 420px) {
    .card { padding: 30px 19px; }
    .actions .button { width: 100%; }
}
```

