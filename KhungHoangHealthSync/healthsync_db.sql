CREATE DATABASE IF NOT EXISTS healthsync_db;
USE healthsync_db;

CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);

CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);
-- =====================================================
-- TỐI ƯU BẢNG APPOINTMENTS THEO QUY TRÌNH NGHIỆP VỤ
-- =====================================================

ALTER TABLE Appointments
    DROP COLUMN is_active,

    ADD COLUMN status ENUM(
        'PENDING',
        'CONFIRMED',
        'CHECKED_IN',
        'COMPLETED',
        'CANCELLED'
    ) NOT NULL DEFAULT 'PENDING',

    ADD COLUMN deposit_amount DECIMAL(12,2) NOT NULL DEFAULT 0,

    ADD COLUMN penalty_fee DECIMAL(12,2) NOT NULL DEFAULT 0,

    ADD COLUMN cancel_reason VARCHAR(255) NULL;
    ALTER TABLE Appointments
    ADD CONSTRAINT chk_deposit_nonnegative
        CHECK (deposit_amount >= 0),

    ADD CONSTRAINT chk_penalty_nonnegative
        CHECK (penalty_fee >= 0);
        -- =====================================================
-- TẠO BẢNG ĐƠN THUỐC
-- =====================================================

CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_prescription_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES Appointments(appointment_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
-- =====================================================
-- DỮ LIỆU NỀN
-- =====================================================

INSERT INTO Patients (full_name, phone)
VALUES
('Nguyen Van A', '0901234567'),
('Tran Thi B', '0912345678');

INSERT INTO Doctors (full_name, specialty)
VALUES
('Dr. Le Minh', 'Noi tong quat'),
('Dr. Pham Lan', 'Tim mach');

-- =====================================================
-- KỊCH BẢN 1: KHÁM THÀNH CÔNG
-- =====================================================

INSERT INTO Appointments (
    patient_id,
    doctor_id,
    appointment_date,
    status,
    deposit_amount
)
VALUES (
    1,
    1,
    '2026-10-10 08:00:00',
    'PENDING',
    500000
);

UPDATE Appointments
SET status = 'CHECKED_IN'
WHERE appointment_id = 1;

UPDATE Appointments
SET status = 'COMPLETED'
WHERE appointment_id = 1;

INSERT INTO Prescriptions (
    appointment_id,
    medication_details
)
VALUES (
    1,
    'Paracetamol 500mg - uong 2 lan/ngay sau an'
);

-- =====================================================
-- KỊCH BẢN 2: HỦY LỊCH VÀ PHẠT TIỀN CỌC
-- =====================================================

INSERT INTO Appointments (
    patient_id,
    doctor_id,
    appointment_date,
    status,
    deposit_amount
)
VALUES (
    2,
    2,
    '2026-10-11 09:30:00',
    'CONFIRMED',
    300000
);

UPDATE Appointments
SET
    status = 'CANCELLED',
    cancel_reason = 'Ban viec dot xuat',
    penalty_fee = 150000
WHERE appointment_id = 2;

SELECT * FROM Appointments;
SELECT * FROM Prescriptions;

-- =====================================================
-- KIỂM TRA LỊCH HOÀN TẤT VÀ ĐƠN THUỐC
-- =====================================================

SELECT
    p.full_name AS patient_name,
    d.full_name AS doctor_name,
    a.appointment_date,
    a.status,
    a.deposit_amount,
    pr.medication_details,
    pr.issued_date
FROM Appointments a
JOIN Patients p
    ON a.patient_id = p.patient_id
JOIN Doctors d
    ON a.doctor_id = d.doctor_id
JOIN Prescriptions pr
    ON a.appointment_id = pr.appointment_id
WHERE a.status = 'COMPLETED';

-- =====================================================
-- TRIGGER: CHỈ CHO KÊ ĐƠN KHI LỊCH ĐÃ COMPLETED
-- =====================================================

DROP TRIGGER IF EXISTS trg_prescription_completed_only;

DELIMITER $$

CREATE TRIGGER trg_prescription_completed_only
BEFORE INSERT ON Prescriptions
FOR EACH ROW
BEGIN
    DECLARE appointment_status VARCHAR(20);

    SET appointment_status = (
        SELECT status
        FROM Appointments
        WHERE appointment_id = NEW.appointment_id
        LIMIT 1
    );

    IF appointment_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lich hen khong ton tai';
    END IF;

    IF appointment_status <> 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Chi duoc ke don khi lich hen da COMPLETED';
    END IF;
END$$

DELIMITER ;

INSERT INTO Prescriptions (
    appointment_id,
    medication_details
)
VALUES (
    2,
    'Thuoc thu nghiem - lenh nay phai bi chan'
);