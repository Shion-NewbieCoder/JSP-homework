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
