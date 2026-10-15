<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="header.jspf" %>
<nav class="breadcrumb"><a href="${pageContext.request.contextPath}/products">Sản phẩm</a><span>/</span><c:choose><c:when test="${isEdit}">Chỉnh sửa</c:when><c:otherwise>Thêm mới</c:otherwise></c:choose></nav>
<div class="form-wrap">
  <div class="form-intro"><span class="eyebrow">QUẢN LÝ SẢN PHẨM</span><h1><c:choose><c:when test="${isEdit}">Chỉnh sửa sản phẩm<span class="heading-dot">.</span></c:when><c:otherwise>Thêm sản phẩm mới<span class="heading-dot">.</span></c:otherwise></c:choose></h1><p class="muted">Nhập đầy đủ thông tin bên dưới để lưu sản phẩm.</p></div>
  <section class="form-card">
    <div class="form-card-heading"><h2>Thông tin sản phẩm</h2><p class="muted">Các trường đánh dấu * là bắt buộc.</p></div>
    <c:if test="${not empty errors}"><div class="alert alert-error" role="alert"><strong>Vui lòng kiểm tra lại:</strong><ul><c:forEach var="err" items="${errors}"><li><c:out value="${err}"/></li></c:forEach></ul></div></c:if>
    <form method="post" action="${pageContext.request.contextPath}/products">
      <input type="hidden" name="csrfToken" value="${csrfToken}">
      <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
      <c:if test="${isEdit}"><input type="hidden" name="id" value="${productId}"></c:if>
      <div class="field"><label for="name">Tên sản phẩm <span>*</span></label><input id="name" name="name" type="text" maxlength="255" value="${fn:escapeXml(formName)}" placeholder="Ví dụ: Bàn phím cơ" required autofocus><small>Tối đa 255 ký tự.</small></div>
      <div class="field-grid">
        <div class="field"><label for="price">Giá sản phẩm (VND) <span>*</span></label><input id="price" name="price" type="number" inputmode="decimal" step="0.01" min="0" max="9999999999.99" value="${fn:escapeXml(formPrice)}" placeholder="149000" required><small>Giá phải không âm.</small></div>
        <div class="field"><label for="quantity">Số lượng <span>*</span></label><input id="quantity" name="quantity" type="number" inputmode="numeric" step="1" min="0" max="2147483647" value="${fn:escapeXml(formQuantity)}" placeholder="20" required><small>Số nguyên từ 0 trở lên.</small></div>
      </div>
      <div class="form-actions"><a class="button button-secondary" href="${pageContext.request.contextPath}/products">Hủy bỏ</a><button class="button button-primary" type="submit"><c:choose><c:when test="${isEdit}">Lưu thay đổi</c:when><c:otherwise>Thêm sản phẩm</c:otherwise></c:choose></button></div>
    </form>
  </section>
</div>
<%@ include file="footer.jspf" %>
