# Kiểm thử JDBC No Transaction

Xem [README ở thư mục nộp bài](../../README.md).

Chạy `NoTransactionMockTest` để xác nhận 2 INSERT lưu độc lập khi UPDATE thiếu parameter 1. Chạy lại `TxMockTest` và `ServletTransactionMockTest` để xác nhận không phá vỡ các chức năng cũ. Đây là kiểm thử mock, không phải kiểm thử MySQL thật.

## JDBC transaction (bài mới)

Chạy `UseTransactionMockTest` và `ServletUseTransactionMockTest` để xác minh 2 chế độ: lỗi rollback và thành công commit. Script SQL `database/reset_employee_demo.sql` phải chạy riêng trên MySQL Workbench.


### Bổ sung cho bài Stored Procedures List/Edit/Delete

- `StoredProceduresCrudMockTest.java`: kiểm thử `CallableStatement` với IN/OUT, kết quả `ResultSet`, đóng tài nguyên và ném `SQLException`.
- `ServletCrudStoredProceduresMockTest.java`: kiểm tra luồng GET/POST của Servlet chuyển sang Stored Procedure mà không hỏng tìm kiếm/sắp xếp.

Chạy `powershell -ExecutionPolicy Bypass -File tests/run_mock_tests.ps1` tại thư mục gốc dự án (yêu cầu JDK 17+). Đây chỉ là test mock, không kết nối MySQL.


### Bài mới: SQL lỗi và Rollback khi thêm User + Permission

- `RollbackExperimentMockTest.java` kiểm tra DAO nhận FK 1452, gọi rollback và không commit, cùng đường thành công đối chứng.
- `ServletRollbackExperimentMockTest.java` kiểm tra GET không ghi dữ liệu, POST truyền quyền `1` và `2147483647`, không đánh đồng lỗi MySQL kết nối với rollback, và xử lý lỗi SELECT xác minh.
- `run_mock_tests.ps1` chạy toàn bộ test bằng JDK17; không sử dụng DB thật.

Để chứng minh thật, xem `database/rollback_demo_precheck.sql` và `database/verify_user_rollback.sql` và thực hiện trên MySQL Workbench.
