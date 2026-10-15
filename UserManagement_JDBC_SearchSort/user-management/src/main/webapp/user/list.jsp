<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Danh sách User | User Management</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css">
</head>
<body>
<header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a><span class="eyebrow">JSP · Servlet · JDBC · MySQL</span></div></header>
<main class="container page">
  <div class="page-heading">
    <div><span class="section-tag">QUẢN LÝ DỮ LIỆU</span><h1>Danh sách người dùng</h1><p>Tìm kiếm theo quốc gia và sắp xếp theo tên trực tiếp từ MySQL.</p></div>
    <a class="button primary" href="${pageContext.request.contextPath}/users?action=create">+ Thêm người dùng</a>
  </div>
  <section class="panel">
    <form class="toolbar" action="${pageContext.request.contextPath}/users" method="get" role="search">
      <label class="field search-field" for="country">Tìm theo quốc gia
        <input id="country" name="country" type="search" maxlength="120" placeholder="Ví dụ: Viet Nam, Kenia..." value="<c:out value='${countryFilter}'/>">
      </label>
      <label class="field sort-field" for="sort">Sắp xếp theo tên
        <select id="sort" name="sort">
          <c:choose>
            <c:when test="${selectedSort eq 'desc'}"><option value="asc">A → Z</option><option value="desc" selected>Z → A</option></c:when>
            <c:otherwise><option value="asc" selected>A → Z</option><option value="desc">Z → A</option></c:otherwise>
          </c:choose>
        </select>
      </label>
      <button class="button primary" type="submit">Lọc / Sắp xếp</button>
      <a class="button ghost" href="${pageContext.request.contextPath}/users">Đặt lại</a>
    </form>
    <div class="table-wrap">
      <table>
        <thead><tr><th>ID</th><th>Họ tên</th><th>Email</th><th>Quốc gia</th><th>Hành động</th></tr></thead>
        <tbody>
          <c:forEach var="user" items="${listUser}">
            <tr>
              <td class="id-col">#<c:out value="${user.id}"/></td>
              <td class="name-col"><c:out value="${user.name}"/></td>
              <td><c:out value="${user.email}"/></td>
              <td><span class="tag"><c:out value="${user.country}" default="Chưa có"/></span></td>
              <td><div class="actions">
                <a class="action edit" href="${pageContext.request.contextPath}/users?action=edit&amp;id=${user.id}">Sửa</a>
                <a class="action delete" href="${pageContext.request.contextPath}/users?action=delete&amp;id=${user.id}">Xóa</a>
              </div></td>
            </tr>
          </c:forEach>
          <c:if test="${empty listUser}"><tr><td colspan="5" class="no-results">Không tìm thấy người dùng phù hợp.</td></tr></c:if>
        </tbody>
      </table>
    </div>
    <p class="table-footer">Đang hiển thị <strong>${listUser.size()}</strong> người dùng · Dữ liệu từ bảng <code>demo.users</code></p>
  </section>
  <footer class="footer">CodeGym Java Web Practice · Model – DAO – Controller – JSP</footer>
</main>
</body>
</html>
