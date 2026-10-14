# Bài thực hành: Chuyển đổi ERD sang mô hình dữ liệu quan hệ

## 1. Mục tiêu

Chuyển đổi sơ đồ thực thể kết hợp (ERD) quản lý nhập, xuất và đặt hàng vật tư thành mô hình dữ liệu quan hệ; xác định bảng, khóa chính (PK) và khóa ngoại (FK).

## 2. Xác định các thực thể

Theo sơ đồ ERD, có 5 thực thể chính:

| Thực thể | Thuộc tính | Khóa chính |
|---|---|---|
| PHIEUXUAT | SoPX, NgayXuat | SoPX |
| VATTU | MaVTU, TenVTU | MaVTU |
| PHIEUNHAP | SoPN, NgayNhap | SoPN |
| DONDH | SoDH, NgayDH | SoDH |
| NHACC | MaNCC, TenNCC, DiaChi, SDT | MaNCC |

**Lưu ý:** Thuộc tính `SDT` của `NHACC` là thuộc tính đa trị (elip kép trên ERD), nên tách sang một bảng riêng.

## 3. Chuyển đổi các mối quan hệ

| Quan hệ trên ERD | Hai thực thể liên quan | Bội số | Cách biểu diễn trong mô hình quan hệ |
|---|---|---|---|
| 1 - Chi tiết phiếu xuất | PHIEUXUAT – VATTU | N–N | Tạo bảng `CHITIET_PHIEUXUAT`, mang hai khóa ngoại và hai thuộc tính `DGXuat`, `SLXuat`. |
| 2 - Chi tiết phiếu nhập | PHIEUNHAP – VATTU | N–N | Tạo bảng `CHITIET_PHIEUNHAP`, mang hai khóa ngoại và hai thuộc tính `DGNhap`, `SLNhap`. |
| 3 - Chi tiết đơn đặt hàng | DONDH – VATTU | N–N | Tạo bảng `CHITIET_DONDH`, mang hai khóa ngoại. |
| 4 - Cung cấp | NHACC – DONDH | 1–N | Đưa `MaNCC` vào bảng `DONDH` làm khóa ngoại. |

## 4. Mô hình dữ liệu quan hệ sau khi chuyển đổi

Quy ước: **PK** là khóa chính, **FK** là khóa ngoại. Ký hiệu `(PK, FK)` ở nhiều cột trong cùng một bảng biểu thị **khóa chính ghép**.

### Các bảng thực thể

1. **PHIEUXUAT**(`SoPX` PK, `NgayXuat`)
2. **VATTU**(`MaVTU` PK, `TenVTU`)
3. **PHIEUNHAP**(`SoPN` PK, `NgayNhap`)
4. **NHACC**(`MaNCC` PK, `TenNCC`, `DiaChi`)
5. **DONDH**(`SoDH` PK, `NgayDH`, `MaNCC` FK → `NHACC.MaNCC`)

### Các bảng biểu diễn quan hệ N–N

6. **CHITIET_PHIEUXUAT**(
   `SoPX` PK, FK → `PHIEUXUAT.SoPX`,
   `MaVTU` PK, FK → `VATTU.MaVTU`,
   `DGXuat`, `SLXuat`
   )
   - Khóa chính ghép: (`SoPX`, `MaVTU`).

7. **CHITIET_PHIEUNHAP**(
   `SoPN` PK, FK → `PHIEUNHAP.SoPN`,
   `MaVTU` PK, FK → `VATTU.MaVTU`,
   `DGNhap`, `SLNhap`
   )
   - Khóa chính ghép: (`SoPN`, `MaVTU`).

8. **CHITIET_DONDH**(
   `SoDH` PK, FK → `DONDH.SoDH`,
   `MaVTU` PK, FK → `VATTU.MaVTU`
   )
   - Khóa chính ghép: (`SoDH`, `MaVTU`).

### Bảng dành cho thuộc tính đa trị

9. **NHACC_SDT**(
   `MaNCC` PK, FK → `NHACC.MaNCC`,
   `SDT` PK
   )
   - Khóa chính ghép: (`MaNCC`, `SDT`).
   - Mỗi nhà cung cấp có thể có nhiều số điện thoại; mỗi số điện thoại của cùng nhà cung cấp được lưu thành một dòng.

## 5. Kết luận

Từ sơ đồ ERD ban đầu, ta thu được **9 bảng quan hệ**: 5 bảng tương ứng với thực thể, 3 bảng trung gian cho các mối quan hệ N–N và 1 bảng dành cho thuộc tính đa trị `SDT`. Quan hệ 1–N giữa `NHACC` và `DONDH` được thể hiện bằng khóa ngoại `MaNCC` trong bảng `DONDH`.

Thiết kế này giữ được các thực thể, mối quan hệ, thuộc tính của quan hệ và thuộc tính đa trị có trong ERD gốc.
