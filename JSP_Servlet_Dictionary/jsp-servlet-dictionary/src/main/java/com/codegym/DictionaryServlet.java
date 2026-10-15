package com.codegym;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/** Receives POST /translate and renders the Vietnamese dictionary result. */
@WebServlet(name = "DictionaryServlet", urlPatterns = "/translate")
public class DictionaryServlet extends HttpServlet {
    private static final int MAX_WORD_LENGTH = 80;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Must happen before reading POST parameters, so Vietnamese text works.
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("X-Content-Type-Options", "nosniff");

        String word = request.getParameter("word");
        String trimmedWord = word == null ? "" : word.strip();
        boolean invalid = trimmedWord.isEmpty() || trimmedWord.length() > MAX_WORD_LENGTH;
        if (invalid) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }

        String meaning = invalid ? null : DictionaryService.translate(trimmedWord);
        String safeWord = HtmlUtil.escape(trimmedWord);
        String contextPath = HtmlUtil.escape(request.getContextPath());

        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html lang=\"vi\"><head><meta charset=\"UTF-8\">");
            out.println("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
            out.println("<title>Kết quả tra cứu - Từ điển Anh Việt</title>");
            out.println("<link rel=\"stylesheet\" href=\"" + contextPath + "/css/style.css\">");
            out.println("</head><body><main class=\"page-shell\">");
            out.println("<header class=\"brand-row\"><span class=\"logo-mark\">A<span>文</span></span>");
            out.println("<span class=\"brand-title\">Lingo<span>Viet</span></span></header>");
            out.println("<article class=\"card result-card\">");
            if (invalid) {
                out.println("<p class=\"eyebrow error-label\">DỮ LIỆU KHÔNG HỢP LỆ</p>");
                out.println("<h1>Vui lòng nhập từ khóa hợp lệ</h1>");
                out.println("<p class=\"description\">Từ cần tra cứu phải có từ 1 đến 80 ký tự.</p>");
            } else if (meaning == null) {
                out.println("<p class=\"eyebrow error-label\">CHƯA CÓ TRONG TỪ ĐIỂN</p>");
                out.println("<h1>Không tìm thấy từ: <span class=\"query\">" + safeWord + "</span></h1>");
                out.println("<p class=\"description\">Thử lại với hello, book hoặc computer nhé.</p>");
            } else {
                out.println("<p class=\"eyebrow success-label\">ĐÃ TÌM THẤY</p>");
                out.println("<h1 class=\"query\">" + safeWord + "</h1>");
                out.println("<div class=\"result-divider\"></div>");
                out.println("<p class=\"meaning-label\">Nghĩa tiếng Việt</p>");
                out.println("<p class=\"meaning\">" + HtmlUtil.escape(meaning) + "</p>");
            }
            out.println("<a class=\"primary-button return-button\" href=\"" + contextPath
                    + "/\">Tra từ khác <span aria-hidden=\"true\">→</span></a>");
            out.println("</article></main></body></html>");
        }
    }
}
