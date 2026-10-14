-- BAI TAP: STORED PROCEDURE VOI THAM SO IN, OUT, INOUT
-- CSDL: classicmodels - MySQL 8.0+
-- Chay toan bo file trong MySQL Workbench (khong sua du lieu customers).
-- Co the chay lai vi da xoa procedure cu truoc khi tao.

USE classicmodels;

-- ============================================================
-- 1. THAM SO IN: TIM KHACH HANG THEO MA
-- ============================================================
DROP PROCEDURE IF EXISTS getCusById;

DELIMITER //
CREATE PROCEDURE getCusById(IN cusNum INT)
BEGIN
    SELECT *
    FROM customers
    WHERE customerNumber = cusNum;
END //
DELIMITER ;

-- Vi du tim khach hang ma 175.
CALL getCusById(175);

-- ============================================================
-- 2. THAM SO OUT: DEM KHACH HANG TRONG MOT THANH PHO
-- ============================================================
DROP PROCEDURE IF EXISTS GetCustomersCountByCity;

DELIMITER //
CREATE PROCEDURE GetCustomersCountByCity(
    IN in_city VARCHAR(50),
    OUT total INT
)
BEGIN
    SELECT COUNT(customerNumber)
    INTO total
    FROM customers
    WHERE city = in_city;
END //
DELIMITER ;

-- Bien @total nhan ket qua tinh ben trong procedure.
CALL GetCustomersCountByCity('Lyon', @total);
SELECT @total AS total_customers_in_lyon;

-- ============================================================
-- 3. THAM SO INOUT: VUA NHAN, VUA CAP NHAT BIEN
-- ============================================================
DROP PROCEDURE IF EXISTS SetCounter;

DELIMITER //
CREATE PROCEDURE SetCounter(
    INOUT counter INT,
    IN inc INT
)
BEGIN
    SET counter = counter + inc;
END //
DELIMITER ;

-- Bat dau = 1; lan luot cong 1, 1, 5 => 2, 3, 8.
SET @counter = 1;
CALL SetCounter(@counter, 1);
SELECT @counter AS after_first_call;   -- 2
CALL SetCounter(@counter, 1);
SELECT @counter AS after_second_call;  -- 3
CALL SetCounter(@counter, 5);
SELECT @counter AS after_third_call;   -- 8

-- ============================================================
-- 4. KIEM TRA BA THU TUC DA DUOC TAO
-- ============================================================
SHOW PROCEDURE STATUS
WHERE Db = 'classicmodels'
  AND Name IN ('getCusById', 'GetCustomersCountByCity', 'SetCounter');
