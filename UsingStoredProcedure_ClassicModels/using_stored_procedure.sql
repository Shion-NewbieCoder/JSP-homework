-- BAI THUC HANH: STORED PROCEDURE - CLASSICMODELS
-- He quan tri: MySQL (chay trong MySQL Workbench)
-- Yeu cau: da import database classicmodels va co bang customers.
-- Chi tao/thay the procedure, KHONG sua du lieu bang customers.

USE classicmodels;

-- BUOC 1: TAO PROCEDURE DAU TIEN: LIET KE TAT CA KHACH HANG.
-- DROP IF EXISTS giup chay lai file tren database bai tap ma khong bao trung ten.
DROP PROCEDURE IF EXISTS findAllCustomers;

DELIMITER //
CREATE PROCEDURE findAllCustomers()
BEGIN
    SELECT *
    FROM customers;
END //
DELIMITER ;

-- BUOC 2: GOI PROCEDURE VUA TAO.
CALL findAllCustomers();

-- BUOC 3: THAY DOI NOI DUNG PROCEDURE BANG CACH XOA VA TAO LAI.
-- MySQL khong ho tro ALTER PROCEDURE de sua phan than BEGIN ... END.
DROP PROCEDURE IF EXISTS findAllCustomers;

DELIMITER //
CREATE PROCEDURE findAllCustomers()
BEGIN
    SELECT *
    FROM customers
    WHERE customerNumber = 175;
END //
DELIMITER ;

-- BUOC 4: GOI LAI PROCEDURE SAU KHI THAY DOI.
CALL findAllCustomers();

-- BUOC 5: KIEM TRA PROCEDURE HIEN DANG TON TAI.
SHOW CREATE PROCEDURE findAllCustomers;
