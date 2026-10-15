# User Management — JDBC Stored Procedures / CallableStatement

Ứng dụng Java Web JSP/Servlet theo mô hình MVC, **nâng cấp từ bài `UserManagement_JDBC_SearchSort`**. Hai chức năng **tìm User theo ID** và **thêm mới User** đã chuyển sang MySQL Stored Procedures, không làm mất các chức năng cũ.

## Tính năng

| Thao tác | Địa chỉ / Tầng xử lý | Cách truy cập DB |
|---|---|---|
| Danh sách & lọc `country` | `GET /users?country=Viet` | `PreparedStatement` (`LIKE ?`) |
| Sắp xếp `name` | `GET /users?sort=asc` / `desc` | `ORDER BY name ASC/DESC` (giá trị sort được giới hạn) |
| Thêm User | `POST /users?action=create` | **`CallableStatement` → `insert_user(?, ?, ?)`** |
| Mở form sửa User | `GET /users?action=edit&id=1` | **`CallableStatement` → `get_user_by_id(?)`** |
| Lưu nội dung sửa | `POST /users?action=edit` | `PreparedStatement` UPDATE (giữ như bài trước) |
| Xóa User | `POST /users?action=delete` | `PreparedStatement` DELETE (giữ như bài trước) |

**Luồng MVC:** JSP (`list.jsp`, `create.jsp`, `edit.jsp`, `delete.jsp`) → `UserServlet` → `IUserDAO`/`UserDAO` → MySQL (`demo.users`) → forward/redirect JSP. Form tạo/sửa/xóa dùng POST, và sau khi ghi dữ liệu thành công Servlet redirect về `/users` (Post/Redirect/Get).

## Cấu trúc dự án

```text
UserManagement_JDBC_StoredProcedures/
├── README.md
├── preview-desktop.png, preview-mobile.png, ...
└── user-management/
    ├── pom.xml
    ├── README.md
    ├── database/
    │   ├── init.sql
    │   ├── stored_procedures.sql   # TẠO 2 PROCEDURES
    │   └── query_examples.sql
    └── src/main/
        ├── java/com/codegym/
        │   ├── model/User.java
        │   ├── dao/IUserDAO.java
        │   ├── dao/UserDAO.java
        │   └── controller/UserServlet.java
        └── webapp/
            ├── index.jsp
            ├── error-404.jsp
            ├── assets/styles.css
            ├── WEB-INF/web.xml
            └── user/{list,create,edit,delete}.jsp
```

## Hướng dẫn chạy trên Windows / VS Code / IntelliJ

**Yêu cầu:** JDK 17 trở lên; Maven; Apache Tomcat 10.1+; MySQL 8.x.

**1. Khởi tạo DB:** Mở MySQL Workbench và chạy `user-management/database/init.sql`, sau đó chạy **`user-management/database/stored_procedures.sql`**. Thứ tự quan trọng: bảng `users` phải tồn tại trước khi tạo/call thủ tục. Hai procedure được `DROP IF EXISTS` rồi tạo lại để chạy lại script trên môi trường thực hành. Không làm vậy nếu bạn có thay đổi procedure riêng trên CSDL khác.

Xác minh trực tiếp trong MySQL Workbench:

```sql
USE demo;
SHOW PROCEDURE STATUS WHERE Db = 'demo';
CALL get_user_by_id(1);
-- Tùy chọn: kiểm tra chèn một User thực sự vào DB
-- CALL insert_user('Linh', 'linh@example.com', 'Viet Nam');
-- SELECT * FROM users ORDER BY id DESC;
```

**2. Cấu hình tài khoản DB:** `UserDAO` đọc biến môi trường `DB_URL`, `DB_USER`, `DB_PASSWORD`; **không lưu mật khẩu trong mã nguồn**. Trên PowerShell trước khi khởi động Tomcat từ cùng môi trường:

```powershell
$env:DB_URL = 'jdbc:mysql://localhost:3306/demo?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh'
$env:DB_USER = 'root'
$env:DB_PASSWORD = 'mat-khau-mysql-cua-ban'
```

Khi Tomcat chạy dưới một chương trình dịch vụ/IDE khác, cần cấu hình các biến trong chính môi trường chạy của Tomcat. Không commit mật khẩu lên GitHub. Nếu tài khoản root không có mật khẩu, ứng dụng mặc định dùng chuỗi rỗng.

**3. Maven build:** Mở terminal tại `user-management/` (cùng cấp `pom.xml`):

```powershell
mvn clean package
```

**4. Deploy:** Copy `target/user-management.war` vào `webapps/` của Tomcat 10.1, sau đó start/redeploy. Mở `http://localhost:8080/user-management/users`. URL là **`/user-management/users`**, không phải `/users` ở gốc Tomcat. Sau thay đổi Java, cần build WAR và deploy lại.

**5. Test tay:** Thêm 1 user (kiểm tra qua `SELECT * FROM demo.users`), mở Edit user vừa thêm (đảm bảo dữ liệu cũ hiển thị), sửa, lọc country, đổi sort A–Z/Z–A và xóa (có form xác nhận). Nếu báo lỗi SQL `PROCEDURE demo.get_user_by_id does not exist` thì chạy lại `stored_procedures.sql` trong đúng database `demo`.

## Điểm kỹ thuật & khác biệt với bài cũ

- `PreparedStatement` gửi câu SQL có tham số được chuẩn bị từ Java (vẫn sử dụng cho lọc, sửa và xóa).
- `CallableStatement` gọi thủ tục đã được tạo trong MySQL. `prepareCall("{CALL get_user_by_id(?)}")` đặt tham số ID tại vị trí 1; thủ tục này trả về `name`, `email`, `country`, nên Java dùng `id` ban đầu để xây đối tượng `User`.
- `prepareCall("{CALL insert_user(?, ?, ?)}")` nhận lần lượt `name`, `email`, `country` và gọi `executeUpdate()`.
- Dùng `try-with-resources` để đóng Connection, CallableStatement và ResultSet, kể cả lúc có exception.
- Hai procedure mẫu dùng tham số dài `VARCHAR(120)`, `VARCHAR(220)`, `VARCHAR(120)` **khớp các trường trong `demo.users`**; tài liệu lớp dùng `VARCHAR(50)` cho cả 3 trường nhưng có thể làm lỗi/cắt dữ liệu hợp lệ dài hơn 50 ký tự.
- Phải chạy thủ tục **trên MySQL thật** trước khi mở form Edit hoặc thêm User; chỉ có file Java thì không đủ.

## Kiểm thử và giới hạn

- **10/10** kiểm thử mô phỏng JDBC `CallableStatement`: chuỗi CALL, thứ tự tham số, User có/không có, đóng tài nguyên và truyền SQLException.
- **11/11** kiểm thử mô phỏng luồng Servlet: GET Edit, POST Create, POST Edit, GET List với country/sort, GET Delete và dữ liệu lỗi.
- Biên dịch Model/DAO bằng `javac --release 17`; biên dịch Servlet qua các interface Jakarta mô phỏng; `pom.xml`, `web.xml` hợp lệ và ZIP kiểm tra được.
- **Chưa thực hiện `mvn clean package` hoặc chạy tích hợp với MySQL/Tomcat thật** trong môi trường tạo bài; cần kiểm tra trên máy nộp. Ảnh preview kế thừa từ bài SearchSort vì bố cục giao diện không thay đổi.

## Mã nguồn quan trọng (để đọc trực tiếp từ link README)

Người chấm có thể kiểm tra đầy đủ các cập nhật SQL, Interface, DAO, Servlet và JSP tại đây; các file thực thi gốc vẫn nằm ở đường dẫn nêu trên.

### MySQL — stored_procedures.sql

```sql
-- BAI THUC HANH: JDBC CALLABLESTATEMENT + MYSQL STORED PROCEDURES
-- Chay database/init.sql truoc, sau do chay file nay trong MySQL Workbench.
-- DROP IF EXISTS de co the chay lai script trong moi truong thuc hanh.
USE demo;

DELIMITER $$
DROP PROCEDURE IF EXISTS get_user_by_id$$
CREATE PROCEDURE get_user_by_id(IN user_id INT)
BEGIN
    SELECT users.name, users.email, users.country
    FROM users
    WHERE users.id = user_id;
END$$

DROP PROCEDURE IF EXISTS insert_user$$
CREATE PROCEDURE insert_user(
    IN user_name VARCHAR(120),
    IN user_email VARCHAR(220),
    IN user_country VARCHAR(120)
)
BEGIN
    INSERT INTO users(name, email, country)
    VALUES (user_name, user_email, user_country);
END$$
DELIMITER ;

-- Kiểm tra danh sách procedures sau khi tạo.
SHOW PROCEDURE STATUS WHERE Db = 'demo';
-- Thu nghiem thu cong (khong bat buoc):
-- CALL get_user_by_id(1);
-- CALL insert_user('Tester', 'tester@example.com', 'Viet Nam');
-- SELECT * FROM users ORDER BY id DESC;
```

### IUserDAO.java

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

    /** Tìm theo một phần tên quốc gia, sắp xếp tên asc hoặc desc. */
    List<User> searchAndSort(String country, String sort) throws SQLException;
}
```

### UserDAO.java

```java
package com.codegym.dao;

import com.codegym.model.User;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

### UserServlet.java

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
            // Chuyển thao tác thêm mới sang CallableStatement.
            dao.insertUserStore(user);
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

### index.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% response.sendRedirect(request.getContextPath() + "/users"); %>
```

### user/list.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Danh sách User | User Management</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css">
</head>
<body>
<header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a><span class="eyebrow">JSP · Servlet · JDBC · MySQL</span></div></header>
<main class="container page">
  <div class="page-heading">
    <div><span class="section-tag">QUẢN LÝ DỮ LIỆU</span><h1>Danh sách người dùng</h1><p>Tìm kiếm theo quốc gia và sắp xếp theo tên trực tiếp từ MySQL.</p></div>
    <a class="button primary" href="${pageContext.request.contextPath}/users?action=create">+ Thêm người dùng</a>
  </div>
  <section class="panel">
    <form class="toolbar" action="${pageContext.request.contextPath}/users" method="get" role="search">
      <label class="field search-field" for="country">Tìm theo quốc gia
        <input id="country" name="country" type="search" maxlength="120" placeholder="Ví dụ: Viet Nam, Kenia..." value="<c:out value='${countryFilter}'/>">
      </label>
      <label class="field sort-field" for="sort">Sắp xếp theo tên
        <select id="sort" name="sort">
          <c:choose>
            <c:when test="${selectedSort eq 'desc'}"><option value="asc">A → Z</option><option value="desc" selected>Z → A</option></c:when>
            <c:otherwise><option value="asc" selected>A → Z</option><option value="desc">Z → A</option></c:otherwise>
          </c:choose>
        </select>
      </label>
      <button class="button primary" type="submit">Lọc / Sắp xếp</button>
      <a class="button ghost" href="${pageContext.request.contextPath}/users">Đặt lại</a>
    </form>
    <div class="table-wrap">
      <table>
        <thead><tr><th>ID</th><th>Họ tên</th><th>Email</th><th>Quốc gia</th><th>Hành động</th></tr></thead>
        <tbody>
          <c:forEach var="user" items="${listUser}">
            <tr>
              <td class="id-col">#<c:out value="${user.id}"/></td>
              <td class="name-col"><c:out value="${user.name}"/></td>
              <td><c:out value="${user.email}"/></td>
              <td><span class="tag"><c:out value="${user.country}" default="Chưa có"/></span></td>
              <td><div class="actions">
                <a class="action edit" href="${pageContext.request.contextPath}/users?action=edit&amp;id=${user.id}">Sửa</a>
                <a class="action delete" href="${pageContext.request.contextPath}/users?action=delete&amp;id=${user.id}">Xóa</a>
              </div></td>
            </tr>
          </c:forEach>
          <c:if test="${empty listUser}"><tr><td colspan="5" class="no-results">Không tìm thấy người dùng phù hợp.</td></tr></c:if>
        </tbody>
      </table>
    </div>
    <p class="table-footer">Đang hiển thị <strong>${listUser.size()}</strong> người dùng · Dữ liệu từ bảng <code>demo.users</code></p>
  </section>
  <footer class="footer">CodeGym Java Web Practice · Model – DAO – Controller – JSP</footer>
</main>
</body>
</html>
```

### user/create.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Thêm User</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css"></head>
<body><header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a></div></header>
<main class="container form-page"><a class="back" href="${pageContext.request.contextPath}/users">← Trở về danh sách</a>
<section class="panel form-panel"><span class="section-tag">TẠO MỚI</span><h1>Thêm người dùng</h1><p>Điền thông tin, dữ liệu được lưu vào MySQL.</p>
<c:if test="${not empty error}"><div class="alert" role="alert"><c:out value="${error}"/></div></c:if>
<form action="${pageContext.request.contextPath}/users?action=create" method="post">
<label class="field" for="name">Họ tên <span class="required">*</span><input id="name" name="name" type="text" maxlength="120" required value="<c:out value='${user.name}'/>"></label>
<label class="field" for="email">Email <span class="required">*</span><input id="email" name="email" type="email" maxlength="220" required value="<c:out value='${user.email}'/>"></label>
<label class="field" for="country">Quốc gia<input id="country" name="country" type="text" maxlength="120" value="<c:out value='${user.country}'/>"></label>
<div class="form-actions"><button class="button primary" type="submit">Lưu người dùng</button><a class="button ghost" href="${pageContext.request.contextPath}/users">Hủy</a></div>
</form></section></main></body></html>
```

### user/edit.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sửa User</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css"></head>
<body><header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a></div></header>
<main class="container form-page"><a class="back" href="${pageContext.request.contextPath}/users">← Trở về danh sách</a>
<section class="panel form-panel"><span class="section-tag">CẬP NHẬT</span><h1>Chỉnh sửa người dùng</h1><p>ID #<c:out value="${user.id}"/> · Cập nhật thông tin trong MySQL.</p>
<c:if test="${not empty error}"><div class="alert" role="alert"><c:out value="${error}"/></div></c:if>
<form action="${pageContext.request.contextPath}/users?action=edit" method="post">
<input type="hidden" name="id" value="${user.id}">
<label class="field" for="name">Họ tên <span class="required">*</span><input id="name" name="name" type="text" maxlength="120" required value="<c:out value='${user.name}'/>"></label>
<label class="field" for="email">Email <span class="required">*</span><input id="email" name="email" type="email" maxlength="220" required value="<c:out value='${user.email}'/>"></label>
<label class="field" for="country">Quốc gia<input id="country" name="country" type="text" maxlength="120" value="<c:out value='${user.country}'/>"></label>
<div class="form-actions"><button class="button primary" type="submit">Lưu thay đổi</button><a class="button ghost" href="${pageContext.request.contextPath}/users">Hủy</a></div>
</form></section></main></body></html>
```

### user/delete.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Xóa User</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css"></head>
<body><header class="topbar"><div class="container topbar-inner"><a class="brand" href="${pageContext.request.contextPath}/users">◈ User<span>Manager</span></a></div></header>
<main class="container form-page"><a class="back" href="${pageContext.request.contextPath}/users">← Trở về danh sách</a>
<section class="panel form-panel"><span class="section-tag">XÁC NHẬN</span><h1>Xóa người dùng?</h1>
<div class="notice">Hành động này sẽ xóa bản ghi trong MySQL và không thể hoàn tác.</div>
<div class="detail"><strong>ID</strong><span>#<c:out value="${user.id}"/></span></div>
<div class="detail"><strong>Tên</strong><span><c:out value="${user.name}"/></span></div>
<div class="detail"><strong>Email</strong><span><c:out value="${user.email}"/></span></div>
<div class="detail"><strong>Quốc gia</strong><span><c:out value="${user.country}"/></span></div>
<form action="${pageContext.request.contextPath}/users?action=delete" method="post"><input type="hidden" name="id" value="${user.id}">
<div class="form-actions"><button class="button danger" type="submit">Xác nhận xóa</button><a class="button ghost" href="${pageContext.request.contextPath}/users">Hủy</a></div></form>
</section></main></body></html>
```

### pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.codegym</groupId>
    <artifactId>user-management</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <name>User Management MVC + JDBC Stored Procedures</name>
    <properties>
        <maven.compiler.release>17</maven.compiler.release>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    <dependencies>
        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>6.0.0</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>jakarta.servlet.jsp</groupId>
            <artifactId>jakarta.servlet.jsp-api</artifactId>
            <version>3.1.1</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>jakarta.servlet.jsp.jstl</groupId>
            <artifactId>jakarta.servlet.jsp.jstl-api</artifactId>
            <version>3.0.0</version>
        </dependency>
        <dependency>
            <groupId>org.glassfish.web</groupId>
            <artifactId>jakarta.servlet.jsp.jstl</artifactId>
            <version>3.0.1</version>
        </dependency>
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <version>8.3.0</version>
        </dependency>
    </dependencies>
    <build>
        <finalName>user-management</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.13.0</version>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.4.0</version>
            </plugin>
        </plugins>
    </build>
</project>
```

