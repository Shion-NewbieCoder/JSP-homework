<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Thêm User</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css"></head>
<body><header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a></div></header>
<main class="container form-page"><a class="back" href="${pageContext.request.contextPath}/users">← Trở về danh sách</a>
<section class="panel form-panel"><span class="section-tag">TẠO MỚI</span><h1>Thêm người dùng</h1><p>Thông tin và quyền được ghi trong một transaction MySQL (thành công hoặc rollback cùng nhau).</p>
<c:if test="${not empty error}"><div class="alert" role="alert"><c:out value="${error}"/></div></c:if>
<form action="${pageContext.request.contextPath}/users?action=create" method="post">
<label class="field" for="name">Họ tên <span class="required">*</span><input id="name" name="name" type="text" maxlength="120" required value="<c:out value='${user.name}'/>"></label>
<label class="field" for="email">Email <span class="required">*</span><input id="email" name="email" type="email" maxlength="220" required value="<c:out value='${user.email}'/>"></label>
<label class="field" for="country">Quốc gia<input id="country" name="country" type="text" maxlength="120" value="<c:out value='${user.country}'/>"></label>
<fieldset class="permission-fieldset">
<legend>Quyền hạn (Permissions)</legend>
<p class="permissions-hint">Chọn các quyền để gán cùng lúc với việc tạo User (có thể bỏ trống).</p>
<div class="permission-options">
<label class="permission-item"><input type="checkbox" name="permissions" value="1"> Thêm (Add)</label>
<label class="permission-item"><input type="checkbox" name="permissions" value="2"> Sửa (Edit)</label>
<label class="permission-item"><input type="checkbox" name="permissions" value="3"> Xoá (Delete)</label>
<label class="permission-item"><input type="checkbox" name="permissions" value="4"> Xem (View)</label>
</div>
</fieldset>
<div class="form-actions"><button class="button primary" type="submit">Lưu người dùng</button><a class="button ghost" href="${pageContext.request.contextPath}/users">Hủy</a></div>
</form></section></main></body></html>
