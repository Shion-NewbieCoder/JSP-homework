<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Từ điển Anh Việt đơn giản bằng JSP và Java Map.">
    <title>Từ điển Anh – Việt | JSP</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
    <main class="page-shell">
        <div class="topline"><span class="topline-dot"></span> Java Web / JSP Practice</div>
        <section class="card" aria-labelledby="app-title">
            <div class="book-icon" aria-hidden="true">Aa</div>
            <p class="eyebrow">DICTIONARY APP</p>
            <h1 id="app-title">Từ điển Anh – Việt</h1>
            <p class="description">Tra cứu từ vựng tiếng Anh cơ bản và khám phá nghĩa tiếng Việt chỉ trong một bước.</p>

            <!-- Bài tập: POST đến dictionary.jsp và tham số name="search" -->
            <form action="dictionary.jsp" method="POST" class="search-form">
                <label for="search">Từ tiếng Anh cần tra</label>
                <input type="search" id="search" name="search"
                       list="sample-words" placeholder="Ví dụ: computer, book, hello..."
                       maxlength="100" required autofocus autocomplete="off">
                <datalist id="sample-words">
                    <option value="hello">
                    <option value="book">
                    <option value="computer">
                    <option value="student">
                    <option value="teacher">
                    <option value="family">
                    <option value="friend">
                </datalist>
                <button type="submit">Tìm kiếm <span aria-hidden="true">→</span></button>
            </form>
            <div class="tips">
                <span class="tip-label">GỢI Ý TRA CỨU</span>
                <div class="examples"><code>hello</code><code>book</code><code>computer</code><code>student</code></div>
            </div>
        </section>
        <p class="footer-note">JSP Scriptlet · Java Map · POST Request <span>•</span> CodeGym Exercise</p>
    </main>
</body>
</html>
