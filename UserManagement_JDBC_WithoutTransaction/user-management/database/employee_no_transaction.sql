-- Bài thực hành chỉ dành cho database demo, KHÔNG dùng trên production.
-- Chạy một lần để khởi tạo bảng; API /users?action=test-without-tran
-- sẽ DROP/CREATE lại chính bảng Employee trước mỗi lần thử.
USE demo;
CREATE TABLE IF NOT EXISTS Employee (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    salary DECIMAL(15,2) NOT NULL,
    created_Date DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sau khi gọi URL demo trong trình duyệt, xác minh:
SELECT id, name, salary, created_Date FROM Employee ORDER BY id;
-- Dự kiến: Quynh = 10.00; Ngan = 20.00;
-- UPDATE lỗi vì SQL có 2 dấu ? nhưng mã Java không gán giá trị cho ? số 1.
-- Hai INSERT trước vẫn tồn tại bởi JDBC đang ở chế độ autoCommit=true.
