import com.codegym.dao.UserDAO;
import com.codegym.model.User;
import java.sql.*;
import java.lang.reflect.*;
import java.util.*;

/** JDBC proxy tests; không kết nối MySQL thật. */
public class RollbackExperimentMockTest {
    private static int checks;
    static void ok(boolean cond, String label) {
        if (!cond) throw new AssertionError(label);
        checks++;
        System.out.println("PASS " + label);
    }
    static Object defaultValue(Class<?> type) {
        if (type == boolean.class) return false;
        if (type == int.class) return 0;
        if (type == long.class) return 0L;
        return null;
    }
    static class Database {
        int openConnections, closed, userInserts, pendingPermissions, commits, rollbacks;
        int savedUsers, savedPermissions, generatedIds = 0;
        int countQueryCalls;
        String errorEmail, insertedEmail;
        int currentPermission;
        boolean autoCommit = true;
        UserDAO dao() {
            return new UserDAO() {
                @Override protected Connection getConnection() { return connection(); }
            };
        }
        ResultSet keys() {
            return (ResultSet) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class[]{ResultSet.class}, new InvocationHandler() {
                boolean returned;
                public Object invoke(Object proxy, Method m, Object[] args) {
                    switch (m.getName()) {
                        case "next": if (returned) return false; returned = true; return true;
                        case "getInt": return 876;
                        default: return defaultValue(m.getReturnType());
                    }
                }
            });
        }
        ResultSet countRows() {
            return (ResultSet) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class[]{ResultSet.class}, new InvocationHandler() {
                boolean returned;
                public Object invoke(Object proxy, Method m, Object[] args) {
                    switch (m.getName()) {
                        case "next": if (returned) return false; returned = true; return true;
                        case "getInt": return savedUsers;
                        default: return defaultValue(m.getReturnType());
                    }
                }
            });
        }
        PreparedStatement statement(String sql) {
            return (PreparedStatement) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class[]{PreparedStatement.class}, (proxy, m, args) -> {
                switch (m.getName()) {
                    case "setString":
                        if (sql.startsWith("INSERT INTO users") && (int) args[0] == 2) {
                            insertedEmail = (String)args[1];
                        }
                        if (sql.startsWith("SELECT COUNT")) errorEmail = (String)args[1];
                        return null;
                    case "setInt":
                        if (sql.startsWith("INSERT INTO user_permission") && (int) args[0] == 2) {
                            currentPermission = (int)args[1];
                        }
                        return null;
                    case "executeUpdate":
                        if (sql.startsWith("INSERT INTO users")) { userInserts++; return 1; }
                        if (sql.startsWith("INSERT INTO user_permission")) {
                            if (currentPermission == Integer.MAX_VALUE) {
                                throw new SQLException("Cannot add or update a child row: a foreign key constraint fails", "23000", 1452);
                            }
                            pendingPermissions++;
                            return 1;
                        }
                        throw new AssertionError("unexpected SQL update " + sql);
                    case "executeQuery":
                        if (sql.startsWith("SELECT COUNT")) { countQueryCalls++; return countRows(); }
                        throw new AssertionError("unexpected SQL query " + sql);
                    case "getGeneratedKeys": generatedIds++; return keys();
                    default: return defaultValue(m.getReturnType());
                }
            });
        }
        Connection connection() {
            openConnections++;
            return (Connection) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class[]{Connection.class}, (proxy, m, args) -> {
                switch (m.getName()) {
                    case "setAutoCommit": autoCommit = (boolean)args[0]; return null;
                    case "prepareStatement": return statement((String)args[0]);
                    case "rollback": rollbacks++; pendingPermissions = 0; return null;
                    case "commit": commits++; savedUsers += userInserts; savedPermissions += pendingPermissions; return null;
                    case "close": closed++; return null;
                    default: return defaultValue(m.getReturnType());
                }
            });
        }
    }
    public static void main(String[] args) throws Exception {
        Database failed = new Database();
        String email = "tx-test-fail@example.invalid";
        SQLException error = null;
        try { failed.dao().addUserTransaction(new User("Test", email, "VN"),
                new int[]{1, Integer.MAX_VALUE}); }
        catch (SQLException ex) { error = ex; }
        ok(error != null, "SQL lỗi có chủ đích được ném ra ngoài DAO");
        ok(error.getErrorCode() == 1452 && "23000".equals(error.getSQLState()), "Mã lỗi khóa ngoại MySQL 1452");
        ok(failed.userInserts == 1, "User INSERT đã thực thi trước lỗi");
        ok(failed.generatedIds == 1, "Đã lấy ID sinh tự động");
        ok(failed.commits == 0, "Không commit khi gán quyền lỗi");
        ok(failed.rollbacks == 1, "Gọi rollback chính xác một lần");
        ok(failed.pendingPermissions == 0, "Quyền đang chờ cũng bị rollback");
        ok(failed.savedUsers == 0 && failed.savedPermissions == 0, "Không còn dữ liệu được commit");
        ok(failed.dao().countUsersByEmail(email) == 0, "Query kết nối mới thấy 0 User");
        ok(email.equals(failed.errorEmail), "SELECT COUNT dùng PreparedStatement/email chính xác");
        ok(failed.openConnections == 2 && failed.closed == 2, "Kết nối được đóng sau mỗi thao tác");

        Database success = new Database();
        String okEmail = "tx-test-ok@example.invalid";
        success.dao().addUserTransaction(new User("Test OK", okEmail, "VN"), new int[]{1,4});
        ok(success.commits == 1 && success.rollbacks == 0, "Đường hợp lệ vẫn commit");
        ok(success.savedUsers == 1 && success.savedPermissions == 2, "User và hai quyền được lưu chung");
        ok(success.dao().countUsersByEmail(okEmail) == 1, "Query kiểm tra thấy User được commit");
        System.out.println("TOTAL PASSED="+checks);
    }
}
