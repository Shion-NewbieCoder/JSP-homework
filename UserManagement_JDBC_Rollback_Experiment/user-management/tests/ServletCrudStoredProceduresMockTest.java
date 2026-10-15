package com.codegym.controller;

import com.codegym.model.User;

/** Verify the real Servlet is now routed through new Stored Procedure DAO methods. */
public class ServletCrudStoredProceduresMockTest {
    static int checks=0;
    static void ok(boolean good,String label) {
        if(!good)throw new AssertionError(label);
        ++checks;System.out.println("PASS "+label);
    }
    public static void main(String[] args) throws Exception {
        ServletTransactionMockTest.FakeDAO dao = new ServletTransactionMockTest.FakeDAO();
        ServletTransactionMockTest.State state = new ServletTransactionMockTest.State();
        state.params.put("country","Viet Nam");state.params.put("sort","desc");
        ServletTransactionMockTest.servlet(dao).doGet(state.request(),state.response());
        ok(dao.filtered==1 && "desc".equals(dao.sort),"GET list maintains search and sort");
        ok("/user/list.jsp".equals(state.forward),"GET list forwards JSP");

        dao = new ServletTransactionMockTest.FakeDAO();
        state = new ServletTransactionMockTest.State();
        state.params.put("action","edit");state.params.put("id","12");
        ServletTransactionMockTest.servlet(dao).doGet(state.request(),state.response());
        ok(dao.getById==1 && "/user/edit.jsp".equals(state.forward),"edit GET loads data using SP");

        dao = new ServletTransactionMockTest.FakeDAO();
        state = new ServletTransactionMockTest.State();
        state.params.put("action","edit");state.params.put("id","12");
        state.params.put("name","New Name");state.params.put("email","name@example.com");state.params.put("country","VN");
        ServletTransactionMockTest.servlet(dao).doPost(state.request(),state.response());
        ok(dao.edited==1,"edit POST uses updateUserStore");
        ok("/user-management/users".equals(state.redirect),"edit successful redirects");

        dao = new ServletTransactionMockTest.FakeDAO();
        state = new ServletTransactionMockTest.State();
        state.params.put("action","delete");state.params.put("id","13");
        ServletTransactionMockTest.servlet(dao).doGet(state.request(),state.response());
        ok(dao.getById==1 && "/user/delete.jsp".equals(state.forward),"delete GET loads confirmation via SP");

        dao = new ServletTransactionMockTest.FakeDAO();
        state = new ServletTransactionMockTest.State();
        state.params.put("action","delete");state.params.put("id","13");
        ServletTransactionMockTest.servlet(dao).doPost(state.request(),state.response());
        ok(dao.removed==1,"delete POST uses deleteUserStore");
        ok("/user-management/users".equals(state.redirect),"delete successful redirects");
        System.out.println("TOTAL PASSED="+checks);
    }
}
