package com.codegym.controller;
import jakarta.servlet.http.*;
import java.util.*;

/** Unit test định tuyến 2 mode (không phải Tomcat tích hợp). */
public class ServletUseTransactionMockTest {
 static int checks=0;
 static void ok(boolean condition,String what) {
  if(!condition) throw new AssertionError(what);
  checks++; System.out.println("PASS: "+what);
 }
 public static void main(String[] args)throws Exception {
  ServletTransactionMockTest.FakeDAO dao = new ServletTransactionMockTest.FakeDAO();
  ServletTransactionMockTest.State s = new ServletTransactionMockTest.State();
  s.params.put("action","test-use-tran");
  ServletTransactionMockTest.servlet(dao).doGet(s.request(),s.response());
  ok(dao.newDemoCalls==1,"GET demo mặc định gọi dao đúng một lần");
  ok(Boolean.TRUE.equals(dao.lastFail),"GET mặc định là fail");
  ok("/user/use-transaction.jsp".equals(s.forward),"GET hiển thị result JSP");
  ok(s.attrs.get("demoError")!=null,"Exception được hiển thị");
  ok(s.redirect==null,"Không fake redirect nếu thất bại");
  ok("fail".equals(s.attrs.get("demoMode")),"mode fail vào model JSP");

  dao = new ServletTransactionMockTest.FakeDAO();
  s = new ServletTransactionMockTest.State();
  s.params.put("action","test-use-tran");s.params.put("mode","success");
  ServletTransactionMockTest.servlet(dao).doGet(s.request(),s.response());
  ok(dao.newDemoCalls==1,"success gọi DAO");
  ok(Boolean.FALSE.equals(dao.lastFail),"success truyền failUpdate=false");
  ok(Boolean.TRUE.equals(s.attrs.get("demoCommitted")),"success đưa flag commit ra JSP");
  ok(s.attrs.get("demoError")==null,"success không báo lỗi");
  ok("success".equals(s.attrs.get("demoMode")),"JSP nhận mode success");

  dao = new ServletTransactionMockTest.FakeDAO();
  s = new ServletTransactionMockTest.State();
  s.params.put("action","test-use-tran");s.params.put("mode","other");
  ServletTransactionMockTest.servlet(dao).doGet(s.request(),s.response());
  ok(s.status==400,"mode khác bị chặn 400");
  ok(dao.newDemoCalls==0,"mode khác không chạm DB");

  dao = new ServletTransactionMockTest.FakeDAO();dao.newDemoUnexpectedSql=true;
  s = new ServletTransactionMockTest.State();
  s.params.put("action","test-use-tran");s.params.put("mode","success");
  ServletTransactionMockTest.servlet(dao).doGet(s.request(),s.response());
  ok(s.attrs.get("demoError")!=null,"lỗi thực ở success không báo thành công");
  ok(s.attrs.get("demoCommitted")==null,"lỗi thực không có commit flag");
  System.out.println("TOTAL PASSED="+checks);
 }
}
