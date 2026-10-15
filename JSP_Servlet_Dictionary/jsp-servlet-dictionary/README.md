# JSP Servlet Dictionary — Maven Webapp

Ứng dụng Java Web **Từ điển Anh–Việt**. Hướng dẫn tổng thể, bảng đối chiếu CodeGym và **toàn bộ mã nguồn quan trọng** xem tại [README cấp bài tập](../README.md).

## Chạy nhanh

```powershell
mvn clean package
```

Triển khai `target/jsp-servlet-dictionary.war` lên Tomcat 10.1+ và mở:
`http://localhost:8080/jsp-servlet-dictionary/`.

## Cấu trúc chính

- [`index.jsp`](src/main/webapp/index.jsp): form POST `word` tới `/translate`.
- [`DictionaryServlet.java`](src/main/java/com/codegym/DictionaryServlet.java): xử lý tra cứu và in kết quả.
- [`DictionaryService.java`](src/main/java/com/codegym/DictionaryService.java): 25 cặp từ và nghĩa.
- [`HtmlUtil.java`](src/main/java/com/codegym/HtmlUtil.java): escape ký tự HTML.
- [`style.css`](src/main/webapp/css/style.css): giao diện đáp ứng kích thước màn hình.
- [`web.xml`](src/main/webapp/WEB-INF/web.xml): welcome file và Jakarta Servlet 6.

Test không cần Maven: `run-tests-windows.bat` hoặc `sh run-tests-unix.sh`.

Đã kiểm tra **19/19 logic**, **15/15 Servlet giả lập**, và HTML/CSS responsive. Chưa xác nhận chạy trên Tomcat thực tế.
