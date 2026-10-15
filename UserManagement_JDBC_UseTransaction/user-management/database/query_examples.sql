USE demo;
-- Kết quả SQL có thể đối chiếu với giao diện /users:
SELECT id, name, email, country FROM users ORDER BY name ASC, id ASC;
SELECT id, name, email, country FROM users ORDER BY name DESC, id ASC;
SELECT id, name, email, country FROM users WHERE LOWER(country) LIKE '%viet nam%' ORDER BY name ASC, id ASC;
-- DAO dùng PreparedStatement để truyền country; không tự nối input vào SQL.
