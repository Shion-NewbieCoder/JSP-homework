# Kiểm thử JDBC No Transaction

Xem [README ở thư mục nộp bài](../../README.md).

Chạy `NoTransactionMockTest` để xác nhận 2 INSERT lưu độc lập khi UPDATE thiếu parameter 1. Chạy lại `TxMockTest` và `ServletTransactionMockTest` để xác nhận không phá vỡ các chức năng cũ. Đây là kiểm thử mock, không phải kiểm thử MySQL thật.

## JDBC transaction (bài mới)

Chạy `UseTransactionMockTest` và `ServletUseTransactionMockTest` để xác minh 2 chế độ: lỗi rollback và thành công commit. Script SQL `database/reset_employee_demo.sql` phải chạy riêng trên MySQL Workbench.
