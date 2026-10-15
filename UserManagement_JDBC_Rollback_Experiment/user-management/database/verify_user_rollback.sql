-- CodeGym: kiểm tra thủ công sau khi POST thí nghiệm Rollback User.
-- Chỉ dùng database DEMO, không xoá dữ liệu nào.
USE demo;

-- Sao chép địa chỉ email tx-rollback-...@example.invalid hiện trên giao diện.
SET @test_email = 'tx-rollback-THAY_BANG_EMAIL_TREN_WEB@example.invalid';

-- ĐÚNG: không có bản ghi User nào khớp email riêng của lần chạy.
SELECT id, name, email, country
FROM users
WHERE email = @test_email;

-- ĐÚNG: không có quyền nào thuộc về User vừa kiểm thử.
SELECT up.user_id, up.permission_id
FROM user_permission AS up
JOIN users AS u ON u.id = up.user_id
WHERE u.email = @test_email;

-- Đảm bảo dùng InnoDB + có FK cần thiết cho rollback:
SELECT TABLE_NAME, ENGINE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'demo'
  AND TABLE_NAME IN ('users', 'permission', 'user_permission');

SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'demo' AND TABLE_NAME = 'user_permission'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
