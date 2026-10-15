-- Kiểm tra điều kiện TRƯỚC khi chạy thí nghiệm rollback từ website.
-- Script chỉ SELECT (không thay đổi dữ liệu).
USE demo;

-- Kết quả phải là cả 3 bảng ENGINE=InnoDB.
SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'demo' AND TABLE_NAME IN ('users', 'permission', 'user_permission');

-- Permission 1 phải có; 2147483647 phải KHÔNG có.
SELECT id, name FROM permission WHERE id IN (1, 2147483647);

-- Phải tồn tại foreign key user_permission.permission_id -> permission.id.
SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA='demo' AND TABLE_NAME='user_permission'
      AND REFERENCED_TABLE_NAME IS NOT NULL;
