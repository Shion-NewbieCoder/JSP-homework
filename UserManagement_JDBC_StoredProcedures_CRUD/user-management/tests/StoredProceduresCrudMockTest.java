import com.codegym.dao.UserDAO;
import com.codegym.model.User;
import java.lang.reflect.Proxy;
import java.sql.*;
import java.util.*;

/** Mock JDBC: verify 3 newly added CallableStatement flows, not a real MySQL test. */
public class StoredProceduresCrudMockTest {
    static class Recorder {
        String call;
        Map<Integer, Object> inputs = new HashMap<>();
        Set<Integer> outputs = new HashSet<>();
        int closedStatements, closedConnections, closedResults, executions;
        int outValue = 1;
        boolean throwOnExecute;
        Connection connection() {
            return (Connection) Proxy.newProxyInstance(getClass().getClassLoader(),
                new Class<?>[]{Connection.class}, (proxy, method, args) -> {
                    switch(method.getName()) {
                        case "prepareCall":
                            call = (String)args[0];
                            return statement();
                        case "close": closedConnections++; return null;
                        case "isClosed": return closedConnections > 0;
                        default: return defaultValue(method.getReturnType());
                    }
                });
        }
        CallableStatement statement() {
            return (CallableStatement) Proxy.newProxyInstance(getClass().getClassLoader(),
                new Class<?>[]{CallableStatement.class}, (proxy, method, args) -> {
                    String name = method.getName();
                    switch (name) {
                        case "setString": case "setInt": inputs.put((int)args[0],args[1]); return null;
                        case "registerOutParameter": outputs.add((int)args[0]); return null;
                        case "executeQuery": executions++; maybeThrow(); return rows();
                        case "execute": executions++; maybeThrow(); return false;
                        case "getInt": return outValue;
                        case "close": closedStatements++; return null;
                        default: return defaultValue(method.getReturnType());
                    }
                });
        }
        void maybeThrow() throws SQLException {
            if (throwOnExecute) throw new SQLException("Simulated stored procedure failure");
        }
        ResultSet rows() {
            return (ResultSet) Proxy.newProxyInstance(getClass().getClassLoader(),
                new Class<?>[]{ResultSet.class}, new java.lang.reflect.InvocationHandler() {
                    int cursor = -1;
                    public Object invoke(Object proxy,java.lang.reflect.Method method,Object[] args) {
                        switch(method.getName()) {
                            case "next": return ++cursor < 2;
                            case "getInt": return cursor + 1;
                            case "getString": {
                                String key = (String)args[0];
                                return switch(key) {
                                    case "name" -> cursor == 0 ? "Minh" : "Kante";
                                    case "email" -> cursor == 0 ? "minh@codegym.vn" : "kante@che.uk";
                                    case "country" -> cursor == 0 ? "Viet Nam" : "Kenia";
                                    default -> null;
                                };
                            }
                            case "close": closedResults++; return null;
                            default: return defaultValue(method.getReturnType());
                        }
                    }
                });
        }
    }
    static Object defaultValue(Class<?> type) {
        if (type==boolean.class) return false;
        if (type==int.class) return 0;
        if (type==long.class) return 0L;
        return null;
    }
    static class DAO extends UserDAO {
        Recorder r = new Recorder();
        @Override protected Connection getConnection() {return r.connection();}
    }
    static int checks = 0;
    static void check(boolean ok, String message) {
        if (!ok) throw new AssertionError(message);
        ++checks; System.out.println("PASS "+message);
    }
    public static void main(String[]args) throws Exception {
        DAO dao = new DAO();
        List<User> users=dao.getAllUsersStore(" Viet Nam ","DeSc");
        check(dao.r.call.equals("{CALL get_all_users(?, ?)}"),"list calls procedure");
        check("Viet Nam".equals(dao.r.inputs.get(1)),"list trims country");
        check("desc".equals(dao.r.inputs.get(2)),"list normalizes sort");
        check(users.size()==2 && users.get(0).getId()==1 && "Kante".equals(users.get(1).getName()),"list parses rows");
        check(dao.r.closedConnections==1 && dao.r.closedStatements==1 && dao.r.closedResults==1,"list closes all JDBC resources");
        dao = new DAO(); dao.selectAllUsers();
        check(dao.r.call.contains("get_all_users") && "asc".equals(dao.r.inputs.get(2)),"default list also uses SP");
        dao = new DAO(); dao.searchAndSort("Kenia","unsafe sort");
        check("asc".equals(dao.r.inputs.get(2)),"unexpected sort falls back safely");

        dao = new DAO(); boolean updated = dao.updateUserStore(new User(7,"Ana","a@example.com","VN"));
        check(updated && dao.r.call.equals("{CALL update_user(?, ?, ?, ?, ?)}"),"edit calls procedure");
        check((int)dao.r.inputs.get(1)==7 && "Ana".equals(dao.r.inputs.get(2)),"edit sends ID and fields");
        check("a@example.com".equals(dao.r.inputs.get(3))&&"VN".equals(dao.r.inputs.get(4)),"edit sends all fields");
        check(dao.r.outputs.contains(5) && dao.r.closedConnections==1,"edit reads OUT param and closes");
        dao = new DAO(); dao.r.outValue=0;
        check(!dao.updateUserStore(new User(999,"A","a@a.vn","VN")),"edit missing ID returns false");

        dao = new DAO(); check(dao.deleteUserStore(8),"delete returns true from OUT");
        check(dao.r.call.equals("{CALL delete_user(?, ?)}") && (int)dao.r.inputs.get(1)==8,"delete calls SP with ID");
        check(dao.r.outputs.contains(2) && dao.r.closedStatements==1,"delete OUT registered and resources closed");
        dao = new DAO();dao.r.outValue=0;
        check(!dao.deleteUserStore(999),"delete missing ID returns false");
        dao = new DAO();dao.r.throwOnExecute=true;
        boolean threw=false;
        try { dao.deleteUserStore(8); } catch(SQLException expected){threw=true;}
        check(threw && dao.r.closedConnections==1 && dao.r.closedStatements==1,"SQL error propagates, no fake successful delete");
        System.out.println("TOTAL PASSED="+checks);
    }
}
