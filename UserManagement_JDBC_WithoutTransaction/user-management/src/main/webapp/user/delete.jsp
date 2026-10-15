<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Xóa User</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css"></head>
<body><header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a></div></header>
<main class="container form-page"><a class="back" href="${pageContext.request.contextPath}/users">← Trở về danh sách</a>
<section class="panel form-panel"><span class="section-tag">XÁC NHẬN</span><h1>Xóa người dùng?</h1>
<div class="notice">Hành động này sẽ xóa bản ghi trong MySQL và không thể hoàn tác.</div>
<div class="detail"><strong>ID</strong><span>#<c:out value="${user.id}"/></span></div>
<div class="detail"><strong>Tên</strong><span><c:out value="${user.name}"/></span></div>
<div class="detail"><strong>Email</strong><span><c:out value="${user.email}"/></span></div>
<div class="detail"><strong>Quốc gia</strong><span><c:out value="${user.country}"/></span></div>
<form action="${pageContext.request.contextPath}/users?action=delete" method="post"><input type="hidden" name="id" value="${user.id}">
<div class="form-actions"><button class="button danger" type="submit">Xác nhận xóa</button><a class="button ghost" href="${pageContext.request.contextPath}/users">Hủy</a></div></form>
</section></main></body></html>
