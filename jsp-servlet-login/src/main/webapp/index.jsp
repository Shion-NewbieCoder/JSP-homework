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
