package com.codegym;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/** Displays a simple dynamic HTML page from a Jakarta Servlet. */
@WebServlet(name = "HelloServlet", urlPatterns = {"/hello"})
public class HelloServlet extends HttpServlet {

    private static final DateTimeFormatter TIME_FORMAT =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss z", Locale.forLanguageTag("vi-VN"));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        String currentTime = ZonedDateTime.now().format(TIME_FORMAT);
        String contextPath = request.getContextPath();

        String page = """
                <!DOCTYPE html>
                <html lang="vi">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <title>Hello Servlet | CodeGym</title>
                    <link rel="stylesheet" href="%s/assets/style.css">
                </head>
                <body>
                <main class="page-shell">
                    <section class="card">
                        <div class="eyebrow">JAVA WEB / JAKARTA SERVLET</div>
                        <div class="icon-mark" aria-hidden="true">J</div>
                        <h1>Chào mừng đến với Servlet đầu tiên!</h1>
                        <p class="lead">Nội dung này được tạo bởi
                           <strong>HelloServlet.java</strong> trên Tomcat.</p>
                        <div class="time-panel">
                            <span>Thời gian hiện tại của máy chủ</span>
                            <strong>%s</strong>
                        </div>
                        <p class="hint">Mỗi lần tải lại, Servlet sẽ lấy thời gian mới từ hệ thống máy chủ.</p>
                        <div class="actions">
                            <a class="button button-primary" href="%s/">Về trang JSP</a>
                            <a class="button button-secondary" href="%s/hello">Làm mới thời gian</a>
                        </div>
                    </section>
                </main>
                </body>
                </html>
                """.formatted(contextPath, currentTime, contextPath, contextPath);

        try (PrintWriter out = response.getWriter()) {
            out.print(page);
        }
    }
}
