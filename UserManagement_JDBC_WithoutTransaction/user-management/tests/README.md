# Kiểm thử JDBC No Transaction

Xem [README ở thư mục nộp bài](../../README.md).

Chạy `NoTransactionMockTest` để xác nhận 2 INSERT lưu độc lập khi UPDATE thiếu parameter 1. Chạy lại `TxMockTest` và `ServletTransactionMockTest` để xác nhận không phá vỡ các chức năng cũ. Đây là kiểm thử mock, không phải kiểm thử MySQL thật.
