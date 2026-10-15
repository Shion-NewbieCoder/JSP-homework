# User Management — Bài thực hành JDBC Transaction Rollback

Dự án Maven Java 17/Jakarta Servlet/JSP/Tomcat 10.1+, mở rộng từ User Management có CRUD, tìm kiếm/sắp xếp, Stored Procedures và phân quyền. Bài mới nhất: **cố tình tạo SQL lỗi trong giao dịch thêm User + gán Permission**.

Xem [README nộp bài đầy đủ](../README.md) để tìm mã mẫu, cách chạy và các trường hợp kiểm thử.

## Chạy thí nghiệm

1. Cài MySQL 8, Maven, JDK 17+, Tomcat 10.1.
2. Chạy các script `database/init.sql`, `database/transaction_permissions.sql`, `database/stored_procedures.sql`, `database/stored_procedures_crud.sql` trên database `demo`.
3. Chạy `database/rollback_demo_precheck.sql` và xác nhận InnoDB, FK, có permission 1 và không có permission 2147483647.
4. Khai báo `DB_USER`, `DB_PASSWORD` ở môi trường Tomcat. `mvn clean package`; deploy WAR.
5. Mở `http://localhost:8080/user-management/users?action=test-user-rollback` và bấm nút chạy POST.
6. Copy email test để chạy `database/verify_user_rollback.sql`. Kết quả đúng: 0 bản ghi.

**Chú ý:** Dữ liệu demo có thể bị thay đổi bởi các trang thực hành trước; chỉ sử dụng trên MySQL học tập. Thí nghiệm mới chỉ INSERT và ROLLBACK, không DROP/TRUNCATE bảng. Tăng giá trị AUTO_INCREMENT sau rollback là bình thường.
