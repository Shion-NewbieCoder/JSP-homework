package com.codegym.dao;

import com.codegym.model.User;
import java.sql.SQLException;
import java.util.List;

/** Thao tác JDBC trên bảng demo.users. */
public interface IUserDAO {
    void insertUser(User user) throws SQLException;
    User selectUser(int id) throws SQLException;
    List<User> selectAllUsers() throws SQLException;
    boolean deleteUser(int id) throws SQLException;
    boolean updateUser(User user) throws SQLException;

    /** Tìm user theo ID qua Stored Procedure get_user_by_id. */
    User getUserById(int id) throws SQLException;

    /** Thêm user qua Stored Procedure insert_user. */
    void insertUserStore(User user) throws SQLException;

    /**
     * Tạo một User và tất cả quyền được chọn trong CÙNG một JDBC transaction.
     * Nếu INSERT nào thất bại thì rollback, đồng thời ném SQLException cho Controller.
     * Mảng quyền rỗng hoặc null: tạo User không gán quyền.
     */
    void addUserTransaction(User user, int[] permissionIds) throws SQLException;

    /**
     * DEMO CÓ CHỦ ĐÍCH GÂY LỖI, chỉ chạy trên CSDL demo.
     * Hai INSERT được auto-commit, UPDATE sai tham số ném SQLException.
     * DROP/CREATE riêng bảng Employee sẽ xóa dữ liệu Employee trước đó.
     */
    void insertUpdateWithoutTransaction() throws SQLException;

    /** Tìm theo một phần tên quốc gia, sắp xếp tên asc hoặc desc. */
    List<User> searchAndSort(String country, String sort) throws SQLException;
}
