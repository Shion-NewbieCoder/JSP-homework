# Bài thực hành: Sử dụng VIEW trong MySQL

**CSDL:** `classicmodels` — bảng `customers`.

## Yêu cầu

1. Tạo view `customer_views` lấy `customerNumber`, `customerName`, `phone`.
2. Truy vấn toàn bộ dữ liệu từ view.
3. Cập nhật định nghĩa view bằng `CREATE OR REPLACE VIEW`, bổ sung `contactFirstName`, `contactLastName` và lọc `city = 'Nantes'`.
4. Truy vấn lại view sau khi cập nhật.
5. Xóa view `customer_views`.

## Cách chạy

- Đảm bảo đã import database `classicmodels` từ bài trước và bảng `customers` có dữ liệu.
- Trong **MySQL Workbench**, mở `using_view.sql` và chạy toàn bộ file.
- Quan sát: bảng kết quả đầu tiên hiển thị 3 cột; bảng kết quả sau cập nhật có 5 cột và chỉ chứa khách hàng ở Nantes.
- Câu truy vấn cuối trong `information_schema.VIEWS` trả về `so_view_con_lai = 0` nếu xóa view thành công.

**Chú ý:** `DROP VIEW` ở cuối bài là chủ ý theo yêu cầu: sau khi chạy xong, `customer_views` **không còn tồn tại**. Để xem lại view, có thể chạy lại toàn bộ file hoặc chỉ chạy các bước trước `DROP VIEW`.

**An toàn:** Script không `UPDATE`, `DELETE` hay `DROP` bảng `customers`; chỉ thao tác với view.

## Đưa lên GitHub

Giải nén thư mục `UsingView_ClassicModels` vào repo `JSP-homework`, sau đó mở Terminal trong repo:

```sh
git add UsingView_ClassicModels/
git commit -m "feat: add MySQL view practice"
git push origin main
```

Sau khi push thành công, nộp link **trực tiếp tới file SQL**, không dùng link clone `.git`:

https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/UsingView_ClassicModels/using_view.sql

Mã lệnh tham khảo đã đối chiếu với `view.sql` trong nhánh `dev` của repo `codegym-vn/jwbd-2023-using-view` (đề bài ghi `develop`, nhưng repo có nhánh `dev`).
