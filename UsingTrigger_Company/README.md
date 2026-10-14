# Bài thực hành Trigger — MySQL (CodeGym)

## Nội dung
- Database: `company`
- Bảng: `employees(id, name, department, salary)`
- Trigger: `update_department`, chạy `BEFORE INSERT ON employees FOR EACH ROW`
- Quy tắc: `salary >= 5000` → Management; `salary >= 3000` → Sales; còn lại → Support.

## Hướng dẫn chạy
1. Mở MySQL Workbench và kết nối MySQL.
2. Mở `using_trigger.sql` rồi chạy **toàn bộ file** (Execute All).
3. Kiểm tra Result Grid của câu `SELECT` cuối và `SHOW TRIGGERS`.

### Kết quả mong đợi
| name | salary | department |
| --- | ---: | --- |
| John Doe | 3500.00 | Sales |
| Jane Smith | 2000.00 | Support |
| David Johnson | 6000.00 | Management |

Script dùng `IF NOT EXISTS` cho database và bảng, `DROP TRIGGER IF EXISTS` để tạo lại trigger và `INSERT ... WHERE NOT EXISTS` để không thêm trùng dữ liệu demo trong các lần chạy sau. **Không xóa dữ liệu nhân viên hiện có.** Trigger `BEFORE INSERT` chỉ tác động lúc chèn bản ghi mới, không tự thay đổi phòng ban của những bản ghi tồn tại trước khi tạo trigger.

## Nộp GitHub
Đặt thư mục `UsingTrigger_Company` ở gốc repository `JSP-homework`, sau đó chạy:

```bash
git add UsingTrigger_Company/
git commit -m "feat: practice MySQL BEFORE INSERT trigger"
git push origin main
```

Sau khi đã push, nộp link **trực tiếp** tới file SQL:

https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/UsingTrigger_Company/using_trigger.sql

## Tham khảo
CodeGym: https://github.com/codegym-vn/jwbd-2023-trigger/tree/dev
