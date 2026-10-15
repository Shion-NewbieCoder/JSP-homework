-- iNotes MySQL 8 / InnoDB / UTF-8; chạy trong MySQL Workbench trước khi chọn MySQL.
CREATE DATABASE IF NOT EXISTS inotes_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE inotes_db;
CREATE TABLE IF NOT EXISTS note_type (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS notes (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    type_id INT NOT NULL,
    CONSTRAINT fk_notes_type FOREIGN KEY (type_id) REFERENCES note_type(id)
) ENGINE=InnoDB;
INSERT INTO note_type(id, name, description) VALUES
    (1, 'Cá nhân', 'Ghi chú cá nhân'),
    (2, 'Công việc', 'Công việc và lịch trình'),
    (3, 'Học tập', 'Kiến thức và ôn tập')
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
-- Chỉ thêm dữ liệu ví dụ nếu chưa có ghi chú nào.
INSERT INTO notes(title, content, type_id)
SELECT 'Họp giao ban đầu tuần', 'Chuẩn bị nội dung và việc cần làm cho cuộc họp.', 2
WHERE NOT EXISTS (SELECT 1 FROM notes);
INSERT INTO notes(title, content, type_id)
SELECT 'Ôn tập Design Pattern Servlet', 'Ôn Strategy Pattern, Servlet, JDBC và JSP.', 3
WHERE NOT EXISTS (SELECT 1 FROM notes WHERE title = 'Ôn tập Design Pattern Servlet');
