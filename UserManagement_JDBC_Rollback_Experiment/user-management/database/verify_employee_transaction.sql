USE demo;
SELECT id, name, salary, created_Date FROM Employee ORDER BY id;
SELECT COUNT(*) AS row_count FROM Employee;
-- Khi fail & baseline trước đó trống: row_count=0.
-- Khi success & baseline trước đó trống: row_count=2,
-- Quynh salary=999.99, Ngan salary=20.00.
