<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>LingoViet | Từ điển Anh - Việt</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <main class="page-shell">
        <header class="brand-row">
            <span class="logo-mark">A<span>文</span></span>
            <span class="brand-title">Lingo<span>Viet</span></span>
        </header>
        <section class="card search-card" aria-labelledby="page-title">
            <div class="eyebrow">ENGLISH → VIETNAMESE</div>
            <h1 id="page-title">Một từ mới, một điều hay.</h1>
            <p class="description">Tra cứu nghĩa từ tiếng Anh nhanh chóng bằng từ điển mini được xây dựng với JSP &amp; Servlet.</p>
            <form action="${pageContext.request.contextPath}/translate" method="post" accept-charset="UTF-8">
                <label for="word">Nhập từ tiếng Anh</label>
                <div class="search-field">
                    <span class="search-icon" aria-hidden="true">⌕</span>
                    <input id="word" name="word" type="text" maxlength="80" placeholder="Ví dụ: hello, book, computer..." autofocus autocomplete="off" required>
                </div>
                <button type="submit" class="primary-button">Tìm kiếm <span aria-hidden="true">→</span></button>
            </form>
            <div class="examples">
                <p>Gợi ý tra cứu</p>
                <div class="chips"><span>hello</span><span>student</span><span>computer</span><span>thank you</span></div>
            </div>
        </section>
        <footer class="footer-note">Bài thực hành CodeGym · Java 17 · Jakarta Servlet · Tomcat 10.1+</footer>
    </main>
</body>
</html>
