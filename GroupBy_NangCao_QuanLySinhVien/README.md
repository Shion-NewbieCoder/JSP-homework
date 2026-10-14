# Bai tap Group By nang cao - QuanLySinhVien

Bai lam gom 3 truy van SELECT trong `group_by_nang_cao.sql`:

1. Lay tat ca mon hoc co `Credit` cao nhat (giu truong hop dong hang).
2. Lay mon hoc co diem thi (`Mark`) cao nhat tren tat ca cac bai thi; chong trung mon neu nhieu sinh vien dong diem.
3. Liet ke thong tin moi hoc vien va diem trung binh giam dan. `LEFT JOIN` giu ca hoc vien chua co diem; diem trung binh cua ho la `NULL`.

## Cach chay

1. Mo MySQL Workbench va ket noi database da tao o bai truoc.
2. Mo `group_by_nang_cao.sql` va thuc thi cac truy van. Khong can tao lai CSDL hoac INSERT lai du lieu.
3. Kiem tra cac Result Grid, sau do push file len GitHub va nop **link truc tiep den file SQL** (`.../blob/main/GroupBy_NangCao_QuanLySinhVien/group_by_nang_cao.sql`).

## Ket qua du kien voi du lieu mau (3 hoc vien, 4 mon, 3 diem)

| Cau | Ket qua |
| --- | --- |
| 1 | RDBMS (Credit = 10) |
| 2 | C (diem cao nhat = 12) |
| 3 | Hung = 10; Hoa = 10; Manh = NULL (chua co diem) |

Neu du lieu da thay doi tren may, ket qua co the khac: truy van van tu tinh theo du lieu hien tai.
