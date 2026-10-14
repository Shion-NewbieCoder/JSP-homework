-- BAI THUC HANH: TAO CO SO DU LIEU QUAN LY BAN HANG
-- He quan tri: MySQL 8.0+
-- So do: Customer (1) - (N) Order (1) - (N) OrderDetail (N) - (1) Product

CREATE DATABASE IF NOT EXISTS QuanLyBanHang
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE QuanLyBanHang;

-- 1. Khach hang: co the ton tai ngay ca khi chua mua hang.
CREATE TABLE IF NOT EXISTS Customer (
    cID INT NOT NULL AUTO_INCREMENT,
    cName VARCHAR(100) NOT NULL,
    cAge INT NULL,
    PRIMARY KEY (cID),
    CONSTRAINT chk_customer_age CHECK (cAge IS NULL OR cAge >= 0)
) ENGINE=InnoDB;

-- 2. San pham.
CREATE TABLE IF NOT EXISTS Product (
    pID INT NOT NULL AUTO_INCREMENT,
    pName VARCHAR(100) NOT NULL,
    pPrice DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (pID),
    CONSTRAINT chk_product_price CHECK (pPrice >= 0)
) ENGINE=InnoDB;

-- 3. Hoa don: moi hoa don thuoc ve mot khach hang.
-- Order la tu khoa SQL, vi vay can dung dau ` khi dat ten bang.
CREATE TABLE IF NOT EXISTS `Order` (
    oID INT NOT NULL AUTO_INCREMENT,
    cID INT NOT NULL,
    oDate DATETIME NOT NULL,
    oTotalPrice DECIMAL(14,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (oID),
    CONSTRAINT fk_order_customer
        FOREIGN KEY (cID) REFERENCES Customer(cID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_order_total CHECK (oTotalPrice >= 0)
) ENGINE=InnoDB;

-- 4. Chi tiet hoa don: lien ket hoa don va san pham.
-- Khoa chinh ghep (oID, pID) tranh trung mot san pham trong cung hoa don.
CREATE TABLE IF NOT EXISTS OrderDetail (
    oID INT NOT NULL,
    pID INT NOT NULL,
    odQTY INT NOT NULL,
    PRIMARY KEY (oID, pID),
    CONSTRAINT fk_detail_order
        FOREIGN KEY (oID) REFERENCES `Order`(oID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detail_product
        FOREIGN KEY (pID) REFERENCES Product(pID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_detail_quantity CHECK (odQTY > 0)
) ENGINE=InnoDB;

-- Xac minh sau khi chay: phai thay 4 bang.
SHOW TABLES;
