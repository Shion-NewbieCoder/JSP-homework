-- BAI THUC HANH: GROUP BY NANG CAO - QUAN LY SINH VIEN
-- Su dung CSDL QuanLySinhVien va du lieu da INSERT o cac bai truoc.
-- Chi co SELECT: khong CREATE, INSERT, UPDATE hoac DELETE.
USE QuanLySinhVien;

-- 1. Hien thi tat ca thong tin mon hoc co Credit LON NHAT.
-- So sanh voi MAX(Credit) de giu moi mon dong hang neu co.
SELECT Sub.*
FROM Subject AS Sub
WHERE Sub.Credit = (SELECT MAX(Credit) FROM Subject);

-- 2. Hien thi thong tin cac mon hoc co DIEM THI LON NHAT.
-- Lay diem cao nhat tren toan bo bang Mark, khong phai diem cao nhat tung mon.
-- DISTINCT tranh lap mon hoc neu nhieu sinh vien dong diem cao nhat.
SELECT DISTINCT Sub.SubID, Sub.SubName, Sub.Credit, Sub.Status,
       M.Mark AS highest_mark
FROM Subject AS Sub
JOIN Mark AS M ON Sub.SubID = M.SubID
WHERE M.Mark = (SELECT MAX(Mark) FROM Mark)
ORDER BY Sub.SubID;

-- 3. Hien thi thong tin hoc vien va diem trung binh, sap xep giam dan.
-- LEFT JOIN giu hoc vien chua co diem: average_mark = NULL (khong phai 0).
SELECT S.StudentID, S.StudentName, S.Address, S.Phone,
       S.Status, S.ClassID,
       ROUND(AVG(M.Mark), 2) AS average_mark
FROM Student AS S
LEFT JOIN Mark AS M ON S.StudentID = M.StudentID
GROUP BY S.StudentID, S.StudentName, S.Address,
         S.Phone, S.Status, S.ClassID
ORDER BY average_mark DESC, S.StudentID ASC;
