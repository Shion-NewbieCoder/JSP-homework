<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Dùng JSP Scriptlet để nhận request, tra cứu Java Map và tính kết quả. --%>
<%
    request.setCharacterEncoding("UTF-8");

    Map<String, String> dic = new LinkedHashMap<>();
    dic.put("hello", "Xin chào");
    dic.put("how", "Thế nào");
    dic.put("book", "Quyển sách");
    dic.put("computer", "Máy tính");
    dic.put("student", "Sinh viên");
    dic.put("teacher", "Giáo viên");
    dic.put("school", "Trường học");
    dic.put("family", "Gia đình");
    dic.put("friend", "Bạn bè");
    dic.put("water", "Nước");
    dic.put("apple", "Quả táo");
    dic.put("love", "Tình yêu");

    String searchWord = request.getParameter("search");
    String normalizedWord = searchWord == null ? "" : searchWord.trim().toLowerCase(Locale.ROOT);
    String meaning = dic.get(normalizedWord);
    boolean emptyInput = normalizedWord.isEmpty();

    // Escape ký tự đặc biệt trước khi in dữ liệu do người dùng nhập vào HTML.
    String safeSearchWord = searchWord == null ? "" : searchWord.trim()
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả tra cứu | Từ điển Anh – Việt</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
    <main class="page-shell">
        <div class="topline"><span class="topline-dot"></span> Java Web / JSP Practice</div>
        <section class="card result-card" aria-labelledby="result-title">
            <div class="book-icon" aria-hidden="true">Aa</div>
            <p class="eyebrow">SEARCH RESULT</p>
            <h1 id="result-title">Kết quả tra cứu</h1>

            <% if (emptyInput) { %>
                <div class="result-box result-warning" role="status">
                    <span class="result-kicker">CHƯA NHẬP TỪ KHÓA</span>
                    <p>Hãy quay lại và nhập một từ tiếng Anh để tra cứu.</p>
                </div>
            <% } else if (meaning != null) { %>
                <p class="searched">Từ tiếng Anh: <strong><%= safeSearchWord %></strong></p>
                <div class="result-box result-success" role="status">
                    <span class="result-kicker">ĐÃ TÌM THẤY</span>
                    <div class="word"><%= normalizedWord %></div>
                    <div class="translation"><%= meaning %></div>
                </div>
            <% } else { %>
                <p class="searched">Từ tiếng Anh: <strong><%= safeSearchWord %></strong></p>
                <div class="result-box result-warning" role="status">
                    <span class="result-kicker">KHÔNG TÌM THẤY</span>
                    <p>Không tìm thấy từ này trong từ điển mẫu.</p>
                    <small>Thử các từ như hello, book, computer, student...</small>
                </div>
            <% } %>

            <a class="back-link" href="index.jsp"><span aria-hidden="true">←</span> Tra cứu từ khác</a>
        </section>
        <p class="footer-note">Xử lý bằng JSP Scriptlet <span>•</span> Xuất kết quả bằng JSP Expression</p>
    </main>
</body>
</html>
