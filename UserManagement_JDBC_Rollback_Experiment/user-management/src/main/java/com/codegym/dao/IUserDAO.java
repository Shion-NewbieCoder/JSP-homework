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
     * Xác minh một email thí nghiệm có bị ghi vào demo.users hay không.
     * Được gọi SAU khi addUserTransaction() đã báo lỗi và rollback.
     */
    int countUsersByEmail(String email) throws SQLException;

    /**
     * DEMO CÓ CHỦ ĐÍCH GÂY LỖI, chỉ chạy trên CSDL demo.
     * Hai INSERT được auto-commit, UPDATE sai tham số ném SQLException.
     * DROP/CREATE riêng bảng Employee sẽ xóa dữ liệu Employee trước đó.
     */
    void insertUpdateWithoutTransaction() throws SQLException;

    /** Thử UPDATE lỗi, chủ động rollback hai INSERT cùng transaction. */
    void insertUpdateUseTransaction() throws SQLException;

    /** failUpdate=true để rollback; false để commit đầy đủ ba thao tác. */
    void insertUpdateUseTransaction(boolean failUpdate) throws SQLException;

    /** Danh sách + country filter + name sort qua CALL get_all_users(?, ?). */
    List<User> getAllUsersStore(String country, String sort) throws SQLException;

    /** Chỉnh sửa qua CALL update_user, trả false nếu ID không tồn tại. */
    boolean updateUserStore(User user) throws SQLException;

    /** Xóa qua CALL delete_user, bao gồm mapping quyền có khóa ngoại. */
    boolean deleteUserStore(int id) throws SQLException;

    /** Tìm theo một phần tên quốc gia, sắp xếp tên asc hoặc desc. */
    List<User> searchAndSort(String country, String sort) throws SQLException;
}
