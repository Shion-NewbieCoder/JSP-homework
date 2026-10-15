<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="header.jspf" %>
<section class="intro">
  <div>
    <span class="eyebrow">QUẢN LÝ KHO HÀNG</span>
    <h1>Danh sách sản phẩm<span class="heading-dot">.</span></h1>
    <p class="muted intro-copy">Theo dõi và cập nhật sản phẩm của bạn ở một nơi.</p>
  </div>
  <a class="button button-primary" href="${pageContext.request.contextPath}/products?action=create">
    <span class="plus">+</span> Thêm sản phẩm
  </a>
</section>

<c:if test="${not empty notice}">
  <div class="alert alert-success" role="status"><span class="alert-check">✓</span> <c:out value="${notice}"/></div>
</c:if>

<section class="stats" aria-label="Thống kê tổng quan">
  <div class="stat">
    <div class="stat-icon">▦</div>
    <div><div class="stat-label">Tổng sản phẩm</div><div class="stat-value"><c:out value="${totalProducts}"/></div></div>
  </div>
  <div class="stat">
    <div class="stat-icon icon-neutral">◫</div>
    <div><div class="stat-label">Tổng số lượng</div><div class="stat-value"><fmt:formatNumber value="${totalQuantity}" pattern="#,##0"/></div></div>
  </div>
  <div class="stat stat-tip">
    <div class="stat-icon icon-green">✓</div>
    <div><div class="stat-label">Lưu trữ</div><div class="stat-value stat-value-sm">MySQL Database</div></div>
  </div>
</section>

<section class="table-panel">
  <div class="panel-head">
    <div><h2>Tất cả sản phẩm</h2><p class="muted panel-description">Danh sách được đồng bộ từ cơ sở dữ liệu.</p></div>
    <span class="count-bubble"><c:out value="${totalProducts}"/> sản phẩm</span>
  </div>
  <div class="table-scroll">
    <table>
      <thead><tr><th scope="col">ID</th><th scope="col">TÊN SẢN PHẨM</th><th scope="col">GIÁ (VND)</th><th scope="col">SỐ LƯỢNG</th><th scope="col" class="actions-head">THAO TÁC</th></tr></thead>
      <tbody>
        <c:forEach var="product" items="${products}">
          <tr>
            <td class="id-cell">#<c:out value="${product.id}"/></td>
            <td><span class="product-name"><c:out value="${product.name}"/></span></td>
            <td class="price-cell"><fmt:formatNumber value="${product.price}" pattern="#,##0.##"/> ₫</td>
            <td><span class="stock-pill ${product.quantity == 0 ? 'stock-empty' : ''}"><c:out value="${product.quantity}"/> trong kho</span></td>
            <td class="actions">
              <a class="action-link" href="${pageContext.request.contextPath}/products?action=edit&amp;id=${product.id}">Sửa</a>
              <a class="action-link danger-link" href="${pageContext.request.contextPath}/products?action=delete&amp;id=${product.id}">Xóa</a>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty products}">
          <tr><td colspan="5"><div class="empty-state"><div class="empty-icon">◇</div><strong>Chưa có sản phẩm nào</strong><p>Hãy thêm sản phẩm đầu tiên để bắt đầu quản lý.</p></div></td></tr>
        </c:if>
      </tbody>
    </table>
  </div>
  <div class="panel-bottom">Dữ liệu được lưu bằng JDBC · MySQL</div>
</section>
<%@ include file="footer.jspf" %>
