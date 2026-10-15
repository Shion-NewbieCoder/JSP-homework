package com.codegym.dao;

import com.codegym.model.User;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;
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

    // Môi trường thực hành: thao tác trên duy nhất bảng demo.Employee.
    private static final String SQL_EMPLOYEE_DROP = "DROP TABLE IF EXISTS Employee";
    private static final String SQL_EMPLOYEE_CREATE =
            "CREATE TABLE Employee ("
                    + "id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "name VARCHAR(120) NOT NULL, "
                    + "salary DECIMAL(15,2) NOT NULL, "
                    + "created_Date DATETIME) ENGINE=InnoDB";
    private static final String SQL_EMPLOYEE_INSERT =
            "INSERT INTO Employee (name, salary, created_Date) VALUES (?, ?, ?)";
    private static final String SQL_EMPLOYEE_UPDATE =
            "UPDATE Employee SET salary=? WHERE name=?";

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

    /**
     * THÍ NGHIỆM CỐ TÌNH SAI, KHÔNG DÙNG TRONG PRODUCTION.
     *
     * <p>Vì không gọi setAutoCommit(false), mặc định hai INSERT được
     * auto-commit riêng rẽ. Sau đó UPDATE thiếu tham số thứ nhất và
     * thất bại, cho thấy hai INSERT vẫn nằm trong CSDL.
     *
     * <p>CHÚ Ý: DROP + CREATE sẽ xóa dữ liệu cũ trong bảng Employee!
     * Chỉ chạy trên database demo và không dùng trên bảng đang khai thác.
     * SQLException phải truyền lên Servlet để người học nhìn thấy lỗi.
     */
    @Override
    public void insertUpdateWithoutTransaction() throws SQLException {
        try (Connection con = getConnection()) {
            if (!con.getAutoCommit()) {
                throw new SQLException("Demo yêu cầu JDBC autoCommit=true");
            }

            // DDL MySQL implicit commit; chỉ reset bảng Employee để tạo
            // dữ liệu thí nghiệm sạch trước mỗi lượt chạy.
            try (Statement ddl = con.createStatement()) {
                ddl.execute(SQL_EMPLOYEE_DROP);
                ddl.execute(SQL_EMPLOYEE_CREATE);
            }

            try (PreparedStatement psInsert = con.prepareStatement(SQL_EMPLOYEE_INSERT);
                 PreparedStatement psUpdate = con.prepareStatement(SQL_EMPLOYEE_UPDATE)) {
                psInsert.setString(1, "Quynh");
                psInsert.setBigDecimal(2, new BigDecimal("10"));
                psInsert.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
                psInsert.executeUpdate();  // đã lưu vì auto-commit

                psInsert.setString(1, "Ngan");
                psInsert.setBigDecimal(2, new BigDecimal("20"));
                psInsert.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
                psInsert.executeUpdate();  // đã lưu vì auto-commit

                // LỖI CÓ CHỦ ĐÍCH: parameter 1 (salary) không được set.
                // Cặp lệnh này đều tác động parameter 2 (name).
                psUpdate.setBigDecimal(2, new BigDecimal("999.99"));
                psUpdate.setString(2, "Quynh");
                psUpdate.executeUpdate(); // SQLException: No value specified for parameter 1
            }
        }
    }

    /**
     * BÀI THỰC HÀNH: 2 INSERT + 1 UPDATE là MỘT GIAO DỊCH.
     * Mặc định thử kịch bản UPDATE sai tham số để quan sát ROLLBACK.
     * Chú ý: không chạy DROP/CREATE TABLE bên trong transaction, vì MySQL DDL
     * kích hoạt implicit commit. Cần reset bảng Employee bằng script SQL riêng.
     *
     * @throws SQLException lỗi có chủ ý khi thiếu tham số #1 hoặc lỗi thật của JDBC
     */
    @Override
    public void insertUpdateUseTransaction() throws SQLException {
        insertUpdateUseTransaction(true);
    }

    /**
     * @param failUpdate true: thiếu tham số 1 để tạo lỗi; false: UPDATE hợp lệ.
     * Cả hai kịch bản đều chạy trên bảng demo.Employee đã có sẵn.
     */
    @Override
    public void insertUpdateUseTransaction(boolean failUpdate) throws SQLException {
        try (Connection con = getConnection()) {
            // Thay vì dựa vào close() tự rollback, chủ động điều khiển transaction.
            con.setAutoCommit(false);
            try {
                try (PreparedStatement psInsert = con.prepareStatement(SQL_EMPLOYEE_INSERT);
                     PreparedStatement psUpdate = con.prepareStatement(SQL_EMPLOYEE_UPDATE)) {

                    psInsert.setString(1, "Quynh");
                    psInsert.setBigDecimal(2, new BigDecimal("10.00"));
                    psInsert.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
                    if (psInsert.executeUpdate() != 1) {
                        throw new SQLException("INSERT Quynh không ghi đúng 1 dòng");
                    }

                    psInsert.setString(1, "Ngan");
                    psInsert.setBigDecimal(2, new BigDecimal("20.00"));
                    psInsert.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
                    if (psInsert.executeUpdate() != 1) {
                        throw new SQLException("INSERT Ngan không ghi đúng 1 dòng");
                    }

                    if (failUpdate) {
                        // LỖI CÓ CHỦ ĐÍCH: parameter 1 (salary) chưa được gán.
                        psUpdate.setBigDecimal(2, new BigDecimal("999.99"));
                    } else {
                        // LẦN CHẠY 2: sửa index từ 2 thành 1.
                        psUpdate.setBigDecimal(1, new BigDecimal("999.99"));
                    }
                    psUpdate.setString(2, "Quynh");
                    if (psUpdate.executeUpdate() != 1) {
                        throw new SQLException("UPDATE Quynh không sửa đúng 1 dòng");
                    }
                }
                // Commit duy nhất sau KHI tất cả các câu lệnh đều thành công.
                con.commit();
            } catch (SQLException | RuntimeException failure) {
                // Không giả định close() luôn rollback. Explicit rollback.
                try {
                    con.rollback();
                } catch (SQLException rollbackError) {
                    failure.addSuppressed(rollbackError);
                }
                throw failure;
            }
            // Connection riêng được đóng ở đây, không tái sử dụng trong pool.
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
