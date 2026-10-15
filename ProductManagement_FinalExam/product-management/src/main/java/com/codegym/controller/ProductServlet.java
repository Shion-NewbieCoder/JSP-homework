package com.codegym.controller;

import com.codegym.dao.ProductDAO;
import com.codegym.model.Product;
import com.codegym.service.ProductValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.Base64;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/** MVC controller. GET only displays screens; POST performs mutations. */
@WebServlet(name = "ProductServlet", urlPatterns = "/products")
public class ProductServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ProductServlet.class.getName());
    private static final SecureRandom RANDOM = new SecureRandom();
    private ProductDAO productDAO;

    @Override
    public void init() {
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        exposeCsrfToken(request);
        String action = request.getParameter("action");
        try {
            switch (action == null ? "list" : action) {
                case "create" -> displayForm(request, response, false, null);
                case "edit" -> showExisting(request, response, false);
                case "delete" -> showExisting(request, response, true);
                case "list" -> listProducts(request, response);
                default -> notFound(request, response);
            }
        } catch (SQLException ex) {
            serverError(request, response, ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        exposeCsrfToken(request);
        if (!isValidCsrf(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Phiên làm việc không hợp lệ. Hãy tải lại trang và thử lại.");
            return;
        }
        String action = request.getParameter("action");
        try {
            switch (action == null ? "" : action) {
                case "create" -> saveProduct(request, response, false);
                case "update" -> saveProduct(request, response, true);
                case "delete" -> deleteProduct(request, response);
                default -> notFound(request, response);
            }
        } catch (SQLException ex) {
            serverError(request, response, ex);
        }
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        List<Product> products = productDAO.findAll();
        long quantity = products.stream().mapToLong(Product::getQuantity).sum();
        request.setAttribute("products", products);
        request.setAttribute("totalProducts", products.size());
        request.setAttribute("totalQuantity", quantity);
        request.setAttribute("pageTitle", "Danh sách sản phẩm");
        String notice = request.getParameter("notice");
        if ("created".equals(notice)) {
            request.setAttribute("notice", "Đã thêm sản phẩm thành công.");
        } else if ("updated".equals(notice)) {
            request.setAttribute("notice", "Đã cập nhật sản phẩm thành công.");
        } else if ("deleted".equals(notice)) {
            request.setAttribute("notice", "Đã xóa sản phẩm thành công.");
        }
        forward(request, response, "list.jsp");
    }

    private void displayForm(HttpServletRequest request, HttpServletResponse response,
                             boolean isEdit, Product product)
            throws ServletException, IOException {
        request.setAttribute("isEdit", isEdit);
        request.setAttribute("productId", isEdit ? product.getId() : 0);
        request.setAttribute("formName", product == null ? "" : product.getName());
        request.setAttribute("formPrice", product == null ? "" : product.getPrice().toPlainString());
        request.setAttribute("formQuantity", product == null ? "" : product.getQuantity());
        request.setAttribute("pageTitle", isEdit ? "Sửa sản phẩm" : "Thêm sản phẩm");
        forward(request, response, "form.jsp");
    }

    private void showExisting(HttpServletRequest request, HttpServletResponse response,
                              boolean isDelete)
            throws SQLException, ServletException, IOException {
        int id = positiveId(request.getParameter("id"));
        if (id == -1) {
            notFound(request, response);
            return;
        }
        Product product = productDAO.findById(id);
        if (product == null) {
            notFound(request, response);
            return;
        }
        if (isDelete) {
            request.setAttribute("product", product);
            request.setAttribute("pageTitle", "Xác nhận xóa");
            forward(request, response, "delete.jsp");
        } else {
            displayForm(request, response, true, product);
        }
    }

    private void saveProduct(HttpServletRequest request, HttpServletResponse response,
                             boolean isEdit)
            throws SQLException, ServletException, IOException {
        int id = isEdit ? positiveId(request.getParameter("id")) : 0;
        if (isEdit && id == -1) {
            notFound(request, response);
            return;
        }
        String name = request.getParameter("name");
        String price = request.getParameter("price");
        String quantity = request.getParameter("quantity");
        ProductValidator.ValidationResult result =
                ProductValidator.validate(id, name, price, quantity);
        if (!result.isValid()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("errors", result.getErrors());
            request.setAttribute("isEdit", isEdit);
            request.setAttribute("productId", id);
            request.setAttribute("formName", name == null ? "" : name);
            request.setAttribute("formPrice", price == null ? "" : price);
            request.setAttribute("formQuantity", quantity == null ? "" : quantity);
            request.setAttribute("pageTitle", isEdit ? "Sửa sản phẩm" : "Thêm sản phẩm");
            forward(request, response, "form.jsp");
            return;
        }
        if (isEdit) {
            if (!productDAO.update(result.getProduct())) {
                notFound(request, response);
                return;
            }
            redirect(request, response, "updated");
        } else {
            productDAO.insert(result.getProduct());
            redirect(request, response, "created");
        }
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int id = positiveId(request.getParameter("id"));
        if (id == -1 || !"yes".equals(request.getParameter("confirm"))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        if (!productDAO.delete(id)) {
            notFound(request, response);
            return;
        }
        redirect(request, response, "deleted");
    }

    private int positiveId(String value) {
        try {
            int id = Integer.parseInt(value);
            return id > 0 ? id : -1;
        } catch (NumberFormatException ex) {
            return -1;
        }
    }

    private void redirect(HttpServletRequest request, HttpServletResponse response,
                          String notice) throws IOException {
        response.sendRedirect(request.getContextPath() + "/products?notice=" + notice);
    }

    private void notFound(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        request.setAttribute("pageTitle", "Không tìm thấy");
        request.setAttribute("errorTitle", "Không tìm thấy sản phẩm");
        request.setAttribute("errorMessage", "Sản phẩm này không tồn tại hoặc đã bị xóa.");
        forward(request, response, "error.jsp");
    }

    private void serverError(HttpServletRequest request, HttpServletResponse response,
                             SQLException ex) throws ServletException, IOException {
        LOGGER.log(Level.SEVERE, "Database error in product management", ex);
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        request.setAttribute("pageTitle", "Lỗi dữ liệu");
        request.setAttribute("errorTitle", "Không thể truy cập cơ sở dữ liệu");
        request.setAttribute("errorMessage", "Vui lòng kiểm tra MySQL, database và cấu hình "
                + "PRODUCT_DB_URL / PRODUCT_DB_USER / PRODUCT_DB_PASSWORD.");
        forward(request, response, "error.jsp");
    }

    private void forward(HttpServletRequest request, HttpServletResponse response,
                         String view) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/" + view).forward(request, response);
    }

    private void exposeCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        String token = (String) session.getAttribute("csrfToken");
        if (token == null) {
            byte[] bytes = new byte[24];
            RANDOM.nextBytes(bytes);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute("csrfToken", token);
        }
        request.setAttribute("csrfToken", token);
    }

    private boolean isValidCsrf(HttpServletRequest request) {
        String provided = request.getParameter("csrfToken");
        Object stored = request.getSession(false).getAttribute("csrfToken");
        return provided != null && stored instanceof String
                && MessageDigest.isEqual(provided.getBytes(StandardCharsets.UTF_8),
                ((String) stored).getBytes(StandardCharsets.UTF_8));
    }
}
