<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>JDBC không dùng Transaction | Bài thực hành</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css">
</head>
<body>
<header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a></div></header>
<main class="container page">
  <div class="page-heading"><div>
    <span class="section-tag">THỰC HÀNH JDBC</span>
    <h1>Thử nghiệm không dùng Transaction</h1>
    <p>Hai lệnh INSERT được auto-commit, sau đó UPDATE được cố tình thiếu tham số thứ nhất.</p>
  </div></div>
  <section class="panel" style="padding:24px; margin:20px 0">
    <c:choose>
      <c:when test="${not empty demoError}">
        <h2 style="color:#a4322b;">Đã bắt được SQLException</h2>
        <p><strong>Chi tiết:</strong> <code><c:out value="${demoError}" /></code></p>
        <p>Đây là lỗi mong đợi khi thiếu tham số thứ nhất của UPDATE. Tuy nhiên hãy kiểm tra log
          và bảng MySQL để phân biệt lỗi chủ đích với lỗi kết nối hoặc quyền truy cập.</p>
      </c:when>
      <c:otherwise>
        <h2>Không phát sinh SQLException</h2>
        <p>Kết quả không như thí nghiệm dự kiến. Kiểm tra driver MySQL và câu lệnh UPDATE.</p>
      </c:otherwise>
    </c:choose>
    <h2>Kiểm tra MySQL Workbench</h2>
    <pre style="white-space:pre-wrap; overflow-wrap:anywhere; padding:14px; background:#eef3f8; border-radius:8px;">USE demo;
SELECT id, name, salary, created_Date FROM Employee ORDER BY id;</pre>
    <p><strong>Kết quả dự kiến (khi kết nối và 2 INSERT thành công):</strong> Quynh = 10.00, Ngan = 20.00.
    Mức lương Quynh không bị cập nhật thành 999.99.</p>
    <p><strong>Cảnh báo:</strong> Demo này <em>xóa và tạo lại</em> bảng <code>Employee</code>
    khi truy cập URL thử nghiệm. Chỉ dùng với MySQL <code>demo</code> trên máy học tập.</p>
    <a class="button primary" href="${pageContext.request.contextPath}/users">Về danh sách User</a>
  </section>
</main>
</body>
</html>
