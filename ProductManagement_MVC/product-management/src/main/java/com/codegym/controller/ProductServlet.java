package com.codegym.controller;

import com.codegym.model.Product;
import com.codegym.service.ProductService;
import com.codegym.service.ProductServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/** Controller phân phối GET/POST, xác thực dữ liệu và forward tới JSP. */
@WebServlet(name = "ProductServlet", urlPatterns = "/products")
public class ProductServlet extends HttpServlet {
    private ProductService productService;

    @Override
    public void init() {
        productService = ProductServiceImpl.getInstance();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        switch (action(request)) {
            case "create" -> showCreate(request, response);
            case "edit" -> showEdit(request, response);
            case "delete" -> showDelete(request, response);
            case "view" -> showView(request, response);
            default -> showList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        switch (action(request)) {
            case "create" -> create(request, response);
            case "edit" -> update(request, response);
            case "delete" -> delete(request, response);
            default -> response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Hành động không được hỗ trợ");
        }
    }

    private String action(HttpServletRequest request) {
        String action = request.getParameter("action");
        return action == null ? "" : action;
    }

    private void forward(HttpServletRequest req, HttpServletResponse res, String view)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/products/" + view + ".jsp")
                .forward(req, res);
    }

    private void showList(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String keyword = req.getParameter("q");
        List<Product> products = keyword == null || keyword.isBlank()
                ? productService.findAll() : productService.searchByName(keyword);
        req.setAttribute("products", products);
        req.setAttribute("keyword", keyword == null ? "" : keyword);
        req.setAttribute("total", products.size());
        forward(req, res, "list");
    }

    private void showCreate(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        forward(req, res, "create");
    }

    private Integer readId(HttpServletRequest req) {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            return id > 0 ? id : null;
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private Product existing(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        Integer id = readId(req);
        Product product = id == null ? null : productService.findById(id);
        if (product == null) {
            res.setStatus(HttpServletResponse.SC_NOT_FOUND);
            req.getRequestDispatcher("/WEB-INF/views/error-404.jsp").forward(req, res);
        }
        return product;
    }

    private void showEdit(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        Product p = existing(req, res);
        if (p == null) return;
        req.setAttribute("product", p);
        populate(req, p);
        forward(req, res, "edit");
    }

    private void showView(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        Product p = existing(req, res);
        if (p == null) return;
        req.setAttribute("product", p);
        forward(req, res, "view");
    }

    private void showDelete(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        Product p = existing(req, res);
        if (p == null) return;
        req.setAttribute("product", p);
        forward(req, res, "delete");
    }

    private void populate(HttpServletRequest req, Product p) {
        req.setAttribute("inputName", p.getName());
        req.setAttribute("inputPrice", p.getPrice().toPlainString());
        req.setAttribute("inputDescription", p.getDescription());
        req.setAttribute("inputManufacturer", p.getManufacturer());
    }

    private void populateFromRequest(HttpServletRequest req) {
        req.setAttribute("inputName", req.getParameter("name"));
        req.setAttribute("inputPrice", req.getParameter("price"));
        req.setAttribute("inputDescription", req.getParameter("description"));
        req.setAttribute("inputManufacturer", req.getParameter("manufacturer"));
    }

    /** Kiểm tra ở server: browser validation có thể bị bỏ qua. */
    private Product parseProduct(HttpServletRequest req) {
        String name = safe(req.getParameter("name"));
        String priceInput = safe(req.getParameter("price"));
        String description = safe(req.getParameter("description"));
        String manufacturer = safe(req.getParameter("manufacturer"));
        if (name.isEmpty() || name.length() > 100) {
            throw new IllegalArgumentException("Tên sản phẩm phải có 1–100 ký tự.");
        }
        if (manufacturer.isEmpty() || manufacturer.length() > 100) {
            throw new IllegalArgumentException("Nhà sản xuất phải có 1–100 ký tự.");
        }
        if (description.length() > 500) {
            throw new IllegalArgumentException("Mô tả không vượt quá 500 ký tự.");
        }
        BigDecimal price;
        try {
            price = new BigDecimal(priceInput);
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("Giá sản phẩm phải là số hợp lệ.");
        }
        if (price.compareTo(BigDecimal.ZERO) < 0
                || price.compareTo(new BigDecimal("999999999999")) > 0
                || price.stripTrailingZeros().scale() > 2) {
            throw new IllegalArgumentException("Giá từ 0 đến 999.999.999.999, tối đa 2 chữ số thập phân.");
        }
        return new Product(0, name, price, description, manufacturer);
    }

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }

    private void create(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            Product created = productService.create(parseProduct(req));
            res.sendRedirect(req.getContextPath() + "/products?action=view&id="
                    + created.getId() + "&message=created");
        } catch (IllegalArgumentException exception) {
            populateFromRequest(req);
            req.setAttribute("error", exception.getMessage());
            res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            forward(req, res, "create");
        }
    }

    private void update(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        Product found = existing(req, res);
        if (found == null) return;
        try {
            Product values = parseProduct(req);
            productService.update(found.getId(), values);
            res.sendRedirect(req.getContextPath() + "/products?action=view&id="
                    + found.getId() + "&message=updated");
        } catch (IllegalArgumentException exception) {
            req.setAttribute("product", found);
            populateFromRequest(req);
            req.setAttribute("error", exception.getMessage());
            res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            forward(req, res, "edit");
        }
    }

    private void delete(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        Product found = existing(req, res);
        if (found == null) return;
        productService.delete(found.getId());
        res.sendRedirect(req.getContextPath() + "/products?message=deleted");
    }
}
