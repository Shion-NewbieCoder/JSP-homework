<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="vi"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Thí nghiệm JDBC Rollback · UserManager</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css">
</head><body>
<header class="topbar"><div class="container topbar-inner">
<a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a>
<span class="eyebrow">JDBC · ACID · ALL OR NOTHING</span>
</div></header>
<main class="container page" style="max-width:860px;">
<a class="back" href="${pageContext.request.contextPath}/users">← Trở về danh sách</a>
<div class="page-heading"><div>
<span class="section-tag">BÀI THỰC HÀNH JDBC TRANSACTION</span>
<h1>Cố tình gây lỗi SQL và kiểm tra Rollback</h1>
<p>Chỉ chạy trên database <code>demo</code> với các bảng <code>users</code>,
<code>permission</code>, <code>user_permission</code> sử dụng InnoDB.</p>
</div></div>
<section class="panel" style="padding:26px; margin:0 0 20px;">
<h2 style="margin-top:0; font-size:20px;">Kịch bản thực hiện</h2>
<ol style="color:#34415c; line-height:1.85; padding-left:22px;">
<li><code>setAutoCommit(false)</code> để bắt đầu giao dịch.</li>
<li>INSERT một User thí nghiệm và lấy ID bằng <code>RETURN_GENERATED_KEYS</code>.</li>
<li>Gán <strong>permission_id = 1</strong> (có thật) — bước này thực thi thành công nhưng chưa commit.</li>
<li>Gán <strong>permission_id = 2147483647</strong> (không tồn tại trong bảng mẫu) → SQL lỗi khóa ngoại.</li>
<li>Gọi <code>rollback()</code>, sau đó kết nối mới kiểm tra User không tồn tại.</li>
</ol>
<div class="notice" style="margin:18px 0;">
<strong>Chỉ chạy trên môi trường học tập.</strong>
Thao tác có chủ đích sinh SQLException; không dùng tài khoản/dữ liệu thật.
GET chỉ xem trang; chỉ POST khi bạn bấm nút mới thử ghi dữ liệu.
</div>
<form method="post" action="${pageContext.request.contextPath}/users?action=test-user-rollback">
<button class="button danger" type="submit">Chạy thử: INSERT → lỗi FK → ROLLBACK</button>
</form>
</section>
<c:if test="${runCompleted}">
<section class="panel" style="padding:26px; margin-bottom:20px;">
<h2 style="margin-top:0; font-size:20px;">Kết quả kiểm chứng</h2>
<c:choose>
  <c:when test="${rollbackVerified}">
    <div class="demo-ok"><strong>ROLLBACK THÀNH CÔNG</strong> — phát hiện lỗi FK 1452 và kiểm tra lại thấy không có User nào với email thí nghiệm.</div>
  </c:when>
  <c:when test="${unexpectedCommit}">
    <div class="alert"><strong>KHÔNG ĐẠT:</strong> Lệnh tạo User đã commit, kiểm tra lại cấu hình khóa ngoại và ID quyền không tồn tại.</div>
  </c:when>
  <c:otherwise>
    <div class="alert"><strong>Chưa chứng minh được rollback.</strong> Kiểm tra chi tiết lỗi, database và số bản ghi bên dưới.</div>
  </c:otherwise>
</c:choose>
<div class="detail"><strong>Email User kiểm thử</strong><span><code><c:out value="${experimentEmail}"/></code></span></div>
<div class="detail"><strong>Lỗi SQL</strong><span><c:out value="${sqlError}" default="Không có SQLException"/></span></div>
<div class="detail"><strong>Lỗi FK mong đợi (1452)</strong><span><c:out value="${expectedForeignKey}" default="false"/></span></div>
<div class="detail"><strong>Số User còn lại sau thử nghiệm</strong><span><c:out value="${remainingCount}" default="Không xác minh được"/></span></div>
<c:if test="${not empty verifyError}"><div class="alert" style="margin-top:16px;">Không thể kiểm tra lại database: <c:out value="${verifyError}"/></div></c:if>
<h3>Kiểm tra độc lập bằng MySQL Workbench</h3>
<pre class="demo-sql">USE demo;
SELECT id, name, email, country FROM users
WHERE email = '<c:out value="${experimentEmail}"/>';

SELECT user_id, permission_id FROM user_permission
WHERE user_id IN (SELECT id FROM users
                  WHERE email = '<c:out value="${experimentEmail}"/>');</pre>
<p>Kết quả đúng: <strong>cả hai truy vấn đều trả 0 dòng.</strong>
ID AUTO_INCREMENT có thể bị nhảy dù transaction rollback — đây là hành vi bình thường, không phải dữ liệu rác.</p>
</section>
</c:if>
<footer class="footer">JDBC Transaction Lab · CodeGym · MySQL InnoDB</footer>
</main></body></html>
