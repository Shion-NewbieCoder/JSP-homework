# Thực hành tổng hợp MySQL: VIEW, INDEX, STORED PROCEDURE

**Bài tập:** CodeGym — thực hành tạo View, Index và Stored Procedure trên bảng `Products`.

## Nội dung

File chính: **`products_view_index_stored_procedure.sql`**.

1. Tạo CSDL `demo`, bảng `Products` đủ 7 trường: `Id`, `productCode`, `productName`, `productPrice`, `productAmount`, `productDescription`, `productStatus`; thêm 8 sản phẩm mẫu khi chưa có dữ liệu tương ứng.
2. Chạy `EXPLAIN` trước khi tạo Index. Tạo **Unique Index** `idx_products_code(productCode)` và **Composite Index** `idx_products_name_price(productName, productPrice)`. Chạy `EXPLAIN` sau và `SHOW INDEX` để kiểm tra.
3. Tạo `product_view` để xem `productCode`, `productName`, `productPrice`, `productStatus`; dùng `CREATE OR REPLACE VIEW` để thêm `productAmount` và lọc sản phẩm còn bán; `DROP VIEW` sau khi kiểm thử.
4. Tạo bốn Stored Procedure: `getAllProducts`, `addProduct`, `updateProduct`, `deleteProduct`; gọi thử đủ CRUD. Bài kiểm thử thêm một sản phẩm `TEST999`, cập nhật và xóa lại; không xóa tám sản phẩm mẫu.

## Cách chạy trong MySQL Workbench

- Mở MySQL Workbench, mở file `.sql` và nhấn **Execute All** (tia sét) để chạy toàn bộ trong cùng một phiên kết nối.
- Kiểm tra Result Grid của các lệnh `EXPLAIN`, `SHOW INDEX` và các câu `SELECT` sau khi gọi Stored Procedure.
- Kết quả đúng khi bảng có 8 sản phẩm mẫu (nếu ban đầu trống), các index hiển thị, CRUD thêm/sửa/xóa được `TEST999` và câu `SELECT COUNT(*) AS so_san_pham_test_con_lai` trả về `0`.
- Do bài yêu cầu xóa view, sau khi chạy xong **`product_view` không còn**. Bốn stored procedures vẫn tồn tại để gọi lại.
- Bạn có thể chạy lại script; lệnh tạo index kiểm tra sự tồn tại trước khi tạo, dữ liệu mẫu không được chèn trùng theo `productCode`. **Tuy nhiên, lần chạy lại, các EXPLAIN nhãn “TRƯỚC” không còn là phép thử trước Index** vì Index đã tồn tại; muốn so sánh đúng cần lưu kết quả ở lần chạy đầu, hoặc trên một database demo sạch.

## Cách đọc EXPLAIN

Tập trung vào `type`, `possible_keys`, `key` và `rows`. Với **bảng mẫu chỉ có tám dòng**, bộ tối ưu của MySQL **có thể chọn `ALL`** kể cả khi đã tạo Index, do chi phí quét cả bảng rất thấp. Vì vậy script thêm một `EXPLAIN ... FORCE INDEX` **chỉ để minh họa**, không coi đó là phép chứng minh tốc độ tăng lên. Đừng tự báo cáo `rows` hoặc tốc độ chưa đo.

Unique Index không cho phép hai sản phẩm có cùng `productCode`; Composite Index có thể hữu ích cho điều kiện tìm theo `productName` và lọc tiếp `productPrice`.

## Nộp bài GitHub

Giải nén thư mục `Products_View_Index_StoredProcedure` vào repo `JSP-homework`, rồi trong Terminal:

```powershell
git add Products_View_Index_StoredProcedure/
git commit -m "feat: add products view index and stored procedures"
git push origin main
```

Link **chỉ hoạt động sau khi push thành công**:

https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/Products_View_Index_StoredProcedure/products_view_index_stored_procedure.sql

> Lưu ý: Đây là script dành cho database **thực hành**. Nếu máy bạn đã có bảng `demo.Products` với cấu trúc khác, hãy dùng một database demo mới hoặc kiểm tra cấu trúc trước, không chạy tùy tiện trên dữ liệu thật.
