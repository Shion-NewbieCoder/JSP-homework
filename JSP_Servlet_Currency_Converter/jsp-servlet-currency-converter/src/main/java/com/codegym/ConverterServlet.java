package com.codegym;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.NumberFormat;
import java.util.Locale;

/** Receives POST /convert from index.jsp and renders the conversion result. */
@WebServlet(name = "ConverterServlet", urlPatterns = "/convert")
public class ConverterServlet extends HttpServlet {
    private static final Locale VIETNAM = Locale.forLanguageTag("vi-VN");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try {
            BigDecimal rate = parseDecimal(request.getParameter("rate"), "tỉ giá");
            BigDecimal usd = parseDecimal(request.getParameter("usd"), "lượng USD");
            BigDecimal vnd = CurrencyCalculator.convert(rate, usd);
            showResult(response, request.getContextPath(), rate, usd, vnd);
        } catch (IllegalArgumentException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            showError(response, request.getContextPath(), ex.getMessage());
        }
    }

    private static BigDecimal parseDecimal(String raw, String field) {
        if (raw == null || raw.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập " + field + ".");
        }
        String normalized = raw.trim();
        if (normalized.length() > 30) {
            throw new IllegalArgumentException("Giá trị " + field + " quá dài.");
        }
        try {
            BigDecimal value = new BigDecimal(normalized);
            if (value.precision() > 18 || value.scale() > 6 || value.scale() < -12) {
                throw new IllegalArgumentException("Giá trị " + field + " vượt quá giới hạn hỗ trợ.");
            }
            return value;
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Giá trị " + field + " phải là số hợp lệ.");
        }
    }

    private static String formatNumber(BigDecimal number) {
        NumberFormat nf = NumberFormat.getNumberInstance(VIETNAM);
        nf.setGroupingUsed(true);
        nf.setMaximumFractionDigits(2);
        nf.setRoundingMode(RoundingMode.HALF_UP);
        return nf.format(number);
    }

    private static void pageStart(PrintWriter out, String contextPath, String title) {
        out.println("<!DOCTYPE html>");
        out.println("<html lang=\"vi\"><head><meta charset=\"UTF-8\">");
        out.println("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
        out.println("<title>" + title + "</title>");
        out.println("<link rel=\"stylesheet\" href=\"" + contextPath + "/css/style.css\">");
        out.println("</head><body><main class=\"container\">");
    }

    private static void pageEnd(PrintWriter out) {
        out.println("</main></body></html>");
    }

    private static void showResult(HttpServletResponse response, String contextPath,
                                   BigDecimal rate, BigDecimal usd, BigDecimal vnd)
            throws IOException {
        try (PrintWriter out = response.getWriter()) {
            pageStart(out, contextPath, "Kết quả chuyển đổi");
            out.println("<article class=\"card result-card\">");
            out.println("<div class=\"eyebrow\">USD → VND · KẾT QUẢ</div>");
            out.println("<h1>Chuyển đổi thành công</h1>");
            out.println("<p class=\"helper\">Giá trị được tính từ tỉ giá do bạn nhập.</p>");
            out.println("<div class=\"result-amount\">" + formatNumber(vnd) + " <span>VNĐ</span></div>");
            out.println("<div class=\"breakdown\"><div><span>Tỉ giá</span><strong>"
                    + formatNumber(rate) + " VNĐ / USD</strong></div>");
            out.println("<div><span>Số tiền USD</span><strong>" + formatNumber(usd) + " USD</strong></div></div>");
            out.println("<a class=\"button\" href=\"" + contextPath + "/\">Chuyển đổi tiếp</a>");
            out.println("</article>");
            pageEnd(out);
        }
    }

    private static void showError(HttpServletResponse response, String contextPath,
                                  String message) throws IOException {
        // message only comes from fixed server-side validation strings (never raw input).
        try (PrintWriter out = response.getWriter()) {
            pageStart(out, contextPath, "Lỗi chuyển đổi");
            out.println("<article class=\"card result-card\">");
            out.println("<div class=\"eyebrow error-text\">DỮ LIỆU KHÔNG HỢP LỆ</div>");
            out.println("<h1>Không thể chuyển đổi</h1>");
            out.println("<p class=\"error-message\">" + message + "</p>");
            out.println("<a class=\"button\" href=\"" + contextPath + "/\">Quay lại biểu mẫu</a>");
            out.println("</article>");
            pageEnd(out);
        }
    }
}
