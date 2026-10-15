-- BAI THUC HANH: JDBC CALLABLESTATEMENT + MYSQL STORED PROCEDURES
-- Chay database/init.sql truoc, sau do chay file nay trong MySQL Workbench.
-- DROP IF EXISTS de co the chay lai script trong moi truong thuc hanh.
USE demo;

DELIMITER $$
DROP PROCEDURE IF EXISTS get_user_by_id$$
CREATE PROCEDURE get_user_by_id(IN user_id INT)
BEGIN
    SELECT users.name, users.email, users.country
    FROM users
    WHERE users.id = user_id;
END$$

DROP PROCEDURE IF EXISTS insert_user$$
CREATE PROCEDURE insert_user(
    IN user_name VARCHAR(120),
    IN user_email VARCHAR(220),
    IN user_country VARCHAR(120)
)
BEGIN
    INSERT INTO users(name, email, country)
    VALUES (user_name, user_email, user_country);
END$$
DELIMITER ;

-- Kiểm tra danh sách procedures sau khi tạo.
SHOW PROCEDURE STATUS WHERE Db = 'demo';
-- Thu nghiem thu cong (khong bat buoc):
-- CALL get_user_by_id(1);
-- CALL insert_user('Tester', 'tester@example.com', 'Viet Nam');
-- SELECT * FROM users ORDER BY id DESC;
