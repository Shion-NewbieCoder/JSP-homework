# Đóng gói thư viện Java JAR và tái sử dụng với Maven

> Bài thực hành CodeGym · Java 17 · 2 dự án Maven Console độc lập · `math-lib` và `calculator-app`.

## 1. Kết quả đã chuẩn bị

- `math-lib/`: source `Calculator.java` và `pom.xml` để tạo JAR.
- `math-lib/target/math-lib-1.0-SNAPSHOT.jar`: **JAR đã được biên dịch thực tế** bằng `javac --release 17` và `jar`.
- `calculator-app/`: dự án Maven mới, sử dụng JAR từ `calculator-app/lib/math-lib.jar` (đã copy sẵn).
- `calculator-app/tests/`: bài kiểm tra độc lập 9 tình huống, không cần thư viện kiểm thử ngoài.
- `calculator-app/run-windows.bat`, `calculator-app/run-unix.sh`: chạy nhanh không cần Maven.

**Lưu ý trung thực về kiểm thử:** Môi trường chuẩn bị bài không có lệnh `mvn`, vì thế **chưa chạy `mvn clean package` thực tế**. Tuy nhiên JAR đã được build bằng bộ công cụ chuẩn của JDK, ứng dụng đã thực sự chạy và 9/9 kiểm tra đạt. Bro nên chạy Maven trên máy trước khi nộp.

## 2. Cấu trúc

```text
Calculator_JAR_Packaging/
├── README.md
├── math-lib/
│   ├── pom.xml
│   ├── src/main/java/com/codegym/Calculator.java
│   └── target/math-lib-1.0-SNAPSHOT.jar   # JAR thành phẩm
└── calculator-app/
    ├── pom.xml
    ├── lib/math-lib.jar                   # JAR từ math-lib
    ├── src/main/java/com/codegym/Main.java
    ├── tests/com/codegym/CalculatorSmokeTest.java
    ├── run-windows.bat
    └── run-unix.sh
```

## 3. Phần 1 — Build thư viện math-lib

Điều kiện: cài JDK 17+ và Maven 3.9+ (khuyến nghị).

Mở Terminal trong thư mục `math-lib`:

```powershell
cd math-lib
mvn clean package
```

Khi build thành công, Maven tạo `target/math-lib-1.0-SNAPSHOT.jar`.
**Sau khi chạy `mvn clean package` mới**, copy JAR mới sang ứng dụng để sử dụng đúng bản vừa build:

```powershell
Copy-Item target/math-lib-1.0-SNAPSHOT.jar ../calculator-app/lib/math-lib.jar -Force
```

Lưu ý: nếu Terminal là CMD truyền thống, dùng `copy target\math-lib-1.0-SNAPSHOT.jar ..\calculator-app\lib\math-lib.jar /Y`.

## 4. Phần 2 — Build và chạy calculator-app

Từ thư mục `math-lib`, chuyển sang `calculator-app`:

```powershell
cd ../calculator-app
mvn clean package
java -cp "target/classes;lib/math-lib.jar" com.codegym.Main
```

Trên macOS/Linux, ký tự phân tách classpath là `:` thay cho `;`:

```bash
java -cp 'target/classes:lib/math-lib.jar' com.codegym.Main
```

**Nếu chưa cài Maven trên Windows**, nháy đúp `calculator-app/run-windows.bat` hoặc mở CMD/PowerShell tại `calculator-app` và chạy `./run-windows.bat`. Trên macOS/Linux: `sh run-unix.sh`.

Kết quả chạy thực tế đã xác minh:

```text
Kết quả gọi từ thư viện đóng gói (.jar):
Tổng 2 số (5, 9): 14
Hiệu 2 số (5, 9): -4
Tích 2 số (5, 9): 45
Thương 2 số (10, 5): 2
```

## 5. Kiểm tra chia cho 0

Theo đúng **đề bài**, `Calculator.divide(10, 0)` sẽ ném `java.security.NoSuchAlgorithmException`.
Trong dự án thực tế nên chọn `ArithmeticException` hoặc `IllegalArgumentException`, nhưng bài này giữ đúng kiểu ngoại lệ mà CodeGym yêu cầu.

Sau khi build ứng dụng, có thể chạy bài test Java độc lập tại thư mục `calculator-app`.

**Windows (PowerShell):**

```powershell
New-Item -ItemType Directory -Force -Path target/test-classes | Out-Null
javac --release 17 -encoding UTF-8 -cp "lib/math-lib.jar" -d target/test-classes tests/com/codegym/CalculatorSmokeTest.java
java -cp "target/test-classes;lib/math-lib.jar" com.codegym.CalculatorSmokeTest
```

**Linux / macOS:**

```bash
mkdir -p target/test-classes
javac --release 17 -encoding UTF-8 -cp lib/math-lib.jar -d target/test-classes tests/com/codegym/CalculatorSmokeTest.java
java -cp 'target/test-classes:lib/math-lib.jar' com.codegym.CalculatorSmokeTest
```

Kết quả mong đợi: `PASS: 9/9 tests, bao gồm chia cho 0.`

## 6. Các mã nguồn chính

### `math-lib/src/main/java/com/codegym/Calculator.java`

```java
package com.codegym;

import java.security.NoSuchAlgorithmException;

/**
 * Thư viện phép tính số nguyên. Không chứa hàm main: ứng dụng khác sẽ gọi lại.
 */
public final class Calculator {
    private Calculator() {
        // Utility class: không cần tạo đối tượng.
    }

    public static int sum(int a, int b) {
        return a + b;
    }

    public static int sub(int a, int b) {
        return a - b;
    }

    public static int mul(int a, int b) {
        return a * b;
    }

    /**
     * Theo đúng bài tập CodeGym, phép chia cho 0 ném NoSuchAlgorithmException.
     * Trong phần mềm thực tế, ArithmeticException phù hợp hơn.
     */
    public static int divide(int a, int b) throws NoSuchAlgorithmException {
        if (b == 0) {
            throw new NoSuchAlgorithmException("Không thể chia cho 0");
        }
        return a / b;
    }
}
```

### `calculator-app/src/main/java/com/codegym/Main.java`

```java
package com.codegym;

import java.security.NoSuchAlgorithmException;

/**
 * Ứng dụng thứ hai sử dụng class Calculator ở thư viện math-lib.jar.
 * Dự án này không chứa bản sao Calculator.java.
 */
public final class Main {
    private Main() {
    }

    public static void main(String[] args) {
        System.out.println("Kết quả gọi từ thư viện đóng gói (.jar):");
        System.out.println("Tổng 2 số (5, 9): " + Calculator.sum(5, 9));
        System.out.println("Hiệu 2 số (5, 9): " + Calculator.sub(5, 9));
        System.out.println("Tích 2 số (5, 9): " + Calculator.mul(5, 9));

        try {
            System.out.println("Thương 2 số (10, 5): " + Calculator.divide(10, 5));
            // Kiểm tra xử lý ngoại lệ: bỏ comment dòng dưới để thử chia cho 0.
            // System.out.println(Calculator.divide(10, 0));
        } catch (NoSuchAlgorithmException e) {
            System.err.println("Lỗi thuật toán: " + e.getMessage());
        }
    }
}
```

### Dependency JAR trong `calculator-app/pom.xml`

```xml
<dependencies>
    <dependency>
        <groupId>com.codegym</groupId>
        <artifactId>math-lib</artifactId>
        <version>1.0</version>
        <scope>system</scope>
        <systemPath>${project.basedir}/lib/math-lib.jar</systemPath>
    </dependency>
</dependencies>
```

**Ghi chú Maven:** `scope=system` là cách mà đề yêu cầu để minh họa JAR cục bộ, nhưng Maven sẽ đưa cảnh báo vì đây không phải cách quản lý phụ thuộc tốt cho dự án lớn. Phương án chuẩn hơn là cài thư viện vào local repository bằng `mvn install` và khai báo dependency thông thường. Không đổi cách làm để bám sát bài này.

## 7. Đưa mã nguồn lên GitHub

Giải nén thư mục `Calculator_JAR_Packaging` vào repo bài tập `JSP-homework`, mở Terminal tại thư mục gốc repo và chạy:

```powershell
git add Calculator_JAR_Packaging/
git commit -m "feat: package calculator java library and reuse external jar"
git push origin main
```

**Link nộp (chỉ có hiệu lực sau khi push):**

https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/Calculator_JAR_Packaging/README.md

Dự án học tập theo đề CodeGym; không chứa thông tin bí mật hoặc cần database.
