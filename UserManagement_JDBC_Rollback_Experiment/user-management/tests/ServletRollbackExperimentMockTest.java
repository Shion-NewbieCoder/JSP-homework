package com.codegym.controller;

import com.codegym.model.User;
import java.sql.SQLException;

/** Servlet mock: GET chỉ hiển thị, POST chủ động gây lỗi và báo kết quả. */
public class ServletRollbackExperimentMockTest {
    static int checks;
    static void ok(boolean condition, String label) {
        if (!condition) throw new AssertionError(label);
        checks++;
        System.out.println("PASS " + label);
    }
    static ServletTransactionMockTest.State state() {
        ServletTransactionMockTest.State s = new ServletTransactionMockTest.State();
        s.params.put("action", "test-user-rollback");
        return s;
    }
    public static void main(String[] argv) throws Exception {
        ServletTransactionMockTest.FakeDAO dao = new ServletTransactionMockTest.FakeDAO();
        ServletTransactionMockTest.State s = state();
        ServletTransactionMockTest.servlet(dao).doGet(s.request(), s.response());
        ok(dao.added == 0, "GET không gọi INSERT");
        ok("/user/rollback-experiment.jsp".equals(s.forward), "GET render trang hướng dẫn");

        dao = new ServletTransactionMockTest.FakeDAO();
        dao.throwSql = true; // 1452 + SQLState 23000
        s = state();
        ServletTransactionMockTest.servlet(dao).doPost(s.request(), s.response());
        ok(dao.added == 1, "POST gọi addUserTransaction đúng một lần");
        ok(dao.perms.length == 2 && dao.perms[0] == 1
                && dao.perms[1] == Integer.MAX_VALUE, "POST truyền quyền đúng/sai theo kịch bản");
        ok(dao.lastAddedUser.getEmail().startsWith("tx-rollback-"), "Email test riêng mỗi lượt");
        ok(Boolean.TRUE.equals(s.attrs.get("expectedForeignKey")), "Phát hiện FK 1452");
        ok(Boolean.TRUE.equals(s.attrs.get("rollbackVerified")), "Kiểm chứng count=0 và lỗi đúng");
        ok("/user/rollback-experiment.jsp".equals(s.forward) && s.redirect == null,
                "Trang kết quả, không redirect che mất lỗi");

        dao = new ServletTransactionMockTest.FakeDAO(); // không ném lỗi
        dao.foundByEmail = 1;
        s = state();
        ServletTransactionMockTest.servlet(dao).doPost(s.request(), s.response());
        ok(Boolean.TRUE.equals(s.attrs.get("unexpectedCommit")), "Nếu SQL không lỗi thì báo tình huống commit bất thường");
        ok(Boolean.FALSE.equals(s.attrs.get("rollbackVerified")), "Không nhầm commit thành rollback");

        ServletTransactionMockTest.FakeDAO otherError = new ServletTransactionMockTest.FakeDAO() {
            @Override public void addUserTransaction(User user, int[] ids) throws SQLException {
                throw new SQLException("DB authentication failed", "28000", 1045);
            }
        };
        s = state();
        ServletTransactionMockTest.servlet(otherError).doPost(s.request(), s.response());
        ok(Boolean.FALSE.equals(s.attrs.get("expectedForeignKey")), "Lỗi mật khẩu không phải FK");
        ok(Boolean.FALSE.equals(s.attrs.get("rollbackVerified")), "Lỗi môi trường không được báo rollback thành công");

        dao = new ServletTransactionMockTest.FakeDAO();
        dao.throwSql = true;
        dao.throwVerify = true;
        s = state();
        ServletTransactionMockTest.servlet(dao).doPost(s.request(), s.response());
        ok(Boolean.FALSE.equals(s.attrs.get("rollbackVerified")), "Query đếm thất bại không được báo đạt");
        ok(s.attrs.get("verifyError") != null, "Lỗi xác minh hiển thị rõ ràng");
        System.out.println("TOTAL PASSED=" + checks);
    }
}
