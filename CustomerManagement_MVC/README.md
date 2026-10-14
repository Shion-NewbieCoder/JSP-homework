# Customer Management - MVC scaffold (JSP/Servlet)

> **Trạng thái: chỉ là bộ khung (scaffold), chưa phải ứng dụng CRUD hoàn chỉnh.**
> Đề bài ở **Bước 1 - Yêu cầu về việc sinh mã (BẮT BUỘC)** ghi rõ AI Agent chỉ được tạo `pom.xml`, `web.xml` đầy đủ và các file Java/JSP dạng trống hoặc khai báo cơ bản. Do đó mã nguồn **không tự triển khai GET/POST, không có nghiệp vụ thêm/sửa/xóa/xem và không có giao diện JSTL hoàn thiện**.

## 1. Mục tiêu và cấu trúc

Dự án Maven Webapp nền tảng **Java 17 / Tomcat 10.1+ / Jakarta Servlet 6.0 / Jakarta JSP 3.1 / Jakarta JSTL 3.0**. Thư mục Java chia thành `model`, `service`, `controller`; các JSP đặt trong `src/main/webapp/customer/`.

```text
customer-management/
├── pom.xml
├── .gitignore
└── src/main/
    ├── java/com/codegym/
    │   ├── model/Customer.java
    │   ├── service/CustomerService.java
    │   ├── service/CustomerServiceImpl.java
    │   └── controller/CustomerServlet.java
    └── webapp/
        ├── WEB-INF/web.xml
        ├── error-404.jsp
        └── customer/
            ├── list.jsp
            ├── create.jsp
            ├── edit.jsp
            ├── delete.jsp
            └── view.jsp
```

## 2. Ý nghĩa các thành phần

| Tầng | File | Nhiệm vụ sẽ phát triển sau |
|---|---|---|
| Model | `Customer.java` | 4 trường `id`, `name`, `email`, `address`; sau này bổ sung JavaBean methods |
| Service (interface) | `CustomerService.java` | Định nghĩa 5 thao tác `findAll`, `save`, `findById`, `update`, `remove` |
| Service (implementation) | `CustomerServiceImpl.java` | Khung `Map<Integer, Customer>` lưu dữ liệu tạm; sau này mới `implements CustomerService` |
| Controller | `CustomerServlet.java` | Có mapping `/customers`, chưa có `doGet`/`doPost` |
| View | `customer/*.jsp` | Năm giao diện danh sách, thêm, sửa, xóa, xem chi tiết; hiện mới là chú thích TODO |
| View | `error-404.jsp` | Placeholder khi không tìm thấy khách hàng |

**Vì sao chưa làm đủ 5 chức năng?** Hướng dẫn có đoạn mã CRUD mẫu ở Bước 3, nhưng yêu cầu tạo file tại Bước 1 nêu rõ **không được tự động sinh logic nghiệp vụ và HTML/JSTL hoàn chỉnh**. Mình giữ đúng quy định bắt buộc ở giai đoạn scaffold; không giả vờ đã chạy được giao diện CRUD.

## 3. Build & Deploy

Yêu cầu máy có JDK 17+, Maven và Apache Tomcat **10.1.x** (Tomcat 9 không tương thích thư viện `jakarta.servlet`). Tại thư mục có `pom.xml`:

```powershell
mvn clean package
```

Nếu lệnh trả `BUILD SUCCESS`, file WAR sẽ ở `target/customer-management.war`. Triển khai WAR qua Tomcat Manager/IDE hoặc copy đến thư mục `webapps/` của Tomcat. Đường dẫn dự kiến: `http://localhost:8080/customer-management/customers`.

**Lưu ý quan trọng:** Đường dẫn `/customers` chỉ có mapping Servlet; vì `doGet`/`doPost` chưa được viết nên **chưa thể hiển thị danh sách**. Đó là hành vi dự kiến của một scaffold, không phải lỗi cấu hình.

## 4. Các bước hoàn thiện trong bài tiếp theo

1. Bổ sung constructors và getters/setters cho `Customer` để JSTL EL có thể truy cập thuộc tính.
2. Cho `CustomerServiceImpl` triển khai `CustomerService`, thêm dữ liệu mẫu vào Map và hoàn thiện các phương thức CRUD.
3. Trong `CustomerServlet`, triển khai `doGet` và `doPost`; GET xử lý list/create/edit/delete/view, POST xử lý create/edit/delete.
4. Dùng `request.getDispatcher` hoặc `getRequestDispatcher(...).forward(...)` để chuyển dữ liệu sang JSP, dùng `request.getContextPath()` cho mọi liên kết/form.
5. Viết HTML/JSTL cho 5 trang khách hàng và thông báo 404. Với JSTL Jakarta 3.0: `<%@ taglib prefix="c" uri="jakarta.tags.core" %>`.
6. Kiểm thử thêm/sửa/xóa/xem, ID không tồn tại, dữ liệu thiếu và điều hướng về danh sách.

Dữ liệu dự kiến lưu trong **Map tĩnh**, không có MySQL; dữ liệu sẽ bị mất khi khởi động lại hoặc redeploy ứng dụng.

## 5. Kiểm tra cấu trúc và phạm vi

Đã kiểm tra cú pháp XML và biên dịch các class Java không phụ thuộc Servlet. `CustomerServlet` được kiểm tra cú pháp bằng Servlet API stub; **chưa build bằng Maven hoặc chạy Tomcat thực tế ở môi trường tạo file**, nên không khẳng định ứng dụng đã triển khai.

## 6. GitHub

Giải nén `CustomerManagement_MVC.zip` vào root của repo `JSP-homework`, giữ nguyên thư mục `CustomerManagement_MVC/` rồi chạy:

```powershell
git add CustomerManagement_MVC/
git commit -m "chore: scaffold customer management MVC webapp"
git push origin main
```

Sau khi push, link nộp có thể là `https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/CustomerManagement_MVC/README.md`.

> Nếu giảng viên yêu cầu **chạy được CRUD ngay bây giờ**, phải hoàn thành các bước ở mục 4. Bản này chỉ đáp ứng giai đoạn **AI tạo khung dự án** theo đúng ràng buộc của đề.
