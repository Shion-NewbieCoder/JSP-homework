package com.codegym.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;

/**
 * Controller MVC: ánh xạ /users.
 * TODO: Bổ sung doGet/doPost, dispatch action và gọi DAO.
 * Cố ý chưa xử lý HTTP do đề yêu cầu chỉ tạo khung sườn.
 */
@WebServlet(name = "UserServlet", urlPatterns = "/users")
public class UserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
}
