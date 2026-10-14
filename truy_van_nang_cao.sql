-- BAI THUC HANH: TRUY VAN DU LIEU QUAN LY SINH VIEN
-- Yeu cau: SELECT / LIKE / MONTH / BETWEEN / UPDATE / JOIN / ORDER BY
-- Su dung database QuanLySinhVien da tao va nhap du lieu o bai truoc.
-- Chu y: Yeu cau 4 CAP NHAT ClassID cua sinh vien Hung trong database.

USE QuanLySinhVien;

-- 1. Tat ca sinh vien co ten bat dau bang 'h' (khong phan biet chu hoa/thuong).
SELECT *
FROM Student
WHERE LOWER(StudentName) LIKE 'h%';

-- 2. Thong tin cac lop co thoi gian bat dau vao thang 12 (bat ky nam nao).
SELECT *
FROM Class
WHERE MONTH(StartDate) = 12;

-- 3. Tat ca thong tin mon hoc co Credit trong khoang 3 den 5 (bao gom 3 va 5).
SELECT *
FROM Subject
WHERE Credit BETWEEN 3 AND 5;

-- 4. Doi ClassID cua sinh vien co ten 'Hung' thanh 2.
UPDATE Student
SET ClassID = 2
WHERE StudentName = 'Hung';

-- Kiem tra ket qua cap nhat (Hung phai co ClassID = 2).
SELECT StudentID, StudentName, ClassID
FROM Student
WHERE StudentName = 'Hung';

-- 5. Hien thi StudentName, SubName, Mark; diem giam dan, neu bang diem thi ten tang dan.
SELECT S.StudentName, Sub.SubName, M.Mark
FROM Student AS S
JOIN Mark AS M ON S.StudentID = M.StudentID
JOIN Subject AS Sub ON M.SubID = Sub.SubID
ORDER BY M.Mark DESC, S.StudentName ASC;
