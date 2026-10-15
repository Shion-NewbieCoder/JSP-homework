# Product Management — Final Exam

Đây là gói nộp bài kiểm tra cuối module **JSP & Servlet**.

- Mã nguồn ứng dụng: [`product-management/`](product-management/)
- Hướng dẫn triển khai: [`product-management/README.md`](product-management/README.md)
- SQL tạo bảng và dữ liệu mẫu: [`product-management/database/product_management.sql`](product-management/database/product_management.sql)
- Kiểm thử validation: [`ProductValidatorTest.java`](product-management/src/test/java/com/codegym/service/ProductValidatorTest.java)

**Đổi tên ZIP thành `[Mã_số_sinh_viên]_FinalExam.zip` trước khi nộp** (hiện đang mang tên tạm `MSSV_FinalExam.zip`).

## Giao diện minh họa

![Màn hình danh sách sản phẩm](previews/desktop.png)

Ảnh là bản xem trước HTML/CSS với dữ liệu mẫu, không phải ảnh chạy JSP trên Tomcat. Xem thêm [giao diện mobile](previews/mobile.png).

## Yêu cầu và hiện thực

| Yêu cầu | Hiện thực |
|---|---|
| Danh sách ID, tên, giá, số lượng từ DB | `ProductDAO.findAll()` → `ProductServlet` → `list.jsp` |
| Thêm | Form JSP → `ProductValidator` → `ProductDAO.insert()` |
| Sửa | `ProductDAO.findById()` → `form.jsp` → `ProductDAO.update()` |
| Xóa có xác nhận | `delete.jsp` → POST → `ProductDAO.delete()` |
| Kết nối MySQL/JDBC | `DatabaseConnection` + `database/product_management.sql` |

Đã chú trọng validate phía server, prepared statements, chặn CSRF cho POST, xử lý 404/lỗi DB và Post/Redirect/Get.

## Nội dung kỹ thuật cốt lõi

**Các phương thức `ProductDAO`:**

- `findAll()` → `SELECT id, name, price, quantity FROM products ORDER BY id DESC`
- `findById(int id)` → `SELECT ... WHERE id = ?`
- `insert(Product)` → `INSERT ... VALUES (?, ?, ?)`; lấy generated ID
- `update(Product)` → `UPDATE ... WHERE id = ?`
- `delete(int id)` → `DELETE ... WHERE id = ?`

**Đường dẫn Servlet**: `@WebServlet(urlPatterns = "/products")`.
**Mẫu thao tác dữ liệu**: GET cho xem/form, POST cho thay đổi, redirect về danh sách sau thao tác thành công.
**Thư viện**: Jakarta Servlet 6.0, JSP 3.1, JSTL 3.0, MySQL Connector/J 8.3, JUnit 5.

## Chạy thử

1. Chạy `database/product_management.sql` bằng MySQL Workbench.
2. Cấu hình `PRODUCT_DB_PASSWORD` ở môi trường chạy Tomcat.
3. Trong `product-management/`, chạy `mvn clean package`.
4. Triển khai WAR lên Tomcat 10.1+.
5. Truy cập `http://localhost:8080/product-management/products`.

Chi tiết ở README trong thư mục dự án. Chưa xác nhận tích hợp trên MySQL/Tomcat thật.
