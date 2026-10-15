package com.codegym;

import com.codegym.service.DiscountCalculator;
import com.codegym.service.DiscountResult;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Locale;

/** Receives POST /display-discount, validates inputs and shows the result JSP. */
@WebServlet(name = "DiscountServlet", urlPatterns = "/display-discount")
public class DiscountServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String description = trimToEmpty(request.getParameter("productDescription"));
        String rawPrice = trimToEmpty(request.getParameter("listPrice"));
        String rawPercent = trimToEmpty(request.getParameter("discountPercent"));

        try {
            if (description.isEmpty() || description.length() > 255) {
                throw new IllegalArgumentException("Mô tả sản phẩm phải có từ 1 đến 255 ký tự.");
            }
            if (rawPrice.isEmpty() || rawPercent.isEmpty()) {
                throw new IllegalArgumentException("Vui lòng nhập đầy đủ giá và tỷ lệ chiết khấu.");
            }

            BigDecimal price = new BigDecimal(rawPrice);
            BigDecimal percent = new BigDecimal(rawPercent);
            DiscountResult result = DiscountCalculator.calculate(price, percent);

            NumberFormat moneyFormat = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
            moneyFormat.setMinimumFractionDigits(2);
            moneyFormat.setMaximumFractionDigits(2);

            request.setAttribute("productDescription", description);
            request.setAttribute("listPriceFormatted", moneyFormat.format(result.getListPrice()));
            request.setAttribute("discountPercent", result.getDiscountPercent().stripTrailingZeros().toPlainString());
            request.setAttribute("discountAmountFormatted", moneyFormat.format(result.getDiscountAmount()));
            request.setAttribute("discountPriceFormatted", moneyFormat.format(result.getDiscountPrice()));
            request.getRequestDispatcher("/WEB-INF/views/discount-result.jsp")
                    .forward(request, response);
        } catch (NumberFormatException ex) {
            forwardError(request, response, description, rawPrice, rawPercent,
                    "Vui lòng nhập số hợp lệ, dùng dấu chấm cho phần thập phân.");
        } catch (IllegalArgumentException ex) {
            forwardError(request, response, description, rawPrice, rawPercent, ex.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/");
    }

    private void forwardError(HttpServletRequest request, HttpServletResponse response,
                              String description, String price, String percent, String message)
            throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        request.setAttribute("errorMessage", message);
        request.setAttribute("productDescription", description);
        request.setAttribute("listPrice", price);
        request.setAttribute("discountPercent", percent);
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
