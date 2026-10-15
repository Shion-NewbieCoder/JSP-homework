import com.codegym.dao.UserDAO;
import java.lang.reflect.Proxy;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

/** Mô phỏng JDBC staging/commit/rollback trên cùng một Connection. */
public class UseTransactionMockTest {
 static int checks=0;
 static void ok(boolean v,String label) {
  if(!v)throw new AssertionError(label);
  checks++;System.out.println("PASS "+label);
 }
 static class DB {
  final List<String> calls = new ArrayList<>();
  Map<String,BigDecimal> persisted = new LinkedHashMap<>();
  Map<String,BigDecimal> staged;
  boolean autoCommit=true;
  boolean failSecondInsert, failCommit, failRollback;
  int inserted, updated, commits, rollbacks, closed;
  static Object primitive(Class<?> type) {
   if(type.equals(boolean.class))return false;
   if(type.equals(int.class))return 0;
   if(type.equals(long.class))return 0L;
   return null;
  }
  PreparedStatement prepared(String sql) {
   if(!(sql.startsWith("INSERT INTO Employee")||sql.startsWith("UPDATE Employee")))
    throw new AssertionError("Unexpected statement: "+sql);
   final boolean insert=sql.startsWith("INSERT");
   final Map<Integer,Object> params=new HashMap<>();
   return (PreparedStatement)Proxy.newProxyInstance(getClass().getClassLoader(),new Class<?>[]{PreparedStatement.class},(o,m,a)->{
    switch(m.getName()) {
     case "setString":case "setBigDecimal":case "setTimestamp":params.put((Integer)a[0],a[1]);return null;
     case "executeUpdate":
      if (insert) {
       if(!params.keySet().containsAll(List.of(1,2,3)))throw new SQLException("missing insert params");
       inserted++;calls.add("insert:"+params.get(1));
       if(failSecondInsert&&inserted==2)throw new SQLException("Second insert error");
       staged.put((String)params.get(1),(BigDecimal)params.get(2));return 1;
      }
      updated++;calls.add("update");
      if(!params.containsKey(1))throw new SQLException("No value specified for parameter 1");
      if(!params.containsKey(2))throw new SQLException("No value specified for parameter 2");
      if(!staged.containsKey((String)params.get(2)))return 0;
      staged.put((String)params.get(2),(BigDecimal)params.get(1));return 1;
     case "close":return null;
     default:return primitive(m.getReturnType());
    }
   });
  }
  Connection conn() {
   return (Connection)Proxy.newProxyInstance(getClass().getClassLoader(),new Class<?>[]{Connection.class},(o,m,a)->{
    switch(m.getName()) {
     case "setAutoCommit":autoCommit=(boolean)a[0];calls.add("autoCommit="+autoCommit);
      if(!autoCommit)staged=new LinkedHashMap<>(persisted);return null;
     case "getAutoCommit":return autoCommit;
     case "prepareStatement":return prepared((String)a[0]);
     case "createStatement":throw new AssertionError("Transaction code must not use DDL");
     case "commit":commits++;calls.add("commit");
      if(failCommit)throw new SQLException("Commit failed");
      persisted=new LinkedHashMap<>(staged);return null;
     case "rollback":rollbacks++;calls.add("rollback");
      if(failRollback)throw new SQLException("Rollback failed");
      staged=new LinkedHashMap<>(persisted);return null;
     case "close":closed++;calls.add("close");return null;
     default:return primitive(m.getReturnType());
    }
   });
  }
 }
 static class DAO extends UserDAO {
  final DB db;
  DAO(DB db){this.db=db;}
  @Override protected Connection getConnection(){return db.conn();}
 }
 public static void main(String[] args)throws Exception {
  DB fail=new DB();
  try{new DAO(fail).insertUpdateUseTransaction();throw new AssertionError("must fail");}
  catch(SQLException e){ok(e.getMessage().contains("parameter 1"),"default mode deliberately fails on parameter 1");}
  ok(!fail.autoCommit,"transaction disabled autoCommit");
  ok(fail.inserted==2,"executed 2 inserts before failure");
  ok(fail.updated==1,"attempted update after inserts");
  ok(fail.persisted.isEmpty(),"rollback leaves empty initial database untouched");
  ok(fail.commits==0,"failure must not commit");
  ok(fail.rollbacks==1,"failure calls explicit rollback once");
  ok(fail.closed==1,"connection closed in error case");
  ok(fail.calls.equals(List.of("autoCommit=false","insert:Quynh","insert:Ngan","update","rollback","close")),"operation order correct");

  DB okdb=new DB();new DAO(okdb).insertUpdateUseTransaction(false);
  ok(okdb.commits==1,"success calls commit once");
  ok(okdb.rollbacks==0,"success doesn't rollback");
  ok(okdb.persisted.size()==2,"both employees committed");
  ok(new BigDecimal("999.99").compareTo(okdb.persisted.get("Quynh"))==0,"Quynh salary updated to 999.99");
  ok(new BigDecimal("20.00").compareTo(okdb.persisted.get("Ngan"))==0,"Ngan salary preserved at 20");
  ok(okdb.inserted==2&&okdb.updated==1,"success completes 2 inserts and 1 update");
  ok(okdb.closed==1,"success closes connection");

  DB baseline=new DB();baseline.persisted.put("Prior",new BigDecimal("456.78"));
  try{new DAO(baseline).insertUpdateUseTransaction(true);throw new AssertionError("must fail");}catch(SQLException e){}
  ok(baseline.persisted.size()==1,"rollback preserves preexisting data");
  ok(baseline.persisted.containsKey("Prior"),"no DROP/CREATE of old data");

  DB secondFail=new DB();secondFail.failSecondInsert=true;
  try{new DAO(secondFail).insertUpdateUseTransaction(false);throw new AssertionError("must fail");}
  catch(SQLException e){ok(e.getMessage().contains("Second"),"error on second INSERT propagates");}
  ok(secondFail.rollbacks==1&&secondFail.commits==0,"second INSERT fail rolls back");
  ok(secondFail.persisted.isEmpty(),"second INSERT failure leaves no partial rows");

  DB commitFail=new DB();commitFail.failCommit=true;
  try{new DAO(commitFail).insertUpdateUseTransaction(false);throw new AssertionError("must fail");}
  catch(SQLException e){ok(e.getMessage().equals("Commit failed"),"commit error propagates");}
  ok(commitFail.rollbacks==1,"attempt rollback when commit fails");
  ok(commitFail.closed==1,"connection closed when commit fails");

  DB rollFail=new DB();rollFail.failRollback=true;
  try{new DAO(rollFail).insertUpdateUseTransaction(true);throw new AssertionError("must fail");}
  catch(SQLException e){ok(e.getSuppressed().length==1,"rollback failure attached as suppressed");}
  ok(rollFail.closed==1,"even if rollback errors, connection closed");
  System.out.println("TOTAL PASSED="+checks);
 }
}
