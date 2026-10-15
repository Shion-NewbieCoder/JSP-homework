# Kiểm thử chức năng JDBC Transaction

**Kết quả tại môi trường tạo bài:** Java 17 biên dịch thành công. Test DAO/JDBC bằng `java.lang.reflect.Proxy`: **44/44 assertions đạt** trong 8 kịch bản. Test luồng Servlet với request/response mocks: **14/14 assertions đạt**.

## Những gì thực sự đã kiểm tra

| Kịch bản | Mức kiểm thử | Kết quả |
|---|---|---|
| Gán Add + View | JDBC proxy: 1 INSERT user, 2 INSERT quyền, 1 commit | PASS |
| Không chọn quyền | JDBC proxy: vẫn commit INSERT user, 0 INSERT quyền | PASS |
| Permission FK giả lập lỗi sau quyền đầu | JDBC proxy ném SQLException và gọi rollback, 0 commit | PASS |
| Không nhận generated key | SQLException, rollback | PASS |
| INSERT user trả số dòng = 0 | SQLException, rollback | PASS |
| commit() ném lỗi | rollback được gọi | PASS |
| rollback() cũng ném lỗi | lưu exception thứ cấp bằng addSuppressed | PASS |
| Servlet nhận checkbox 1 và 4 | parse thành int[]{1,4}, gọi addUserTransaction | PASS |
| Servlet nhận checkbox bị sửa thành dữ liệu sai | không gọi DAO; forward với HTTP 400 | PASS |
| DAO ném SQLException | ServletException và không sendRedirect | PASS |
| GET Edit, POST Edit, country search và sort | không phá luồng cũ | PASS |

**Giới hạn:** JDBC/Servlet mocks chỉ chứng minh các hàm được gọi và luồng xử lý lỗi. Chưa xác nhận tính nguyên tử thật của InnoDB hoặc chất lượng kết nối Tomcat/MySQL. Cần chạy `database/verify_transaction.sql` sau khi triển khai trên máy người học.

## Tái chạy mock tests bằng JDK 17, không cần Maven / Tomcat

Các file trong `tests/stubs` chỉ phục vụ kiểm thử cú pháp Jakarta Servlet. Maven chính của dự án dùng dependency thật, không biên dịch stubs.

Tại thư mục gốc `user-management/`, trên bash / Git Bash:

```sh
mkdir -p tests/build
javac --release 17 -d tests/build $(find tests/stubs -name '*.java') \
    $(find src/main/java -name '*.java') \
    tests/TxMockTest.java tests/ServletTransactionMockTest.java
java -cp tests/build TxMockTest
java -cp tests/build com.codegym.controller.ServletTransactionMockTest
```

Trên Windows PowerShell có thể chạy:

```powershell
New-Item -ItemType Directory -Force tests/build | Out-Null
$javaFiles = @(Get-ChildItem tests/stubs,src/main/java -Recurse -Filter *.java | ForEach-Object FullName)
$javaFiles += (Resolve-Path tests/TxMockTest.java).Path
$javaFiles += (Resolve-Path tests/ServletTransactionMockTest.java).Path
javac --release 17 -d tests/build $javaFiles
java -cp tests/build TxMockTest
java -cp tests/build com.codegym.controller.ServletTransactionMockTest
```

Không đưa `tests/stubs` vào `src/main/java` vì stub là bộ giả lập đơn giản, không phải Jakarta API để triển khai thật.
