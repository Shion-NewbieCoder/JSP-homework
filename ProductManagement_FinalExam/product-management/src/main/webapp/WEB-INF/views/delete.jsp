<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="header.jspf" %>
<nav class="breadcrumb"><a href="${pageContext.request.contextPath}/products">Sản phẩm</a><span>/</span>Xác nhận xóa</nav>
<section class="confirm-card">
  <div class="warning-symbol">!</div>
  <h1>Xóa sản phẩm?</h1><p class="muted">Hành động này không thể hoàn tác. Hãy kiểm tra thông tin trước khi xác nhận.</p>
  <div class="details"><div><span>Mã sản phẩm</span><strong>#<c:out value="${product.id}"/></strong></div><div><span>Tên sản phẩm</span><strong><c:out value="${product.name}"/></strong></div><div><span>Giá</span><strong><fmt:formatNumber value="${product.price}" pattern="#,##0.##"/> ₫</strong></div><div><span>Số lượng</span><strong><c:out value="${product.quantity}"/></strong></div></div>
  <form method="post" action="${pageContext.request.contextPath}/products" class="confirm-actions">
    <input type="hidden" name="csrfToken" value="${csrfToken}">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="confirm" value="yes">
    <input type="hidden" name="id" value="${product.id}">
    <a class="button button-secondary" href="${pageContext.request.contextPath}/products">Hủy bỏ</a>
    <button class="button button-danger" type="submit">Xác nhận xóa</button>
  </form>
</section>
<%@ include file="footer.jspf" %>
