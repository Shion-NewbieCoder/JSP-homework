package com.codegym.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;

/**
 * MVC controller placeholder mapped to /customers.
 * TODO: Implement doGet/doPost, action routing, form validation and JSP forwarding.
 * IMPORTANT: Accessing /customers will not render a page until those are added.
 */
@WebServlet(name = "CustomerServlet", urlPatterns = {"/customers"})
public class CustomerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
}
