<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>JDBC Transaction | Kết quả kiểm nghiệm</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css">
</head>
<body>
<header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a></div></header>
<main class="container page">
  <div class="page-heading"><div>
    <span class="section-tag">THỰC HÀNH JDBC · ACID</span>
    <h1>Kiểm thử Transaction: Commit &amp; Rollback</h1>
    <p>Hai INSERT và một UPDATE cùng nằm trong một Transaction duy nhất.</p>
  </div></div>
  <section class="panel" style="padding:24px; margin:20px 0;">
    <c:choose>
      <c:when test="${not empty demoError}">
        <h2 style="color:#ae3232">Có SQLException — đã yêu cầu rollback</h2>
        <p>Chế độ thử nghiệm: <strong><c:out value="${demoMode}"/></strong></p>
        <p><strong>Thông báo:</strong> <code><c:out value="${demoError}"/></code></p>
        <p>Nếu lỗi là thiếu tham số số 1, đây là kịch bản chủ đích.
          Nếu lỗi liên quan tới kết nối, schema hoặc SQL, phải khắc phục môi trường rồi thử lại.</p>
      </c:when>
      <c:when test="${demoCommitted}">
        <h2 style="color:#167c54">Đã gọi commit() thành công</h2>
        <p>Chế độ: <strong><c:out value="${demoMode}"/></strong> — hai INSERT và UPDATE đã chạy không lỗi.</p>
      </c:when>
      <c:otherwise><h2>Chưa xác định kết quả</h2></c:otherwise>
    </c:choose>
    <h2>Xác minh trên MySQL Workbench</h2>
    <pre style="white-space:pre-wrap; overflow-wrap:anywhere; padding:14px; background:#eef3f8; border-radius:8px;">USE demo;
SELECT id, name, salary, created_Date FROM Employee ORDER BY id;</pre>
    <p><strong>Trước mỗi kịch bản:</strong> chạy <code>database/reset_employee_demo.sql</code>
      để bảng thí nghiệm trống. Đừng chạy hai URL liên tiếp mà không reset.</p>
    <p><strong>Chế độ fail:</strong> nếu bảng ban đầu trống, sau rollback bảng vẫn trống.
      <strong>Chế độ success:</strong> hai dòng Quynh (999.99) và Ngan (20.00).</p>
    <p style="color:#a4322b"><strong>Chỉ dùng trong môi trường học tập.</strong>
       Các URL demo sử dụng GET để thay đổi dữ liệu, không được triển khai công khai.</p>
    <p><a class="button primary" href="${pageContext.request.contextPath}/users">Về danh sách User</a></p>
  </section>
</main>
</body>
</html>
