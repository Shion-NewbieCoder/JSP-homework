<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jspf" %>
<a class="backlink" href="${pageContext.request.contextPath}/products">← Quay lại danh sách</a>
<div class="form-shell">
    <span class="eyebrow">SẢN PHẨM / CHỈNH SỬA · #<c:out value="${product.id}"/></span>
    <h1>Cập nhật sản phẩm<span class="title-dot">.</span></h1>
    <p class="lead">Thay đổi thông tin sản phẩm đang được lưu.</p>
    <c:if test="${not empty error}"><div class="notice error" role="alert"><c:out value="${error}"/></div></c:if>
    <form class="edit-form panel" action="${pageContext.request.contextPath}/products?action=edit" method="post">
        <input type="hidden" name="id" value="${product.id}">
        <div class="field"><label for="name">Tên sản phẩm <span>*</span></label>
            <input id="name" name="name" required maxlength="100" value="${fn:escapeXml(inputName)}" autofocus></div>
        <div class="field-grid">
            <div class="field"><label for="price">Giá sản phẩm (VNĐ) <span>*</span></label>
                <input id="price" name="price" type="number" min="0" max="999999999999" step="0.01" required value="${fn:escapeXml(inputPrice)}"></div>
            <div class="field"><label for="manufacturer">Nhà sản xuất <span>*</span></label>
                <input id="manufacturer" name="manufacturer" required maxlength="100" value="${fn:escapeXml(inputManufacturer)}"></div>
        </div>
        <div class="field"><label for="description">Mô tả sản phẩm</label>
            <textarea id="description" name="description" maxlength="500" rows="4"><c:out value="${inputDescription}"/></textarea></div>
        <div class="form-actions"><a class="button ghost" href="${pageContext.request.contextPath}/products?action=view&amp;id=${product.id}">Hủy</a><button class="button primary" type="submit">Lưu thay đổi →</button></div>
    </form>
</div>
<%@ include file="../common/footer.jspf" %>
