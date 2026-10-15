<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kết quả chiết khấu — DiscountLab</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css">
</head>
<body>
    <div class="page-shell">
        <header class="topbar"><a class="brand" href="${pageContext.request.contextPath}/"><span class="brand-icon" aria-hidden="true">%</span><span>Discount<span class="brand-accent">Lab</span></span></a><span class="course-label">JSP · SERVLET · JAVA WEB</span></header>
        <main class="result-layout">
            <div class="result-heading"><span class="eyebrow"><span class="eyebrow-dot"></span> DISCOUNT CALCULATED</span><h1>Chiết khấu <span>đã được tính.</span></h1><p>Đây là thông tin và kết quả tính toán từ sản phẩm của bạn.</p></div>
            <section class="result-card" aria-label="Kết quả tính chiết khấu">
                <div class="result-card-header"><span class="step">02 / RESULT</span><span class="status"><span aria-hidden="true">✓</span> Thành công</span></div>
                <div class="product-title"><span>PRODUCT DESCRIPTION</span><h2><c:out value="${requestScope.productDescription}" /></h2></div>
                <div class="metrics">
                    <div class="metric"><span>List Price <small>Giá niêm yết</small></span><strong><c:out value="${requestScope.listPriceFormatted}" /></strong></div>
                    <div class="metric"><span>Discount Percent <small>Tỷ lệ chiết khấu</small></span><strong><c:out value="${requestScope.discountPercent}" />%</strong></div>
                    <div class="metric savings"><span>Discount Amount <small>Số tiền được giảm</small></span><strong>− <c:out value="${requestScope.discountAmountFormatted}" /></strong></div>
                </div>
                <div class="total"><span>DISCOUNT PRICE <small>Giá sau chiết khấu</small></span><strong><c:out value="${requestScope.discountPriceFormatted}" /></strong></div>
                <a class="submit-btn back-btn" href="${pageContext.request.contextPath}/"><span aria-hidden="true">←</span> Tính sản phẩm khác</a>
                <p class="panel-footnote">Đơn vị tiền tệ theo giá bạn nhập. Giá được làm tròn đến 2 chữ số thập phân.</p>
            </section>
        </main>
        <footer class="footer"><span>CODEGYM EXERCISE · PRODUCT DISCOUNT</span><span>Java 17 / Tomcat 10.1+</span></footer>
    </div>
</body>
</html>
