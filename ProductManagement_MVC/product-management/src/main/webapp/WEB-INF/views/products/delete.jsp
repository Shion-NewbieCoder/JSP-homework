<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="../common/header.jspf" %>
<a class="backlink" href="${pageContext.request.contextPath}/products">← Quay lại danh sách</a>
<div class="form-shell">
    <span class="eyebrow danger-text">SẢN PHẨM / XÁC NHẬN XÓA</span>
    <h1>Xóa sản phẩm?</h1>
    <p class="lead">Hành động sẽ xóa bản ghi khỏi danh sách hiện tại.</p>
    <section class="panel confirm-panel">
        <div class="warning-symbol">!</div>
        <h2><c:out value="${product.name}"/></h2>
        <p>Mã #<c:out value="${product.id}"/> · <c:out value="${product.manufacturer}"/></p>
        <form class="form-actions" method="post" action="${pageContext.request.contextPath}/products?action=delete">
            <input type="hidden" name="id" value="${product.id}">
            <a class="button ghost" href="${pageContext.request.contextPath}/products">Hủy</a>
            <button type="submit" class="button danger">Xác nhận xóa</button>
        </form>
    </section>
</div>
<%@ include file="../common/footer.jspf" %>
