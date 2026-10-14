<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chuyển đổi USD sang VNĐ | CodeGym</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<main class="page">
    <section class="converter-card" aria-labelledby="converter-title">
        <p class="eyebrow">JAVA WEB · JSP PRACTICE</p>
        <div class="icon-circle" aria-hidden="true">$ ↔ ₫</div>
        <h1 id="converter-title">USD to VND Converter</h1>
        <p class="description">Nhập tỉ giá và lượng USD cần đổi. Kết quả được xử lý bằng JSP trên máy chủ.</p>

        <%-- Gửi dữ liệu bằng POST đến converter.jsp (cùng thư mục). --%>
        <form action="converter.jsp" method="post">
            <div class="field">
                <label for="rate">Tỉ giá (VND / USD)</label>
                <input id="rate" name="rate" type="number" min="0.000001" step="any"
                       inputmode="decimal" value="25000" placeholder="Ví dụ: 25000" required>
            </div>
            <div class="field">
                <label for="usd">Số tiền USD cần chuyển đổi</label>
                <input id="usd" name="usd" type="number" min="0" step="any"
                       inputmode="decimal" placeholder="Ví dụ: 100" required>
            </div>
            <button type="submit">Chuyển đổi ngay <span aria-hidden="true">→</span></button>
        </form>
        <p class="footnote">Đây là bài tập nhập tỉ giá giả định, không phải tỉ giá thời gian thực.</p>
    </section>
</main>
</body>
</html>
