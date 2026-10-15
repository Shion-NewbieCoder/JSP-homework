-- BAI THUC HANH: Stored Procedures cho List / Edit / Delete User (MySQL 8.0+)
-- Chay theo thu tu: init.sql -> transaction_permissions.sql ->
-- stored_procedures.sql -> stored_procedures_crud.sql.
-- Lenh DROP PROCEDURE ben duoi chi thay the procedures tuong ung,
-- KHONG xoa du lieu bang users hoac user_permission.
USE demo;

DELIMITER $$
DROP PROCEDURE IF EXISTS get_all_users$$
CREATE PROCEDURE get_all_users(IN filter_country VARCHAR(120), IN sort_order VARCHAR(4))
BEGIN
    -- Giu ca tinh nang tim country va sap xep name cua bai truoc.
    -- Escaping !, %, _ de nguoi dung tim chuoi literal thay vi LIKE wildcard.
    SELECT u.id, u.name, u.email, u.country
    FROM users AS u
    WHERE COALESCE(TRIM(filter_country), '') = ''
       OR LOWER(u.country) LIKE CONCAT('%',
            REPLACE(REPLACE(REPLACE(LOWER(TRIM(filter_country)),
                '!', '!!'), '%', '!%'), '_', '!_'), '%') ESCAPE '!'
    ORDER BY
        CASE WHEN LOWER(sort_order) = 'desc' THEN u.name END DESC,
        CASE WHEN LOWER(sort_order) <> 'desc' THEN u.name END ASC,
        u.id ASC;
END$$

DROP PROCEDURE IF EXISTS update_user$$
CREATE PROCEDURE update_user(
    IN p_id INT,
    IN p_name VARCHAR(120),
    IN p_email VARCHAR(220),
    IN p_country VARCHAR(120),
    OUT p_exists INT
)
BEGIN
    -- Truyen ket qua theo su ton tai; sua thanh cung gia tri van la hop le.
    UPDATE users
    SET name = p_name, email = p_email, country = p_country
    WHERE id = p_id;
    SELECT COUNT(*) INTO p_exists FROM users WHERE id = p_id;
END$$

DROP PROCEDURE IF EXISTS delete_user$$
CREATE PROCEDURE delete_user(IN p_id INT, OUT p_deleted_count INT)
BEGIN
    -- Bảng user_permission co FK tro toi users: phai xoa mapping truoc.
    -- Transaction bao ve khi xoa mapping thanh cong nhung xoa users that bai.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    DELETE FROM user_permission WHERE user_id = p_id;
    DELETE FROM users WHERE id = p_id;
    SET p_deleted_count = ROW_COUNT();
    COMMIT;
END$$
DELIMITER ;

-- Kiem tra sau khi tao:
SHOW PROCEDURE STATUS WHERE Db = 'demo';
-- CALL get_all_users('', 'asc');
-- CALL get_all_users('Viet Nam', 'desc');
-- Goi UPDATE/DELETE chi tren du lieu THU NGHIEM; co thay doi du lieu that.
-- CALL update_user(999999, 'Test', 'test@example.com', 'VN', @updated);
-- SELECT @updated;
-- CALL delete_user(999999, @deleted);
-- SELECT @deleted;
