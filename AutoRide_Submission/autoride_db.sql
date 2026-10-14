-- AutoRide: Chuyen doi Activity Diagram thanh CSDL quan he
-- MySQL 8.0.16+ (ho tro CHECK neu bo sung sau)
-- CHU Y: Script khoi tao 1 lan tren CSDL autoride_db chua co cac bang.
-- KHONG chay lai tren CSDL da tao bang va nhap du lieu, tranh trung bang/bien so.
-- Chi dung de nop va khoi tao kiem thu tren CSDL moi.

-- PHAN A: MO HINH CU (LEGACY)
CREATE DATABASE IF NOT EXISTS autoride_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE autoride_db;

CREATE TABLE Cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT,
    customer_name VARCHAR(100) NOT NULL,
    rent_date DATETIME NOT NULL,
    return_date DATETIME,
    status VARCHAR(50) DEFAULT 'BOOKED',
    FOREIGN KEY (car_id) REFERENCES Cars(car_id)
);

-- PHAN B: NANG CAP SCHEMA (ALTER TABLE, BAO TOAN CAU TRUC CU)
ALTER TABLE Rentals
    MODIFY COLUMN status ENUM(
        'BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED'
    ) NOT NULL DEFAULT 'BOOKED',
    ADD COLUMN security_deposit DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    ADD COLUMN late_fee DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    ADD COLUMN damage_fee DECIMAL(12,2) NOT NULL DEFAULT 0.00;

-- Moi hop dong co the duoc kiem tra nhieu lan (quan he 1-N).
CREATE TABLE Inspections (
    inspection_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    inspection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    damage_description TEXT,
    inspector_name VARCHAR(100) NOT NULL,
    CONSTRAINT fk_inspections_rentals
        FOREIGN KEY (rental_id)
        REFERENCES Rentals(rental_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- PHAN C: MO PHONG NGHIEP VU
-- 1. Them xe
INSERT INTO Cars (model_name, license_plate)
VALUES ('Toyota Vios', '30A-12345');
SET @car_id = LAST_INSERT_ID();

-- 2. Dat xe va dong coc 10.000.000 VND
INSERT INTO Rentals (
    car_id, customer_name, rent_date, status, security_deposit
) VALUES (
    @car_id, 'Nguyen Van A', '2026-10-14 08:00:00',
    'BOOKED', 10000000.00
);
SET @rental_id = LAST_INSERT_ID();

-- 3. Nhan xe
UPDATE Rentals
SET status = 'ACTIVE'
WHERE rental_id = @rental_id;

-- 4. Kiem tra xe: vo den pha trai
INSERT INTO Inspections (
    rental_id, inspection_date, damage_description, inspector_name
) VALUES (
    @rental_id, '2026-10-16 08:00:00',
    'Vo den pha trai', 'Tran Thi B'
);

-- 5. Tra xe, ghi nhan phi hu hong 2.000.000 VND
UPDATE Rentals
SET status = 'COMPLETED',
    return_date = '2026-10-16 08:00:00',
    late_fee = 0.00,
    damage_fee = 2000000.00
WHERE rental_id = @rental_id;

-- PHAN D: DOI SOAT TIEN HOAN COC
SELECT
    r.rental_id,
    r.customer_name,
    r.status,
    i.damage_description,
    r.security_deposit,
    r.late_fee,
    r.damage_fee,
    (r.security_deposit - r.late_fee - r.damage_fee) AS refund_amount
FROM Rentals AS r
JOIN Inspections AS i
    ON i.rental_id = r.rental_id
WHERE r.rental_id = @rental_id;

-- Ket qua ky vong: refund_amount = 8000000.00 (VND)
