<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jspf" %>
<fmt:setLocale value="vi_VN"/>
<div class="page-heading">
    <div>
        <span class="eyebrow">QUẢN LÝ KHO / SẢN PHẨM</span>
        <h1>Danh sách sản phẩm<span class="title-dot">.</span></h1>
        <p class="lead">Quản lý, tìm kiếm và cập nhật sản phẩm trên cùng một hệ thống.</p>
    </div>
    <a class="button primary" href="${pageContext.request.contextPath}/products?action=create">+ Thêm sản phẩm</a>
</div>
<c:if test="${param.message == 'deleted'}"><div class="notice success" role="status">Đã xóa sản phẩm thành công.</div></c:if>
<section class="panel">
    <div class="panel-head">
        <div><h2>Kho sản phẩm</h2><p><strong><c:out value="${total}"/></strong> sản phẩm đang hiển thị</p></div>
        <form class="search-form" action="${pageContext.request.contextPath}/products" method="get" role="search">
            <label class="sr-only" for="q">Tìm theo tên</label>
            <input id="q" name="q" type="search" placeholder="Tìm theo tên sản phẩm..."
                   value="${fn:escapeXml(keyword)}" maxlength="100">
            <button type="submit" class="button dark">Tìm kiếm</button>
            <c:if test="${not empty keyword}"><a class="button ghost" href="${pageContext.request.contextPath}/products">Xóa lọc</a></c:if>
        </form>
    </div>
    <div class="table-scroll">
        <table class="data-table">
            <thead><tr><th>ID</th><th>Tên sản phẩm</th><th>Nhà sản xuất</th><th>Giá bán</th><th>Hành động</th></tr></thead>
            <tbody>
            <c:forEach var="product" items="${products}">
                <tr>
                    <td class="mono muted">#<c:out value="${product.id}"/></td>
                    <td><a class="product-link" href="${pageContext.request.contextPath}/products?action=view&amp;id=${product.id}"><c:out value="${product.name}"/></a><span class="table-subtext"><c:out value="${product.description}"/></span></td>
                    <td><span class="pill"><c:out value="${product.manufacturer}"/></span></td>
                    <td class="price"><fmt:formatNumber value="${product.price}" type="number" maxFractionDigits="2"/> ₫</td>
                    <td><div class="table-actions">
                        <a href="${pageContext.request.contextPath}/products?action=view&amp;id=${product.id}">Xem</a>
                        <a href="${pageContext.request.contextPath}/products?action=edit&amp;id=${product.id}">Sửa</a>
                        <a class="danger-link" href="${pageContext.request.contextPath}/products?action=delete&amp;id=${product.id}">Xóa</a>
                    </div></td>
                </tr>
            </c:forEach>
            <c:if test="${empty products}"><tr><td class="empty-state" colspan="5">Không có sản phẩm phù hợp. Thử từ khóa khác hoặc thêm sản phẩm mới.</td></tr></c:if>
            </tbody>
        </table>
    </div>
</section>
<div class="hint"><strong>Ghi chú:</strong> Dữ liệu lưu bằng Map trong bộ nhớ, sẽ được đặt lại khi khởi động lại ứng dụng.</div>
<%@ include file="../common/footer.jspf" %>
