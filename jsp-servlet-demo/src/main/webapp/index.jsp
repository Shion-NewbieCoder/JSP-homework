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
