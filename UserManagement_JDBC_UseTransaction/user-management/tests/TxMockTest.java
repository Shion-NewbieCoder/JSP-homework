import com.codegym.dao.*;
import com.codegym.model.User;
import java.sql.*;
import java.lang.reflect.*;
import java.util.*;

public class TxMockTest {
 static class DB {
  int commits, rollbacks, closes, prepared, autoOff, assigned, inserted;
  boolean failedPermission, failKey, failCommit, failRollback, zeroInsert;
  ArrayList<String> calls = new ArrayList<>();
  Object defaultValue(Class<?> c) {
   if (c == boolean.class) return false;
   if (c == int.class) return 0;
   if (c == long.class) return 0L;
   return null;
  }
  ResultSet rs() {
   return (ResultSet)Proxy.newProxyInstance(getClass().getClassLoader(),new Class[]{ResultSet.class},new InvocationHandler(){boolean next;
     public Object invoke(Object proxy, Method m,Object[] args) {
      switch(m.getName()) {
       case "next": if (failKey || next) return false; next=true; return true;
       case "getInt": return 734;
       default: return defaultValue(m.getReturnType());
      }
     }
   });
  }
  PreparedStatement stmt(boolean permission) {
    return (PreparedStatement) Proxy.newProxyInstance(getClass().getClassLoader(),new Class[]{PreparedStatement.class},(proxy,method,args)->{
      switch(method.getName()) {
       case "setInt": case "setString": if(permission && method.getName().equals("setInt") && ((int)args[0])==2 && ((int)args[1])==999) failedPermission=true;return null;
       case "executeUpdate": if(permission){ if(failedPermission) throw new SQLException("Foreign key violation", "23000"); assigned++; return 1; }
         if (zeroInsert) return 0; inserted++; return 1;
       case "getGeneratedKeys": return rs();
       default: return defaultValue(method.getReturnType());
      }
    });
  }
  Connection conn(){return (Connection)Proxy.newProxyInstance(getClass().getClassLoader(),new Class[]{Connection.class},(proxy,m,args)->{
   switch(m.getName()){
    case "setAutoCommit": if(Boolean.FALSE.equals(args[0]))autoOff++;return null;
    case "prepareStatement":prepared++;return stmt(((String)args[0]).startsWith("INSERT INTO user_permission"));
    case "commit":commits++;if(failCommit)throw new SQLException("commit failed");return null;
    case "rollback":rollbacks++;if(failRollback)throw new SQLException("rollback failed");return null;
    case "close":closes++;return null;
    default:return defaultValue(m.getReturnType());
   }
  });}
 }
 static class TestDAO extends UserDAO {
  DB db;
  TestDAO(DB db){this.db=db;}
  @Override protected Connection getConnection(){return db.conn();}
 }
 static int tests=0;
 static void ok(boolean b,String name){if(!b) throw new AssertionError(name);tests++;System.out.println("PASS: "+name);}
 static void run(DB db,int[] ids,boolean expectError) throws Exception {
  boolean failed=false;
  try {new TestDAO(db).addUserTransaction(new User("Test","test@example.com","VN"),ids);}
  catch(SQLException e){ failed=true; if(db.failRollback)ok(e.getSuppressed().length==1,"rollback exception suppressed");}
  ok(failed==expectError,"exception propagated expected="+expectError);
  ok(db.autoOff==1,"autoCommit disabled");
  ok(db.closes==1,"connection closed");
  ok(db.rollbacks==(expectError?1:0),"rollback count");
  if(!expectError)ok(db.commits==1,"commit exactly once");
 }
 public static void main(String[] argv) throws Exception {
  DB success=new DB();run(success,new int[]{1,4},false);ok(success.assigned==2,"2 permissions linked");ok(success.inserted==1,"single user insert");
  DB zero=new DB();run(zero,new int[]{},false);ok(zero.assigned==0,"allow empty permission list");
  DB nullArray=new DB();run(nullArray,null,false);ok(nullArray.assigned==0,"allow null permission list");
  DB badFK=new DB();run(badFK,new int[]{1,999},true);ok(badFK.commits==0,"FK failure is not committed");ok(badFK.assigned==1,"first permission assigned in pending transaction");
  DB key=new DB();key.failKey=true;run(key,new int[]{1},true);ok(key.assigned==0,"missing generated key prevents link");
  DB insert0=new DB();insert0.zeroInsert=true;run(insert0,new int[]{1},true);ok(insert0.assigned==0,"zero inserted users prevents link");
  DB commit=new DB();commit.failCommit=true;run(commit,new int[]{1},true);
  DB rollback=new DB();rollback.failRollback=true;run(rollback,new int[]{1,999},true);
  System.out.println("TOTAL PASSED="+tests);
 }
}
