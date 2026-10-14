<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // JSP Scriptlet: lấy tham số POST, chuyển thành số thực và tính VND = USD * Rate.
    request.setCharacterEncoding("UTF-8");
    String errorMessage = null;
    String rateFormatted = "";
    String usdFormatted = "";
    String vndFormatted = "";

    try {
        if (!"POST".equalsIgnoreCase(request.getMethod())) {
            throw new IllegalArgumentException("Vui lòng nhập thông tin từ biểu mẫu trước.");
        }

        String rateValue = request.getParameter("rate");
        String usdValue = request.getParameter("usd");
        if (rateValue == null || usdValue == null
                || rateValue.isBlank() || usdValue.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ tỉ giá và số USD.");
        }

        double rate = Double.parseDouble(rateValue.trim());
        double usd = Double.parseDouble(usdValue.trim());
        double vnd = rate * usd;
        if (!Double.isFinite(rate) || !Double.isFinite(usd) || !Double.isFinite(vnd)
                || rate <= 0 || usd < 0) {
            throw new IllegalArgumentException("Tỉ giá phải lớn hơn 0 và USD không được âm.");
        }

        java.text.NumberFormat format = java.text.NumberFormat.getNumberInstance(
                java.util.Locale.forLanguageTag("vi-VN"));
        format.setMinimumFractionDigits(0);
        format.setMaximumFractionDigits(2);
        rateFormatted = format.format(rate);
        usdFormatted = format.format(usd);
        vndFormatted = format.format(vnd);
    } catch (NumberFormatException e) {
        errorMessage = "Giá trị nhập không hợp lệ. Vui lòng nhập số hợp lệ.";
    } catch (IllegalArgumentException e) {
        errorMessage = e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả chuyển đổi | CodeGym</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<main class="page">
    <section class="converter-card result-card" aria-labelledby="result-title">
        <p class="eyebrow">KẾT QUẢ · JSP EXPRESSION</p>
        <% if (errorMessage == null) { %>
            <div class="icon-circle success" aria-hidden="true">✓</div>
            <h1 id="result-title">Chuyển đổi thành công</h1>
            <div class="result-details">
                <%-- JSP Expression: in giá trị đã tính ra trang HTML. --%>
                <p>Tỉ giá: <strong><%= rateFormatted %> VNĐ / USD</strong></p>
                <p>Số tiền: <strong><%= usdFormatted %> USD</strong></p>
            </div>
            <div class="result-total">
                <span>Thành tiền</span>
                <strong><%= vndFormatted %> VNĐ</strong>
            </div>
        <% } else { %>
            <div class="icon-circle error" aria-hidden="true">!</div>
            <h1 id="result-title">Không thể chuyển đổi</h1>
            <p class="error-text"><%= errorMessage %></p>
        <% } %>
        <a class="back-button" href="index.jsp">← Quay lại nhập số tiền</a>
        <p class="footnote">Công thức: VNĐ = USD × Tỉ giá.</p>
    </section>
</main>
</body>
</html>
