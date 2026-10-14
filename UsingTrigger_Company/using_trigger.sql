-- CODEGYM - BAI THUC HANH TRIGGER TRONG MYSQL
-- CSDL: company | Bang: employees | Trigger: update_department
-- Trigger BEFORE INSERT phan phong ban theo luong, khong sua du lieu cu.

-- 1. Tao CSDL va bang nhan vien neu chua co.
CREATE DATABASE IF NOT EXISTS company;
USE company;

CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL
);

-- 2. Tao BEFORE INSERT TRIGGER.
-- DROP IF EXISTS de co the chay lai script khi trigger da duoc tao.
DROP TRIGGER IF EXISTS update_department;

DELIMITER //
CREATE TRIGGER update_department
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary >= 5000 THEN
        SET NEW.department = 'Management';
    ELSEIF NEW.salary >= 3000 THEN
        SET NEW.department = 'Sales';
    ELSE
        SET NEW.department = 'Support';
    END IF;
END //
DELIMITER ;

-- 3. Them du lieu demo. Gia tri department='A' duoc trigger thay the.
-- Dung NOT EXISTS de tranh chen trung du lieu mau khi chay lai bai.
INSERT INTO employees (name, department, salary)
SELECT 'John Doe', 'A', 3500
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE name = 'John Doe' AND salary = 3500
);

INSERT INTO employees (name, department, salary)
SELECT 'Jane Smith', 'A', 2000
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE name = 'Jane Smith' AND salary = 2000
);

INSERT INTO employees (name, department, salary)
SELECT 'David Johnson', 'A', 6000
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE name = 'David Johnson' AND salary = 6000
);

-- 4. Kiem tra: John Doe = Sales, Jane Smith = Support,
-- David Johnson = Management.
SELECT id, name, department, salary
FROM employees
WHERE (name = 'John Doe' AND salary = 3500)
   OR (name = 'Jane Smith' AND salary = 2000)
   OR (name = 'David Johnson' AND salary = 6000)
ORDER BY FIELD(name, 'John Doe', 'Jane Smith', 'David Johnson'), id;

-- 5. Xac nhan trigger dang ton tai va gan voi bang employees.
SHOW TRIGGERS FROM company LIKE 'employees';
