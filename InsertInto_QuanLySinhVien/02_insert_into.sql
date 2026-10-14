-- Bai tap INSERT INTO - QuanLySinhVien
-- Run once, after the four tables Class, Student, Subject, Mark exist and are empty.
USE QuanLySinhVien;

-- 1. Class (3 rows)
INSERT INTO Class (ClassID, ClassName, StartDate, Status)
VALUES (1, 'A1', '2008-12-20', 1),
       (2, 'A2', '2008-12-22', 1),
       (3, 'B3', CURRENT_DATE(), 0);

-- 2. Student (3 rows). Phone for Hoa is NULL.
INSERT INTO Student (StudentID, StudentName, Address, Phone, Status, ClassID)
VALUES (1, 'Hung', 'Ha Noi', '0912113113', 1, 1),
       (2, 'Hoa', 'Hai phong', NULL, 1, 1),
       (3, 'Manh', 'HCM', '0123123123', 0, 2);

-- 3. Subject (4 rows)
INSERT INTO Subject (SubID, SubName, Credit, Status)
VALUES (1, 'CF', 5, 1),
       (2, 'C', 6, 1),
       (3, 'HDJ', 5, 1),
       (4, 'RDBMS', 10, 1);

-- 4. Mark (3 rows). Mark=12 is taken verbatim from the assignment.
INSERT INTO Mark (MarkID, SubID, StudentID, Mark, ExamTimes)
VALUES (1, 1, 1, 8, 1),
       (2, 1, 2, 10, 2),
       (3, 2, 1, 12, 1);

-- Check that all rows were inserted as specified.
SELECT * FROM Class ORDER BY ClassID;
SELECT * FROM Student ORDER BY StudentID;
SELECT * FROM Subject ORDER BY SubID;
SELECT * FROM Mark ORDER BY MarkID;

SELECT 'Class' AS table_name, COUNT(*) AS total FROM Class
UNION ALL SELECT 'Student', COUNT(*) FROM Student
UNION ALL SELECT 'Subject', COUNT(*) FROM Subject
UNION ALL SELECT 'Mark', COUNT(*) FROM Mark;
