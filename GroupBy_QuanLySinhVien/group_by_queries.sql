-- BAI TAP: HAM THONG DUNG VA GROUP BY - QUAN LY SINH VIEN
-- Du lieu: Bai INSERT INTO QuanLySinhVien da hoan thanh truoc do.
-- Chi dung SELECT, KHONG thay doi du lieu hoac tao lai database.

USE QuanLySinhVien;

-- 1. Hien thi so luong sinh vien o tung noi.
SELECT Address, COUNT(StudentID) AS so_luong_hoc_vien
FROM Student
GROUP BY Address
ORDER BY Address;

-- 2. Tinh diem trung binh cua moi hoc vien da co diem.
-- Theo bai mau: INNER JOIN, nen hoc vien chua co diem khong xuat hien.
SELECT S.StudentID, S.StudentName, AVG(M.Mark) AS diem_trung_binh
FROM Student AS S
JOIN Mark AS M ON S.StudentID = M.StudentID
GROUP BY S.StudentID, S.StudentName
ORDER BY S.StudentID;

-- 3. Hien thi hoc vien co diem trung binh lon hon 15.
-- Neu khong co ai thoa man thi tra ve 0 dong - khong phai loi.
SELECT S.StudentID, S.StudentName, AVG(M.Mark) AS diem_trung_binh
FROM Student AS S
JOIN Mark AS M ON S.StudentID = M.StudentID
GROUP BY S.StudentID, S.StudentName
HAVING AVG(M.Mark) > 15
ORDER BY S.StudentID;

-- 4. Hien thi TAT CA hoc vien dong hang diem trung binh cao nhat.
SELECT S.StudentID, S.StudentName, AVG(M.Mark) AS diem_trung_binh
FROM Student AS S
JOIN Mark AS M ON S.StudentID = M.StudentID
GROUP BY S.StudentID, S.StudentName
HAVING AVG(M.Mark) >= ALL (
    SELECT AVG(M2.Mark)
    FROM Mark AS M2
    GROUP BY M2.StudentID
)
ORDER BY S.StudentID;
