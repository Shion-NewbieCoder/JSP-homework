# Bài tập: Xóa cơ sở dữ liệu

## Cách 1: Xóa CSDL bằng MySQL Workbench (GUI)

Các bước thực hiện:

1. Mở MySQL Workbench và kết nối tới MySQL Server.
2. Trong mục SCHEMAS, chọn CSDL thử nghiệm `test db`.
3. Click chuột phải vào `test db` và chọn `Drop Schema...`.
4. Trong cửa sổ xác nhận, chọn `Drop Now`.
5. Sau khi thực hiện, schema `test db` không còn xuất hiện trong danh sách SCHEMAS.

### Minh chứng

![Chọn Drop Schema](Screen%20Shots/01_Right_click_drop.png)

![Chọn Drop Now](Screen%20Shots/02_drop_now.png)

![Kết quả sau khi xóa](Screen%20Shots/03_after_drop.png)

## Cách 2: Xóa CSDL bằng câu lệnh SQL

```sql
DROP DATABASE IF EXISTS `my_database1`;