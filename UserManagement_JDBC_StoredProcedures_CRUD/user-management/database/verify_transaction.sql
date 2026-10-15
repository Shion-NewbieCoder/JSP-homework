-- CHAY TRONG MYSQL WORKBENCH SAU KHI THEM USER BANG FORM
USE demo;
-- Xem user duoc tao moi nhat:
SELECT id, name, email, country FROM users ORDER BY id DESC LIMIT 5;
-- Xem phan quyen va ten quyen cua nhung user vua them:
SELECT u.id AS user_id, u.name AS user_name,
       p.id AS permission_id, p.name AS permission_name
FROM users u
JOIN user_permission up ON up.user_id = u.id
JOIN permission p ON p.id = up.permission_id
ORDER BY u.id DESC, p.id ASC;

-- KIEM THU ROLLBACK (KHONG CAN SUA DAO):
-- Gọi UserDAO.addUserTransaction(new User("Rollback Demo", "rollback@example.com", "VN"), new int[]{1, 999})
-- Bước gán quyền 999 vi phạm FOREIGN KEY, phải ném SQLException và rollback cả User.
-- Sau đó, truy vấn dưới phải trả 0 dòng:
SELECT id, name FROM users WHERE email = 'rollback@example.com';
-- KHONG INSERT test vao production vi duoi day.
