<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Tính chiết khấu và giá sau khi giảm bằng JSP và Servlet.">
    <title>Product Discount Calculator — CodeGym</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css">
</head>
<body>
    <div class="page-shell">
        <header class="topbar">
            <a class="brand" href="${pageContext.request.contextPath}/">
                <span class="brand-icon" aria-hidden="true">%</span>
                <span>Discount<span class="brand-accent">Lab</span></span>
            </a>
            <span class="course-label">JSP · SERVLET · JAVA WEB</span>
        </header>

        <main class="hero-layout">
            <section class="intro" aria-labelledby="hero-title">
                <span class="eyebrow"><span class="eyebrow-dot"></span> PRODUCT DISCOUNT CALCULATOR</span>
                <h1 id="hero-title">Tính giá ưu đãi<br><span>trong vài giây.</span></h1>
                <p>Nhập thông tin sản phẩm và mức chiết khấu để biết chính xác số tiền được giảm và giá thanh toán.</p>
                <div class="formula"><span class="formula-icon">ƒ</span><span><strong>Discount Amount</strong> = List Price × Discount Percent ÷ 100</span></div>
                <div class="decor-line"><span></span><span></span><span></span></div>
            </section>

            <section class="panel" aria-labelledby="form-title">
                <div class="panel-top"><div><span class="step">01 / CALCULATOR</span><h2 id="form-title">Thông tin sản phẩm</h2><p>Điền các trường bên dưới để tính chiết khấu.</p></div><span class="panel-symbol" aria-hidden="true">↗</span></div>
                <c:if test="${not empty requestScope.errorMessage}">
                    <div class="alert" role="alert"><strong>Không thể tính chiết khấu.</strong> <c:out value="${requestScope.errorMessage}" /></div>
                </c:if>
                <form action="${pageContext.request.contextPath}/display-discount" method="post">
                    <div class="field"><label for="productDescription">Product Description <span>Mô tả sản phẩm</span></label>
                        <input id="productDescription" name="productDescription" type="text" maxlength="255" required placeholder="Ví dụ: Bàn phím cơ Keychron" value="<c:out value='${requestScope.productDescription}' />">
                    </div>
                    <div class="field-row">
                        <div class="field"><label for="listPrice">List Price <span>Giá niêm yết</span></label>
                            <div class="input-wrap"><input id="listPrice" name="listPrice" type="number" min="0" max="999999999999.99" step="0.01" inputmode="decimal" required placeholder="1000000" value="<c:out value='${requestScope.listPrice}' />"><span class="field-unit">PRICE</span></div>
                        </div>
                        <div class="field"><label for="discountPercent">Discount Percent <span>Tỷ lệ chiết khấu</span></label>
                            <div class="input-wrap"><input id="discountPercent" name="discountPercent" type="number" min="0" max="100" step="0.01" inputmode="decimal" required placeholder="20" value="<c:out value='${requestScope.discountPercent}' />"><span class="field-unit">%</span></div>
                        </div>
                    </div>
                    <button class="submit-btn" type="submit">Calculate Discount <span aria-hidden="true">→</span></button>
                </form>
                <p class="panel-footnote">Chấp nhận tỷ lệ 0–100%. Kết quả làm tròn đến 2 chữ số thập phân.</p>
            </section>
        </main>

        <footer class="footer"><span>CODEGYM EXERCISE · PRODUCT DISCOUNT</span><span>Java 17 / Tomcat 10.1+</span></footer>
    </div>
</body>
</html>
