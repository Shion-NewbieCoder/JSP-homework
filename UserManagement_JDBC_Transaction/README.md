# Bài thực hành JDBC Transaction — User Management

## 1. Mục tiêu

Tạo User và phân quyền trong cùng một JDBC transaction: **thành công cùng nhau (`commit`) hoặc hủy toàn bộ (`rollback`)**. Dự án tiếp nối bài Stored Procedures: giữ List/Create/Edit/Delete, lọc `country`, sắp xếp `name`; Edit vẫn gọi Stored Procedure `get_user_by_id`, còn Create dùng `addUserTransaction` thay cho `insert_user`.

## 2. Cấu trúc dự án và khởi động

```text
UserManagement_JDBC_Transaction/
├── README.md
└── user-management/
    ├── pom.xml
    ├── database/
    │   ├── init.sql
    │   ├── stored_procedures.sql
    │   ├── transaction_permissions.sql
    │   └── verify_transaction.sql
    └── src/main/
        ├── java/com/codegym/
        │   ├── model/User.java
        │   ├── dao/IUserDAO.java
        │   ├── dao/UserDAO.java
        │   └── controller/UserServlet.java
        └── webapp/
            ├── WEB-INF/web.xml
            ├── user/ (list.jsp, create.jsp, edit.jsp, delete.jsp)
            └── assets/styles.css
```

**Chạy:** (1) trong MySQL Workbench chạy `database/init.sql`, `database/stored_procedures.sql`, sau cùng `database/transaction_permissions.sql`. Nếu đã có `demo.users` và procedures, có thể chỉ chạy file cuối. (2) Thiết lập biến môi trường `DB_URL`, `DB_USER`, `DB_PASSWORD` phù hợp. (3) trong `user-management/` chạy `mvn clean package` (yêu cầu JDK 17 + Maven). (4) Deploy `target/user-management.war` lên Tomcat 10.1+. (5) Mở `http://localhost:8080/user-management/users?action=create`.

Ví dụ biến môi trường Windows PowerShell:

```powershell
$env:DB_URL = 'jdbc:mysql://localhost:3306/demo?useUnicode=true&characterEncoding=UTF-8'
$env:DB_USER = 'root'
$env:DB_PASSWORD = 'YOUR_MYSQL_PASSWORD'
```

> Nếu khởi chạy Tomcat bằng IDE/dịch vụ Windows, hãy cấu hình biến môi trường **trong tiến trình Tomcat** (PowerShell ở ngoài không tự truyền vào tiến trình đã chạy). Không commit mật khẩu thật vào GitHub.

## 3. Quy trình Transaction

`Connection.setAutoCommit(false)` → thêm vào `users` bằng `PreparedStatement` + `Statement.RETURN_GENERATED_KEYS` → đọc ID mới → thêm từng quyền vào `user_permission` qua **chính Connection đó** → `Connection.commit()` nếu tất cả thành công. Nếu một thao tác SQL lỗi: `Connection.rollback()` rồi **ném lại lỗi** để Servlet không redirect giả thành công. Dùng try-with-resources đóng `Connection`, `PreparedStatement`, `ResultSet`.

Form tạo User có checkbox `name="permissions"` cho 4 quyền (ID 1–4). `request.getParameterValues("permissions")` trả `String[]`, Servlet chuyển thành `int[]` và gọi `dao.addUserTransaction(user, ids)`. Không chọn quyền thì thêm User không gán quyền (mảng rỗng).

### Tại sao không dùng hai Connection?

Hai connection là hai transaction khác nhau, không đảm bảo atomic: nếu insert User thành công mà insert permission thất bại thì sẽ để lại User không có quyền. Ở dự án này transaction chạy với bảng InnoDB (cả `users`, `permission`, `user_permission`).

## 4. Đối chiếu mã chính (để CodeGym có thể chấm từ README)

**Interface**:

```java
void addUserTransaction(User user, int[] permissionIds) throws SQLException;
```

**DAO — đoạn trọng tâm (xem full file `user-management/src/main/java/com/codegym/dao/UserDAO.java`)**:

```java
try (Connection con = getConnection()) {
    con.setAutoCommit(false);
    try {
        try (PreparedStatement ps = con.prepareStatement(
                SQL_INSERT, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getCountry());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("Không tìm thấy ID mới");
                int userId = keys.getInt(1);
                // Dùng chính con chuẩn bị INSERT user_permission cho từng permissionId.
            }
        }
        con.commit();
    } catch (SQLException | RuntimeException e) {
        try { con.rollback(); } catch (SQLException re) { e.addSuppressed(re); }
        throw e;
    }
}
```

**Controller — code từ form**:

```java
String[] checked = req.getParameterValues("permissions");
int[] ids = new int[checked == null ? 0 : checked.length];
for (int i = 0; i < ids.length; i++) {
    ids[i] = Integer.parseInt(checked[i]);
}
// Sau bước validate: thay gọi insertUserStore bằng
userDAO.addUserTransaction(newUser, ids);
```

**JSP — checkbox**:

```jsp
<label><input type="checkbox" name="permissions" value="1"> Thêm (Add)</label>
<label><input type="checkbox" name="permissions" value="2"> Sửa (Edit)</label>
<label><input type="checkbox" name="permissions" value="3"> Xoá (Delete)</label>
<label><input type="checkbox" name="permissions" value="4"> Xem (View)</label>
```

**SQL — cấu trúc bảng**:

```sql
CREATE TABLE IF NOT EXISTS permission (
  id INT PRIMARY KEY,
  name VARCHAR(50) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS user_permission (
  user_id INT NOT NULL,
  permission_id INT NOT NULL,
  PRIMARY KEY(user_id, permission_id),
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(permission_id) REFERENCES permission(id)
) ENGINE=InnoDB;
```

## 5. Quy trình kiểm tra bằng MySQL

1. Vào `http://localhost:8080/user-management/users?action=create`, thêm `Nguyễn Văn A / a@gmail.com / VN`, chọn **Add** và **View**, nhấn lưu.
2. Chạy `database/verify_transaction.sql`: trong `users` có 1 User mới, `user_permission` có cặp `(user_id, 1)` và `(user_id, 4)`.
3. Kiểm thử rollback có chủ đích bằng cách gọi `UserDAO.addUserTransaction(new User("Rollback Demo", "rollback@example.com", "VN"), new int[]{1, 999})` trong **bài test Java** (không thử bằng giao diện vì form chỉ nhận 1–4). FK `permission_id=999` phải ném `SQLException`; truy vấn `SELECT ... WHERE email='rollback@example.com'` phải ra 0 dòng.
4. Thử lại tính năng sửa (Stored Procedure), xóa, tìm country, sort A–Z/Z–A để kiểm tra hồi quy.

**Giới hạn kiểm thử:** Phải thử trên MySQL + Tomcat thật của người học mới chứng minh được transaction thực sự commit/rollback trong InnoDB. Các kiểm tra mock không thay thế bước nghiệm thu này.

## 6. Kiến thức rút ra

- **Commit:** xác nhận toàn bộ tác động SQL trong transaction.
- **Rollback:** hủy tất cả tác động chưa commit sau khi một phần thao tác gặp lỗi.
- **Atomicity:** không có trạng thái User được thêm nhưng permission bị thiếu do một giao dịch thất bại.
- **Auto-commit:** mặc định thường bật, phải tắt trước khi bắt đầu nhóm thao tác phụ thuộc.
- **SQLException:** không được chỉ `printStackTrace()` rồi redirect như thể thành công.
- **Bảo mật:** SQL dùng `PreparedStatement` tham số hóa; không commit thông tin kết nối thực vào repo; đây là bài CRUD minh họa, chưa có authentication/authorization thực tế.

## 7. Kết quả kiểm thử kỹ thuật

- **44/44 assertions** qua test DAO/Connection/PreparedStatement dùng proxy, 8 kịch bản.
- **14/14 assertions** qua test Controller Servlet mô phỏng.
- Tổng cộng **58/58 assertions**; xem `user-management/tests/README.md` để chạy lại.
- Java 17 biên dịch thành công với Servlet stubs. **Chưa chạy Maven WAR/Tomcat/MySQL thật** trong môi trường tạo bài.

## 8. Mã nguồn nộp bài đầy đủ (dễ xem trên GitHub)

Dưới đây là **nội dung các file thực tế**. Mã này để minh họa trực tiếp toàn bộ phần Transaction, có thể đối chiếu với project trong thư mục `user-management`.

### Interface — IUserDAO.java

```java
package com.codegym.dao;

import com.codegym.model.User;
import java.sql.SQLException;
import java.util.List;

/** Thao tác JDBC trên bảng demo.users. */
public interface IUserDAO {
    void insertUser(User user) throws SQLException;
    User selectUser(int id) throws SQLException;
    List<User> selectAllUsers() throws SQLException;
    boolean deleteUser(int id) throws SQLException;
    boolean updateUser(User user) throws SQLException;

    /** Tìm user theo ID qua Stored Procedure get_user_by_id. */
    User getUserById(int id) throws SQLException;

    /** Thêm user qua Stored Procedure insert_user. */
    void insertUserStore(User user) throws SQLException;

    /**
     * Tạo một User và tất cả quyền được chọn trong CÙNG một JDBC transaction.
     * Nếu INSERT nào thất bại thì rollback, đồng thời ném SQLException cho Controller.
     * Mảng quyền rỗng hoặc null: tạo User không gán quyền.
     */
    void addUserTransaction(User user, int[] permissionIds) throws SQLException;

    /** Tìm theo một phần tên quốc gia, sắp xếp tên asc hoặc desc. */
    List<User> searchAndSort(String country, String sort) throws SQLException;
}
```

### DAO — UserDAO.java

```java
package com.codegym.dao;

import com.codegym.model.User;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** MySQL JDBC: truy vấn có tham số, kết nối đóng bằng try-with-resources. */
public class UserDAO implements IUserDAO {
    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/demo?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh";
    private static final String SQL_INSERT =
            "INSERT INTO users (name, email, country) VALUES (?, ?, ?)";
    private static final String SQL_FIND =
            "SELECT id, name, email, country FROM users WHERE id = ?";
    private static final String SQL_UPDATE =
            "UPDATE users SET name = ?, email = ?, country = ? WHERE id = ?";
    private static final String SQL_DELETE = "DELETE FROM users WHERE id = ?";

    /** Không lưu mật khẩu thật trong source; đọc từ biến môi trường. */
    protected Connection getConnection() throws SQLException {
        String url = getenvOrDefault("DB_URL", DEFAULT_URL);
        String username = getenvOrDefault("DB_USER", "root");
        String password = System.getenv("DB_PASSWORD");
        return DriverManager.getConnection(url, username, password == null ? "" : password);
    }

    private static String getenvOrDefault(String key, String fallback) {
        String value = System.getenv(key);
        return value == null || value.isBlank() ? fallback : value;
    }

    private static User readUser(ResultSet rs) throws SQLException {
        return new User(rs.getInt("id"), rs.getString("name"),
                rs.getString("email"), rs.getString("country"));
    }

    @Override
    public void insertUser(User user) throws SQLException {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(SQL_INSERT)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getCountry());
            ps.executeUpdate();
        }
    }

    /**
     * Dùng Stored Procedure get_user_by_id thay cho SELECT trực tiếp.
     * Procedure mẫu trả về name/email/country; id giữ từ đối số truyền vào.
     */
    @Override
    public User getUserById(int id) throws SQLException {
        String call = "{CALL get_user_by_id(?)}";
        try (Connection con = getConnection();
             CallableStatement cs = con.prepareCall(call)) {
            cs.setInt(1, id);
            try (ResultSet rs = cs.executeQuery()) {
                return rs.next() ? new User(id, rs.getString("name"),
                        rs.getString("email"), rs.getString("country")) : null;
            }
        }
    }

    /** Thêm mới bằng Stored Procedure có ba tham số IN. */
    @Override
    public void insertUserStore(User user) throws SQLException {
        String call = "{CALL insert_user(?, ?, ?)}";
        try (Connection con = getConnection();
             CallableStatement cs = con.prepareCall(call)) {
            cs.setString(1, user.getName());
            cs.setString(2, user.getEmail());
            cs.setString(3, user.getCountry());
            cs.executeUpdate();
        }
    }

    /**
     * Atomic INSERT: users + user_permission phải thành công hoặc thất bại cùng nhau.
     * Dùng đúng MỘT connection với InnoDB và PreparedStatement.
     * Không nuốt SQLException: Controller chỉ redirect sau khi commit thành công.
     */
    @Override
    public void addUserTransaction(User user, int[] permissionIds) throws SQLException {
        if (user == null) {
            throw new IllegalArgumentException("User không được null");
        }
        int[] selected = permissionIds == null ? new int[0] : permissionIds;
        final String sqlAssign =
                "INSERT INTO user_permission (user_id, permission_id) VALUES (?, ?)";

        try (Connection con = getConnection()) {
            con.setAutoCommit(false);
            try {
                int newUserId;
                try (PreparedStatement ps = con.prepareStatement(
                        SQL_INSERT, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, user.getName());
                    ps.setString(2, user.getEmail());
                    ps.setString(3, user.getCountry());
                    if (ps.executeUpdate() != 1) {
                        throw new SQLException("Không tạo được User mới");
                    }
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("MySQL không trả ID cho User mới");
                        }
                        newUserId = keys.getInt(1);
                    }
                }

                if (selected.length > 0) {
                    try (PreparedStatement ps = con.prepareStatement(sqlAssign)) {
                        for (int permissionId : selected) {
                            ps.setInt(1, newUserId);
                            ps.setInt(2, permissionId);
                            if (ps.executeUpdate() != 1) {
                                throw new SQLException("Không gán được quyền: " + permissionId);
                            }
                        }
                    }
                }
                con.commit();
            } catch (SQLException | RuntimeException failure) {
                try {
                    con.rollback();
                } catch (SQLException rollbackError) {
                    failure.addSuppressed(rollbackError);
                }
                throw failure;
            }
            // Connection là kết nối riêng, đóng ngay sau transaction.
            // Không bật autoCommit=true khi rollback thất bại vì thao tác đó
            // có thể vô tình commit giao dịch chưa được hoàn tác.
        }
    }

    @Override
    public User selectUser(int id) throws SQLException {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(SQL_FIND)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? readUser(rs) : null;
            }
        }
    }

    @Override
    public List<User> selectAllUsers() throws SQLException {
        return searchAndSort("", "asc");
    }

    /**
     * @param country Từ khóa (chứa trong tên country); rỗng = tất cả.
     * @param sort asc hoặc desc. Chỉ chọn 2 hằng SQL an toàn (không nối input tự do).
     */
    @Override
    public List<User> searchAndSort(String country, String sort) throws SQLException {
        String keyword = country == null ? "" : country.trim();
        boolean filtered = !keyword.isEmpty();
        boolean descending = "desc".equalsIgnoreCase(sort);
        String sql = "SELECT id, name, email, country FROM users"
                + (filtered ? " WHERE LOWER(country) LIKE ? ESCAPE '!'" : "")
                + " ORDER BY name " + (descending ? "DESC" : "ASC") + ", id ASC";
        List<User> users = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (filtered) {
                String escaped = keyword.toLowerCase(Locale.ROOT)
                        .replace("!", "!!").replace("%", "!%").replace("_", "!_");
                ps.setString(1, "%" + escaped + "%");
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(readUser(rs));
                }
            }
        }
        return users;
    }

    @Override
    public boolean updateUser(User user) throws SQLException {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(SQL_UPDATE)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getCountry());
            ps.setInt(4, user.getId());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean deleteUser(int id) throws SQLException {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(SQL_DELETE)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}
```

### Controller — UserServlet.java

```java
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
            } else if ("create".equals(action)) {
                forward(req, resp, "/user/create.jsp");
            } else if ("edit".equals(action) || "delete".equals(action)) {
                Integer id = parseId(req.getParameter("id"));
                if (id == null) {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
                    return;
                }
                // Edit sử dụng Stored Procedure; Delete giữ JDBC cũ.
                User user = "edit".equals(action)
                        ? dao.getUserById(id) : dao.selectUser(id);
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
                default:
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thao tác không hợp lệ");
            }
        } catch (SQLException ex) {
            throw new ServletException("Không ghi được dữ liệu MySQL", ex);
        }
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
        if (edit && dao.selectUser(id) == null) {
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
            dao.updateUser(user);
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
        if (!dao.deleteUser(id)) {
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
```

### View — create.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Thêm User</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css"></head>
<body><header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a></div></header>
<main class="container form-page"><a class="back" href="${pageContext.request.contextPath}/users">← Trở về danh sách</a>
<section class="panel form-panel"><span class="section-tag">TẠO MỚI</span><h1>Thêm người dùng</h1><p>Thông tin và quyền được ghi trong một transaction MySQL (thành công hoặc rollback cùng nhau).</p>
<c:if test="${not empty error}"><div class="alert" role="alert"><c:out value="${error}"/></div></c:if>
<form action="${pageContext.request.contextPath}/users?action=create" method="post">
<label class="field" for="name">Họ tên <span class="required">*</span><input id="name" name="name" type="text" maxlength="120" required value="<c:out value='${user.name}'/>"></label>
<label class="field" for="email">Email <span class="required">*</span><input id="email" name="email" type="email" maxlength="220" required value="<c:out value='${user.email}'/>"></label>
<label class="field" for="country">Quốc gia<input id="country" name="country" type="text" maxlength="120" value="<c:out value='${user.country}'/>"></label>
<fieldset class="permission-fieldset">
<legend>Quyền hạn (Permissions)</legend>
<p class="permissions-hint">Chọn các quyền để gán cùng lúc với việc tạo User (có thể bỏ trống).</p>
<div class="permission-options">
<label class="permission-item"><input type="checkbox" name="permissions" value="1"> Thêm (Add)</label>
<label class="permission-item"><input type="checkbox" name="permissions" value="2"> Sửa (Edit)</label>
<label class="permission-item"><input type="checkbox" name="permissions" value="3"> Xoá (Delete)</label>
<label class="permission-item"><input type="checkbox" name="permissions" value="4"> Xem (View)</label>
</div>
</fieldset>
<div class="form-actions"><button class="button primary" type="submit">Lưu người dùng</button><a class="button ghost" href="${pageContext.request.contextPath}/users">Hủy</a></div>
</form></section></main></body></html>
```

### SQL — transaction_permissions.sql

```sql
-- BAI THUC HANH JDBC TRANSACTION: USERS + PERMISSIONS
-- Chay SAU database/init.sql (va database/stored_procedures.sql neu muon dung tinh nang cu).
-- Hai bang duoi day PHAI la InnoDB de COMMIT/ROLLBACK hoat dong.
CREATE DATABASE IF NOT EXISTS demo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE demo;

CREATE TABLE IF NOT EXISTS permission (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_permission (
    user_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (user_id, permission_id),
    CONSTRAINT fk_user_permission_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_permission_permission
        FOREIGN KEY (permission_id) REFERENCES permission(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Upsert giu nguyen ID va khong nhan doi khi chay lai.
INSERT INTO permission (id, name) VALUES
    (1, 'add'), (2, 'edit'), (3, 'delete'), (4, 'view')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Xac minh storage engine (quan trong: rollback phu thuoc InnoDB)
SELECT table_name, engine FROM information_schema.tables
WHERE table_schema='demo' AND table_name IN ('users', 'permission', 'user_permission');
SELECT * FROM permission ORDER BY id;
```
