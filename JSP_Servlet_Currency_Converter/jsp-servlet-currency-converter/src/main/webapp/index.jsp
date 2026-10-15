<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chuyển đổi tiền tệ USD sang VNĐ</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<main class="container">
    <article class="card">
        <div class="eyebrow">CURRENCY CONVERTER · JSP / SERVLET</div>
        <h1>Chuyển đổi USD sang VNĐ</h1>
        <p class="helper">Nhập tỉ giá và số USD cần đổi để tính số tiền VNĐ tương ứng.</p>

        <form action="${pageContext.request.contextPath}/convert" method="post">
            <div class="form-group">
                <label for="rate">Tỉ giá (VNĐ / USD)</label>
                <input id="rate" name="rate" type="number" inputmode="decimal" min="0.000001"
                       step="any" value="25000" placeholder="Ví dụ: 25000" required>
            </div>
            <div class="form-group">
                <label for="usd">Lượng USD cần đổi</label>
                <input id="usd" name="usd" type="number" inputmode="decimal" min="0"
                       step="any" placeholder="Ví dụ: 100" required>
            </div>
            <button class="button" type="submit">Chuyển đổi sang VNĐ <span aria-hidden="true">→</span></button>
        </form>
        <p class="note">Tỉ giá do người dùng tự nhập; ứng dụng không lấy tỉ giá thời gian thực.</p>
    </article>
</main>
</body>
</html>
