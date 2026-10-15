-- Chạy trong MySQL Workbench; script phục vụ bài thực hành.
-- Không xóa hoặc ghi đè database demo sẵn có.
CREATE DATABASE IF NOT EXISTS demo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE demo;

CREATE TABLE IF NOT EXISTS users (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(220) NOT NULL,
    country VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Giữ hai dữ liệu mẫu của đề; tránh nhân đôi khi chạy script lần thứ hai.
INSERT INTO users (name, email, country)
SELECT 'Minh', 'minh@codegym.vn', 'Viet Nam'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'minh@codegym.vn');

INSERT INTO users (name, email, country)
SELECT 'Kante', 'kante@che.uk', 'Kenia'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'kante@che.uk');

SELECT id, name, email, country FROM users ORDER BY id;
