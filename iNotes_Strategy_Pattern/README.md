# iNotes — Java Web MVC + Strategy Pattern

**Bài thực hành CodeGym:** quản lý ghi chú và chuyển đổi tầng lưu trữ **MySQL ↔ File TXT** khi ứng dụng đang chạy. Đây là dự án có đủ nghiệp vụ, không phải scaffold.

## Công nghệ và yêu cầu

- Java 17, Maven WAR, Jakarta Servlet 6, JSP 3.1, JSTL 3.0, Tomcat 10.1+.
- JDBC + MySQL 8 qua MySQL Connector/J 8.4.0; UTF-8 tiếng Việt.
- Dự án Maven thực tế nằm ở [`inotes/`](inotes). `groupId=com.codegym`, `artifactId=inotes`.

## Chức năng

| Chức năng | HTTP | Ghi chú |
|---|---|---|
| Danh sách | `GET /notes` | Tiêu đề, nội dung ngắn, danh mục, thao tác |
| Tìm kiếm tiêu đề hoặc nội dung | `GET /notes?q=...` | Không phân biệt hoa/thường |
| Lọc danh mục | `GET /notes?type=2` | Phối hợp với từ khóa |
| Thêm | `GET /notes?action=create` → `POST /notes?action=save` | Kiểm tra dữ liệu, POST/Redirect/GET |
| Xem | `GET /notes?action=view&id=...` | Nội dung đầy đủ |
| Sửa | `GET /notes?action=edit&id=...` → `POST /notes?action=save` | Giữ ID |
| Xóa | `GET /notes?action=delete&id=...` → `POST /notes?action=delete` | Có xác nhận |
| Chuyển kho | `POST /notes?action=switch` | Lưu lựa chọn trong HTTP Session |

**Cấu trúc MVC / Strategy:**

```text
inotes/
├── pom.xml
├── database/
│   ├── inotes_db.sql
│   └── verify.sql
├── sample-data/notes-example.txt
└── src/main/
    ├── java/com/codegym/
    │   ├── model/Note.java, NoteType.java
    │   ├── strategy/NoteStrategy.java, NoteDBStrategy.java,
    │   │             NoteFileStrategy.java, StorageException.java
    │   ├── service/NoteManagement.java, StorageStrategyFactory.java
    │   └── controller/NoteServlet.java
    └── webapp/
        ├── index.jsp
        ├── assets/style.css
        └── WEB-INF/
            ├── web.xml
            └── views/
                ├── partials/header.jspf, footer.jspf
                └── notes/list.jsp, form.jsp, view.jsp, delete.jsp, error.jsp
```

## Cách chạy (Windows / VS Code / IntelliJ)

**1. Cần cài:** JDK 17+, Apache Maven, Apache Tomcat 10.1+. Kiểm tra `java -version` và `mvn -version`.

**2. Giải nén ZIP và mở thư mục có `pom.xml`:**

```powershell
cd .\iNotes_Strategy_Pattern\inotes
mvn clean package
```

Sau `BUILD SUCCESS`, lấy `target/inotes.war` đặt vào `TOMCAT_HOME/webapps/` và start Tomcat (`bin/startup.bat`).

**3. Mở:** http://localhost:8080/inotes/ hoặc http://localhost:8080/inotes/notes . Mặc định dùng **File TXT**, chạy được mà không cần MySQL. File lưu ở `%USERPROFILE%\.inotes
otes.txt` trên Windows hoặc `~/.inotes/notes.txt` trên Linux/macOS. Dữ liệu file ban đầu trống; muốn có ví dụ, sao chép `sample-data/notes-example.txt` thành `notes.txt` **trước lần khởi chạy**.

**4. Chế độ MySQL:** chạy file [`inotes/database/inotes_db.sql`](inotes/database/inotes_db.sql) bằng MySQL Workbench (CSDL `inotes_db`, 2 bảng quan hệ 1–N, 3 loại mặc định và 2 ghi chú demo). Đặt biến môi trường **trước khi start Tomcat**, ví dụ PowerShell:

```powershell
$env:INOTES_DB_URL = "jdbc:mysql://localhost:3306/inotes_db?useUnicode=true&characterEncoding=UTF-8"
$env:INOTES_DB_USER = "root"
$env:INOTES_DB_PASSWORD = "your_password"
```

Nếu Tomcat chạy dưới một IDE/service khác, phải khai báo biến môi trường **trong tiến trình Tomcat**, không chỉ ở Terminal khác. Restart Tomcat, tại Dashboard đổi kho sang **MySQL** rồi bấm **Chuyển đổi**. Nếu MySQL lỗi, có trang thông báo và nút chuyển về File.

> **Quan trọng:** Đổi kho lưu trữ **không chuyển dữ liệu** từ kho cũ sang kho mới. Các ghi chú thuộc hai kho riêng biệt. Lựa chọn lưu ở HTTP session của từng trình duyệt; không bị thay đổi trên các phiên khác. Đây là demo học tập, **chưa có đăng nhập**; không sử dụng để lưu nội dung bí mật hoặc đưa công khai lên Internet.

## Cấu trúc bảng MySQL

```sql
CREATE DATABASE IF NOT EXISTS inotes_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE inotes_db;
CREATE TABLE IF NOT EXISTS note_type (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS notes (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  type_id INT NOT NULL,
  CONSTRAINT fk_notes_type FOREIGN KEY(type_id) REFERENCES note_type(id)
) ENGINE=InnoDB;
```

**Danh mục:** `1=Cá nhân`, `2=Công việc`, `3=Học tập`. File Strategy dùng cùng ba ID; MySQL lấy tên loại từ bảng `note_type`. Kiểm tra dữ liệu bằng [`database/verify.sql`](inotes/database/verify.sql).

## Strategy Pattern — điểm chấm chính

**Hợp đồng thống nhất**, file `src/main/java/com/codegym/strategy/NoteStrategy.java`:

```java
public interface NoteStrategy {
    void save(Note note);
    void delete(int id);
    List<Note> findAll();
    List<Note> search(String keyword);
    Note findById(int id);
    List<NoteType> findTypes();
}
```

- **NoteDBStrategy:** MySQL JDBC sử dụng `PreparedStatement` cho INSERT/UPDATE/DELETE/SELECT và khóa ngoại. Cấu hình qua biến môi trường, **không commit mật khẩu**.
- **NoteFileStrategy:** file UTF-8 từng dòng `id|title|content|typeId`; escape `\`, `|`, xuống dòng và `
`, tránh hỏng bản ghi khi nội dung chứa ký tự đặc biệt. Ghi thông qua file tạm + `Files.move` thay thế để hạn chế lỗi ghi dở. Khóa `synchronized` bảo vệ thao tác đọc-sửa-ghi trong **một JVM** (không dành cho nhiều server cùng ghi).
- **NoteManagement:** giữ `private NoteStrategy strategy;` và `setStrategy(NoteStrategy strategy)`. Các hàm `searchNotes`, `addNote`, `deleteNote` và `updateNote` **chỉ gọi interface**; không chứa SQL hoặc logic xử lý file. Các phương thức `Note.save()`/`Note.delete(int id)` cũng ủy quyền cho strategy đã gắn bằng `using(strategy)`.
- **NoteServlet:** dựa trên lựa chọn `file/mysql` trong Session để khởi tạo context, rồi forward cùng một bộ JSP. `POST` xử lý ghi/xóa/chuyển kho và redirect sau thành công.

**Sơ đồ luồng:**

```text
Browser (JSP) -> NoteServlet -> NoteManagement (Strategy Context)
                                          |
                                      NoteStrategy
                                        /      \
                              NoteFileStrategy  NoteDBStrategy
                                notes.txt        MySQL JDBC
```

## Kiểm tra thủ công

1. Ở chế độ File, tạo ghi chú `Học Java | JDBC`, nội dung gồm dấu `|`, dấu `\` và 2 dòng. Tải lại; xem/sửa/tìm kiếm/xóa; mở file TXT kiểm tra escape và giải mã đúng.
2. Tạo ghi chú loại `Học tập`, lọc loại và tìm theo từ khóa trong nội dung.
3. Chuyển sang MySQL, xác nhận danh sách khác kho File. Tạo một ghi chú, reload và chạy `database/verify.sql`.
4. Quay về File, kiểm tra ghi chú File cũ vẫn còn.
5. Thử tên rỗng, phân loại không hợp lệ, URL ID không tồn tại. App phải từ chối hoặc trả HTTP 404/400.

## Kiểm thử có thể chạy lại

File `inotes/tests/InotesTest.java` có **27 phép kiểm tra** độc lập với MySQL/Tomcat (tạo, sửa, xóa, lọc, escape các ký tự `|`, `\`, xuống dòng, phát hiện file lỗi và thay Strategy). Trên Windows, sau khi mở Terminal tại `inotes/`, chạy `tests\run-file-tests.bat`. Bộ kiểm thử này chỉ cần JDK 17+ (không cần Maven); các bộ thử Servlet trong quá trình xây dựng dùng Jakarta API mock và không thay thế kiểm thử Tomcat thực tế.

Ảnh ở `previews/desktop.png` và `previews/mobile.png` là mô phỏng giao diện HTML/CSS, **không phải screenshot ứng dụng JSP đang chạy trên server**.

## Giới hạn và ghi chú kỹ thuật

- Dữ liệu trên File không phải CSV tiêu chuẩn mà là format pipe `id|title|content|typeId` đúng bài; có quy tắc escape.
- Thí nghiệm không có cơ chế đồng bộ hai kho. Dữ liệu MySQL bị lỗi kết nối sẽ hiển thị lỗi, không tự động âm thầm thay bằng File.
- Không có chức năng quản lý danh mục riêng hoặc authentication vì đề chỉ yêu cầu phân loại ghi chú và đổi Strategy.
- Chạy `mvn clean package` và deploy WAR trên máy có Maven/Tomcat; bộ ZIP được kiểm tra tĩnh và các thành phần Java được biên dịch/kiểm thử độc lập trong môi trường xây dựng.

## Nộp bài GitHub

Giải nén thư mục `iNotes_Strategy_Pattern` vào repo rồi:

```powershell
git add iNotes_Strategy_Pattern/
git commit -m "feat: build iNotes MVC with MySQL and File Strategy Pattern"
git push origin main
```

Link README **sau khi push**: https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/iNotes_Strategy_Pattern/README.md
