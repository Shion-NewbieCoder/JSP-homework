package com.codegym.controller;
import com.codegym.dao.*;
import com.codegym.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.lang.reflect.*;
import java.io.*;
import java.sql.*;
import java.util.*;

public class ServletTransactionMockTest {
 static class FakeDAO implements IUserDAO {
  int added, edited, storeLegacy, getById, filtered;
  int[] perms; boolean throwSql;
  String country, sort;
  public void addUserTransaction(User user,int[] ids) throws SQLException {added++;perms=ids;if(throwSql) throw new SQLException("FK bad");}
  public void insertUser(User u){} public User selectUser(int id){return new User(id,"Test","test@example.com","VN");}
  public List<User> selectAllUsers(){return List.of();}public boolean deleteUser(int id){return true;}
  public boolean updateUser(User user){edited++;return true;}
  public User getUserById(int id){getById++;return new User(id,"Test","test@example.com","VN");}
  public void insertUserStore(User user){storeLegacy++;}
  public List<User> searchAndSort(String c,String s){filtered++;country=c;sort=s;return List.of();}
 }
 static class State {
  Map<String,String> params = new HashMap<>(); String[] checked; int status=200;
  String redirect,forward; Map<String,Object> attrs=new HashMap<>();
  HttpServletRequest request() {
   return (HttpServletRequest)Proxy.newProxyInstance(getClass().getClassLoader(),new Class[]{HttpServletRequest.class},(proxy,m,args)->{
    switch(m.getName()){
      case "getParameter": return params.get(args[0]);
      case "getParameterValues": return "permissions".equals(args[0])?checked:null;
      case "getContextPath":return "/user-management";
      case "setCharacterEncoding":return null;
      case "setAttribute":attrs.put((String)args[0],args[1]);return null;
      case "getRequestDispatcher": return (RequestDispatcher)(r,s)->forward=(String)args[0];
      default: return null;
    }
   });
  }
  HttpServletResponse response(){
   return (HttpServletResponse)Proxy.newProxyInstance(getClass().getClassLoader(),new Class[]{HttpServletResponse.class},(proxy,m,args)->{
    switch(m.getName()){
      case "setStatus": status=(int)args[0];return null;
      case "sendError":status=(int)args[0];return null;
      case "sendRedirect":redirect=(String)args[0];return null;
      default:return null;
    }
   });
  }
 }
 static int checks=0;
 static void ok(boolean bool,String name){if(!bool)throw new AssertionError(name);checks++;System.out.println("PASS "+name);}
 static UserServlet servlet(FakeDAO dao)throws Exception {
  UserServlet s=new UserServlet();
  Field fld=UserServlet.class.getDeclaredField("dao");fld.setAccessible(true);fld.set(s,dao);return s;
 }
 static State create(String[] selections){State s=new State();s.checked=selections;
  s.params.put("action","create");s.params.put("name","Anna");s.params.put("email","anna@example.com");s.params.put("country","VN");return s;}
 public static void main(String[] args)throws Exception{
  FakeDAO d=new FakeDAO();State s=create(new String[]{"1","4"});servlet(d).doPost(s.request(),s.response());
  ok(d.added==1,"create invokes transaction once");ok(Arrays.equals(d.perms,new int[]{1,4}),"checkbox values parsed");ok(d.storeLegacy==0,"create not using old Stored Procedure");ok("/user-management/users".equals(s.redirect),"success redirects to context list");
  d=new FakeDAO();s=create(null);servlet(d).doPost(s.request(),s.response());ok(d.added==1&&d.perms.length==0,"null checked -> empty array");
  d=new FakeDAO();s=create(new String[]{"invalid"});servlet(d).doPost(s.request(),s.response());ok(d.added==0,"bad permission not saved");ok(s.status==400,"bad permission HTTP400");ok("/user/create.jsp".equals(s.forward),"bad permission stays on form");
  d=new FakeDAO();s=create(new String[]{"5"});servlet(d).doPost(s.request(),s.response());ok(s.status==400&&d.added==0,"out-of-range permission refused");
  d=new FakeDAO();d.throwSql=true;s=create(new String[]{"1"});boolean caught=false;try{servlet(d).doPost(s.request(),s.response());}catch(ServletException ex){caught=true;}ok(caught,"SQL error propagated");ok(s.redirect==null,"SQL error does not fake success redirect");
  d=new FakeDAO();s=new State();s.params.put("action","edit");s.params.put("id","8");s.params.put("name","John");s.params.put("email","john@example.com");s.params.put("country","VN");servlet(d).doPost(s.request(),s.response());ok(d.edited==1&&d.added==0,"edit retains legacy path");
  d=new FakeDAO();s=new State();s.params.put("action","edit");s.params.put("id","8");servlet(d).doGet(s.request(),s.response());ok(d.getById==1,"edit GET retains Stored Procedure");
  d=new FakeDAO();s=new State();s.params.put("country","VN");s.params.put("sort","desc");servlet(d).doGet(s.request(),s.response());ok("VN".equals(d.country)&&"desc".equals(d.sort),"country filter and sort remain");
  System.out.println("TOTAL PASSED="+checks);
 }
}
