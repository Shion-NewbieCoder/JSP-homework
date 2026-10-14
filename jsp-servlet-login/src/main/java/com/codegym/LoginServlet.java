package com.codegym;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Login minh hoa JSP/Servlet - tai khoan co dinh admin/admin theo de bai.
 * KHONG dung mau hard-coded password nay cho ung dung that.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        boolean validCredentials = "admin".equals(username) && "admin".equals(password);

        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html lang='vi'>");
            out.println("<head>");
            out.println("<meta charset='UTF-8'>");
            out.println("<meta name='viewport' content='width=device-width, initial-scale=1'>");
            out.println("<title>Login Result</title>");
            out.println("<link rel='stylesheet' href='css/styles.css'>");
            out.println("</head>");
            out.println("<body><main class='login-shell'>");
            out.println("<section class='login-card result-card'>");
            out.println("<div class='brand-icon' aria-hidden='true'>J</div>");
            if (validCredentials) {
                out.println("<div class='result-badge success'>Đăng nhập thành công</div>");
                out.println("<h1 class='result-heading success-text'>Welcome admin to website</h1>");
                out.println("<p class='description'>Bạn đã gửi đúng username và password bằng HTTP POST.</p>");
            } else {
                out.println("<div class='result-badge error'>Đăng nhập thất bại</div>");
                out.println("<h1 class='result-heading error-text'>Login Error</h1>");
                out.println("<p class='description'>Tên đăng nhập hoặc mật khẩu không đúng.</p>");
            }
            out.println("<a class='back-link' href='index.jsp'>← Quay lại trang đăng nhập</a>");
            out.println("</section></main></body></html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Truy cap /login bang GET chi quay lai form; khong nhan mat khau tren URL.
        response.sendRedirect(request.getContextPath() + "/");
    }
}
