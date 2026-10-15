-- CHỈ DÀNH CHO DATABASE demo cá nhân!
-- THAO TÁC CÓ TÍNH PHÁ HỦY: XÓA TOÀN BỘ DỮ LIỆU trong demo.Employee.
-- Chạy THỦ CÔNG trong Workbench trước mỗi lần kiểm tra fail/success.
USE demo;
DELETE FROM Employee;
SELECT COUNT(*) AS baseline_rows FROM Employee;
-- Dự kiến baseline_rows=0. Transaction sẽ khôi phục lại baseline này nếu lỗi.
