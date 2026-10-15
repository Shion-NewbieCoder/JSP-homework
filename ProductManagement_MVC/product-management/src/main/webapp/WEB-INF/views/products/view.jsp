<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jspf" %>
<fmt:setLocale value="vi_VN"/>
<a class="backlink" href="${pageContext.request.contextPath}/products">← Quay lại danh sách</a>
<div class="detail-shell">
    <span class="eyebrow">CHI TIẾT SẢN PHẨM / #<c:out value="${product.id}"/></span>
    <h1><c:out value="${product.name}"/><span class="title-dot">.</span></h1>
    <c:if test="${param.message == 'created'}"><div class="notice success" role="status">Đã tạo sản phẩm mới thành công.</div></c:if>
    <c:if test="${param.message == 'updated'}"><div class="notice success" role="status">Đã cập nhật sản phẩm thành công.</div></c:if>
    <section class="panel detail-panel">
        <dl class="details">
            <div><dt>Mã sản phẩm</dt><dd class="mono">#<c:out value="${product.id}"/></dd></div>
            <div><dt>Tên sản phẩm</dt><dd><c:out value="${product.name}"/></dd></div>
            <div><dt>Giá bán</dt><dd class="price"><fmt:formatNumber value="${product.price}" type="number" maxFractionDigits="2"/> ₫</dd></div>
            <div><dt>Nhà sản xuất</dt><dd><c:out value="${product.manufacturer}"/></dd></div>
            <div><dt>Mô tả</dt><dd><c:out value="${product.description}" default="(Chưa có mô tả)"/></dd></div>
        </dl>
        <div class="form-actions"><a class="button ghost" href="${pageContext.request.contextPath}/products?action=delete&amp;id=${product.id}">Xóa sản phẩm</a><a class="button primary" href="${pageContext.request.contextPath}/products?action=edit&amp;id=${product.id}">Chỉnh sửa →</a></div>
    </section>
</div>
<%@ include file="../common/footer.jspf" %>
