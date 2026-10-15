# User Management — JDBC Transaction Demo

Mã chính: [`UserDAO.java`](src/main/java/com/codegym/dao/UserDAO.java), [`UserServlet.java`](src/main/java/com/codegym/controller/UserServlet.java).

Hướng dẫn đầy đủ, bảng so sánh, các URL chạy thử, reset DB và kết quả dự kiến nằm tại [`../README.md`](../README.md).

Mục đích: dùng `setAutoCommit(false)`, `rollback()` khi lỗi, `commit()` khi thành công. Chỉ thử trên database `demo` học tập.
