<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sửa User</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css"></head>
<body><header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a></div></header>
<main class="container form-page"><a class="back" href="${pageContext.request.contextPath}/users">← Trở về danh sách</a>
<section class="panel form-panel"><span class="section-tag">CẬP NHẬT</span><h1>Chỉnh sửa người dùng</h1><p>ID #<c:out value="${user.id}"/> · Cập nhật thông tin trong MySQL.</p>
<c:if test="${not empty error}"><div class="alert" role="alert"><c:out value="${error}"/></div></c:if>
<form action="${pageContext.request.contextPath}/users?action=edit" method="post">
<input type="hidden" name="id" value="${user.id}">
<label class="field" for="name">Họ tên <span class="required">*</span><input id="name" name="name" type="text" maxlength="120" required value="<c:out value='${user.name}'/>"></label>
<label class="field" for="email">Email <span class="required">*</span><input id="email" name="email" type="email" maxlength="220" required value="<c:out value='${user.email}'/>"></label>
<label class="field" for="country">Quốc gia<input id="country" name="country" type="text" maxlength="120" value="<c:out value='${user.country}'/>"></label>
<div class="form-actions"><button class="button primary" type="submit">Lưu thay đổi</button><a class="button ghost" href="${pageContext.request.contextPath}/users">Hủy</a></div>
</form></section></main></body></html>
