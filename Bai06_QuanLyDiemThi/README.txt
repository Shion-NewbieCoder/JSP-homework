# Bài tập - Tạo CSDL QuanLyDiemThi

## Yêu cầu

Tạo cơ sở dữ liệu `QuanLyDiemThi` gồm 4 bảng:

### HocSinh
- MaHS VARCHAR(20) - Primary Key
- TenHS VARCHAR(50)
- NgaySinh DATETIME
- Lop VARCHAR(20)
- GT VARCHAR(20)

### MonHoc
- MaMH VARCHAR(50) - Primary Key
- TenMH VARCHAR(50)
- MaGV VARCHAR(20) - Foreign Key

### BangDiem
- MaHS VARCHAR(20) - Primary Key, Foreign Key
- MaMH VARCHAR(50) - Primary Key, Foreign Key
- DiemThi INT
- NgayKT DATETIME

Khóa chính của BangDiem là khóa ghép `(MaHS, MaMH)`.

### GiaoVien
- MaGV VARCHAR(20) - Primary Key
- TenGV VARCHAR(50)
- SDT VARCHAR(10)

## Liên kết giữa các bảng

- BangDiem.MaHS tham chiếu HocSinh.MaHS
- BangDiem.MaMH tham chiếu MonHoc.MaMH
- MonHoc.MaGV tham chiếu GiaoVien.MaGV

Toàn bộ cơ sở dữ liệu và các bảng được tạo bằng câu lệnh SQL trên MySQL Workbench.