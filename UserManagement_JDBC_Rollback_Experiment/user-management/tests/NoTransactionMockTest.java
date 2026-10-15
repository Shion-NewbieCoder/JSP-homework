import com.codegym.dao.UserDAO;
import java.math.BigDecimal;
import java.lang.reflect.Proxy;
import java.sql.*;
import java.util.*;

/** Mô phỏng chính xác cơ chế auto-commit để kiểm tra luồng Java (không thay MySQL thật). */
public class NoTransactionMockTest {
    static class DB {
        final List<String> calls = new ArrayList<>();
        final Map<String, BigDecimal> persisted = new LinkedHashMap<>();
        int conClose = 0;
        int insertCalls = 0;
        int commitCalls = 0;
        int rollbackCalls = 0;
        int updateCalls = 0;
        boolean autocommitDisabled = false;
        boolean failCreate = false;

        static Object primitive(Class<?> type) {
            if (type.equals(boolean.class)) return false;
            if (type.equals(int.class)) return 0;
            if (type.equals(long.class)) return 0L;
            return null;
        }
        PreparedStatement prepared(String sql) {
            Map<Integer,Object> values = new HashMap<>();
            boolean insert = sql.startsWith("INSERT INTO Employee");
            if (!insert && !sql.startsWith("UPDATE Employee")) throw new AssertionError("Unexpected SQL: " + sql);
            return (PreparedStatement) Proxy.newProxyInstance(
                    getClass().getClassLoader(), new Class<?>[]{PreparedStatement.class}, (p,m,a)-> {
                String method = m.getName();
                switch (method) {
                    case "setString": case "setBigDecimal": case "setTimestamp":
                        values.put((Integer)a[0], a[1]);
                        return null;
                    case "executeUpdate":
                        if (insert) {
                            if (!values.keySet().containsAll(List.of(1,2,3)))
                                throw new SQLException("Missing INSERT params");
                            String name=(String)values.get(1);
                            persisted.put(name, (BigDecimal)values.get(2));
                            insertCalls++;
                            calls.add("INSERT:"+name);
                            return 1;
                        }
                        updateCalls++;
                        calls.add("UPDATE:attempted");
                        if (!values.containsKey(1)) throw new SQLException("No value specified for parameter 1");
                        persisted.put((String)values.get(2), (BigDecimal)values.get(1));
                        return 1;
                    case "close": return null;
                    default: return primitive(m.getReturnType());
                }
            });
        }
        Statement statement() {
            return (Statement) Proxy.newProxyInstance(getClass().getClassLoader(),new Class<?>[]{Statement.class},(p,m,a)->{
                switch (m.getName()) {
                    case "execute":
                        String sql=(String)a[0];
                        calls.add(sql.startsWith("DROP") ? "DROP" : "CREATE");
                        if (sql.startsWith("DROP")) persisted.clear();
                        if (failCreate && sql.startsWith("CREATE")) throw new SQLException("DDL error");
                        return false;
                    case "close": return null;
                    default: return primitive(m.getReturnType());
                }
            });
        }
        Connection connection() {
            return (Connection) Proxy.newProxyInstance(getClass().getClassLoader(),new Class<?>[]{Connection.class},(p,m,a)->{
                switch(m.getName()) {
                    case "getAutoCommit":return true;
                    case "setAutoCommit":autocommitDisabled |= Boolean.FALSE.equals(a[0]);return null;
                    case "createStatement": return statement();
                    case "prepareStatement":return prepared((String)a[0]);
                    case "commit":commitCalls++;return null;
                    case "rollback":rollbackCalls++;return null;
                    case "close":conClose++;return null;
                    default:return primitive(m.getReturnType());
                }
            });
        }
    }
    static class FakeDAO extends UserDAO {
        DB db;
        FakeDAO(DB db) { this.db=db; }
        @Override protected Connection getConnection() { return db.connection(); }
    }
    static int checks=0;
    static void ok(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
        checks++;
        System.out.println("PASS: "+message);
    }
    public static void main(String[] args) throws Exception {
        DB db = new DB();
        try {
            new FakeDAO(db).insertUpdateWithoutTransaction();
            throw new AssertionError("UPDATE cần ném SQLException");
        } catch (SQLException expected) {
            ok(expected.getMessage().contains("parameter 1"), "UPDATE sai tham số ném đúng SQLException");
        }
        ok(db.insertCalls==2, "Đã thực thi chính xác hai INSERT");
        ok(db.persisted.size()==2, "Hai dòng còn lại sau UPDATE thất bại");
        ok(new BigDecimal("10").compareTo(db.persisted.get("Quynh"))==0, "Quynh có salary 10");
        ok(new BigDecimal("20").compareTo(db.persisted.get("Ngan"))==0, "Ngan có salary 20");
        ok(db.updateCalls==1, "UPDATE được gọi và bị lỗi");
        ok(db.commitCalls==0, "Không gọi commit thủ công");
        ok(db.rollbackCalls==0, "Không gọi rollback");
        ok(!db.autocommitDisabled, "Không tắt auto-commit");
        ok(db.conClose==1, "Connection được đóng");
        ok(db.calls.equals(List.of("DROP","CREATE","INSERT:Quynh","INSERT:Ngan","UPDATE:attempted")),
                "Đúng thứ tự DDL, INSERT, UPDATE");
        DB failed=new DB();failed.failCreate=true;
        try {new FakeDAO(failed).insertUpdateWithoutTransaction();throw new AssertionError("DDL phải fail");}
        catch(SQLException e) {ok("DDL error".equals(e.getMessage()),"Lỗi CREATE TABLE truyền lên caller");}
        ok(failed.insertCalls==0,"DDL thất bại không tiến hành INSERT");
        ok(failed.conClose==1,"Lỗi DDL vẫn đóng Connection");
        System.out.println("TOTAL PASSED="+checks);
    }
}
