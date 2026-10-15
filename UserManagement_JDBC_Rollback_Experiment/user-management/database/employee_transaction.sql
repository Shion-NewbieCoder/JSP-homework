-- SCRIPT chuẩn bị cho bài JDBC Transaction (dùng MySQL Workbench)
-- DDL MySQL có IMPLICIT COMMIT, vì vậy CHỈ chạy tạo bảng ở đây;
-- đừng đặt DROP/CREATE TABLE trong phần Transaction của Java.
CREATE DATABASE IF NOT EXISTS demo CHARACTER SET utf8mb4;
USE demo;
CREATE TABLE IF NOT EXISTS Employee (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    salary DECIMAL(15,2) NOT NULL,
    created_Date DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bước reset: Chạy file database/reset_employee_demo.sql riêng trước mỗi lượt.
-- KHÔNG tự động xóa dữ liệu khi truy cập URL test.
