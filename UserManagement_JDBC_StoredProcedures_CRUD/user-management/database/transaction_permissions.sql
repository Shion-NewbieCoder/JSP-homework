-- BAI THUC HANH JDBC TRANSACTION: USERS + PERMISSIONS
-- Chay SAU database/init.sql (va database/stored_procedures.sql neu muon dung tinh nang cu).
-- Hai bang duoi day PHAI la InnoDB de COMMIT/ROLLBACK hoat dong.
CREATE DATABASE IF NOT EXISTS demo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE demo;

CREATE TABLE IF NOT EXISTS permission (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_permission (
    user_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (user_id, permission_id),
    CONSTRAINT fk_user_permission_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_permission_permission
        FOREIGN KEY (permission_id) REFERENCES permission(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Upsert giu nguyen ID va khong nhan doi khi chay lai.
INSERT INTO permission (id, name) VALUES
    (1, 'add'), (2, 'edit'), (3, 'delete'), (4, 'view')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Xac minh storage engine (quan trong: rollback phu thuoc InnoDB)
SELECT table_name, engine FROM information_schema.tables
WHERE table_schema='demo' AND table_name IN ('users', 'permission', 'user_permission');
SELECT * FROM permission ORDER BY id;
