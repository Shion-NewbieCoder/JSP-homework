package com.codegym.controller;

import com.codegym.dao.IUserDAO;
import com.codegym.dao.UserDAO;
import com.codegym.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

/** Điều hướng MVC: GET xem/form/lọc/sắp xếp; POST tạo/sửa/xóa. */
@WebServlet(name = "UserServlet", urlPatterns = "/users")
public class UserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private IUserDAO dao;

    @Override
    public void init() {
        dao = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String action = req.getParameter("action");
            if (action == null || action.isEmpty() || "list".equals(action)) {
                showList(req, resp);
            } else if ("test-without-tran".equals(action)) {
                testWithoutTran(req, resp);
            } else if ("test-use-tran".equals(action)) {
                testUseTran(req, resp);
            } else if ("test-user-rollback".equals(action)) {
                // GET chỉ mở hướng dẫn; không thay đổi cơ sở dữ liệu.
                forward(req, resp, "/user/rollback-experiment.jsp");
            } else if ("create".equals(action)) {
                forward(req, resp, "/user/create.jsp");
            } else if ("edit".equals(action) || "delete".equals(action)) {
                Integer id = parseId(req.getParameter("id"));
                if (id == null) {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
                    return;
                }
                // Edit/Delete đều tra cứu qua Stored Procedure get_user_by_id.
                User user = dao.getUserById(id);
                if (user == null) {
                    notFound(req, resp);
                    return;
                }
                req.setAttribute("user", user);
                forward(req, resp, "/user/" + action + ".jsp");
            } else {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException ex) {
            throw new ServletException("Không truy cập được dữ liệu MySQL", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            switch (action) {
                case "create":
                    save(req, resp, false);
                    break;
                case "edit":
                    save(req, resp, true);
                    break;
                case "delete":
                    delete(req, resp);
                    break;
                case "test-user-rollback":
                    testUserRollback(req, resp);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thao tác không hợp lệ");
            }
        } catch (SQLException ex) {
            throw new ServletException("Không ghi được dữ liệu MySQL", ex);
        }
    }

    /**
     * Demo GET theo yêu cầu bài tập: tác động dữ liệu, chỉ dùng LOCAL.
     * Cố tình thực hiện 2 INSERT thành công rồi UPDATE bị lỗi; trình bày
     * lỗi trên trang JSP, không làm ảnh hưởng các bảng users / permission.
     */
    private void testWithoutTran(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            dao.insertUpdateWithoutTransaction();
            req.setAttribute("unexpectedSuccess", true);
        } catch (SQLException expectedOrUnexpected) {
            // Không che giấu lỗi. Người học kiểm chứng số dòng bằng MySQL Workbench.
            System.err.println("[DEMO NO-TRANSACTION] SQLException xảy ra:");
            expectedOrUnexpected.printStackTrace(System.err);
            req.setAttribute("demoError", expectedOrUnexpected.getMessage());
        }
        forward(req, resp, "/user/without-transaction.jsp");
    }

    /**
     * Trình diễn Transaction cho LOCAL DEMO; kịch bản mặc định cố tình lỗi.
     * Trên ứng dụng thực tế tuyệt đối không dùng GET để thay đổi dữ liệu.
     */
    private void testUseTran(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String mode = req.getParameter("mode");
        if (mode != null && !"fail".equals(mode) && !"success".equals(mode)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "mode phải là fail hoặc success");
            return;
        }
        boolean simulateFailure = !"success".equals(mode);
        req.setAttribute("demoMode", simulateFailure ? "fail" : "success");
        try {
            dao.insertUpdateUseTransaction(simulateFailure);
            req.setAttribute("demoCommitted", true);
        } catch (SQLException ex) {
            System.err.println("[DEMO TRANSACTION] Đã bắt SQLException:");
            ex.printStackTrace(System.err);
            req.setAttribute("demoError", ex.getMessage());
        }
        forward(req, resp, "/user/use-transaction.jsp");
    }

    /**
     * Thí nghiệm có chủ đích cho bảng users/user_permission trong CSDL demo.
     * POST tạo một email ngẫu nhiên rồi gọi addUserTransaction() với 1 quyền
     * hợp lệ và 1 ID không tồn tại để tạo lỗi khóa ngoại MySQL.
     *
     * SQLState 23xxx + MySQL error 1452 được xem là lỗi FK MONG ĐỢI;
     * không đánh đồng các lỗi kết nối, schema, password... với rollback tốt.
     */
    private void testUserRollback(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = "tx-rollback-" + UUID.randomUUID().toString().replace("-", "")
                + "@example.invalid";
        User testUser = new User("JDBC Rollback Demo", email, "VN");
        req.setAttribute("experimentEmail", email);
        req.setAttribute("runCompleted", true);
        boolean expectedForeignKey = false;
        try {
            // Permission 1 = add (hợp lệ); Integer.MAX_VALUE không có trong
            // bảng permission seed 1..4 => FOREIGN KEY violation ở lần 2.
            dao.addUserTransaction(testUser, new int[]{1, Integer.MAX_VALUE});
            // Nếu ID này tồn tại trong DB test hoặc schema thiếu FK,
            // đây là tình huống KHÔNG ĐẠT: không được nói đã rollback.
            req.setAttribute("unexpectedCommit", true);
        } catch (SQLException ex) {
            System.err.println("[DEMO USER ROLLBACK] SQLException: " + ex.getMessage());
            req.setAttribute("sqlError", ex.getMessage());
            expectedForeignKey = ex.getErrorCode() == 1452
                    && ex.getSQLState() != null && ex.getSQLState().startsWith("23");
            req.setAttribute("expectedForeignKey", expectedForeignKey);
        }
        try {
            int count = dao.countUsersByEmail(email);
            req.setAttribute("remainingCount", count);
            req.setAttribute("rollbackVerified",
                    expectedForeignKey && count == 0);
        } catch (SQLException checkError) {
            req.setAttribute("verifyError", checkError.getMessage());
            req.setAttribute("rollbackVerified", false);
        }
        forward(req, resp, "/user/rollback-experiment.jsp");
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        String country = req.getParameter("country");
        String sort = req.getParameter("sort");
        country = country == null ? "" : country.trim();
        sort = "desc".equalsIgnoreCase(sort) ? "desc" : "asc";
        List<User> users = dao.searchAndSort(country, sort);
        req.setAttribute("listUser", users);
        req.setAttribute("countryFilter", country);
        req.setAttribute("selectedSort", sort);
        forward(req, resp, "/user/list.jsp");
    }

    private void save(HttpServletRequest req, HttpServletResponse resp, boolean edit)
            throws SQLException, ServletException, IOException {
        Integer id = edit ? parseId(req.getParameter("id")) : null;
        if (edit && id == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
            return;
        }
        if (edit && dao.getUserById(id) == null) {
            notFound(req, resp);
            return;
        }
        String name = trim(req.getParameter("name"));
        String email = trim(req.getParameter("email"));
        String country = trim(req.getParameter("country"));
        User user = new User(id == null ? 0 : id, name, email, country);
        String error = validate(name, email, country);
        if (error != null) {
            req.setAttribute("error", error);
            req.setAttribute("user", user);
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            forward(req, resp, edit ? "/user/edit.jsp" : "/user/create.jsp");
            return;
        }
        if (edit) {
            if (!dao.updateUserStore(user)) {
                notFound(req, resp);
                return;
            }
        } else {
            // Checkbox cùng name="permissions" => mảng giá trị từ request.
            String[] selected = req.getParameterValues("permissions");
            int[] permissionIds = new int[selected == null ? 0 : selected.length];
            try {
                for (int i = 0; i < permissionIds.length; i++) {
                    permissionIds[i] = Integer.parseInt(selected[i]);
                    // Form chỉ cho chọn 4 quyền đã khai báo trong bảng permission.
                    if (permissionIds[i] < 1 || permissionIds[i] > 4) {
                        throw new NumberFormatException("Quyền không hợp lệ");
                    }
                }
            } catch (NumberFormatException ex) {
                req.setAttribute("error", "Danh sách quyền hạn không hợp lệ.");
                req.setAttribute("user", user);
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                forward(req, resp, "/user/create.jsp");
                return;
            }
            // Chỉ redirect nếu JDBC transaction đã commit thành công.
            // SQLException được doPost chuyển thành ServletException.
            dao.addUserTransaction(user, permissionIds);
        }
        redirectList(req, resp);
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        Integer id = parseId(req.getParameter("id"));
        if (id == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
            return;
        }
        if (!dao.deleteUserStore(id)) {
            notFound(req, resp);
            return;
        }
        redirectList(req, resp);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static String validate(String name, String email, String country) {
        if (name.isEmpty() || name.length() > 120) {
            return "Tên bắt buộc, tối đa 120 ký tự.";
        }
        if (email.isEmpty() || email.length() > 220
                || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return "Email không đúng định dạng hoặc quá 220 ký tự.";
        }
        if (country.length() > 120) {
            return "Quốc gia tối đa 120 ký tự.";
        }
        return null;
    }

    private static Integer parseId(String text) {
        try {
            int value = Integer.parseInt(text);
            return value > 0 ? value : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private void notFound(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
        forward(req, resp, "/error-404.jsp");
    }

    private static void forward(HttpServletRequest req, HttpServletResponse resp, String jsp)
            throws ServletException, IOException {
        req.getRequestDispatcher(jsp).forward(req, resp);
    }

    private static void redirectList(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/users");
    }
}
