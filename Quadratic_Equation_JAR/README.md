# Bài thực hành: Đóng gói thư viện giải phương trình bậc 2 thành JAR

**Mục tiêu:** Xây dựng thư viện Java độc lập để giải `ax² + bx + c = 0`, đóng gói `.jar`, rồi **dùng lại JAR trong một chương trình mới** mà không copy mã nguồn thư viện.

## Cấu trúc dự án

```text
Quadratic_Equation_JAR/
├── quadratic-equation-lib/
│   ├── pom.xml
│   ├── src/main/java/com/codegym/math/
│   │   ├── QuadraticEquation.java      # thuật toán giải
│   │   └── EquationResult.java        # kiểu kết quả và nghiệm
│   └── target/quadratic-equation-lib-1.0.0.jar   # JAR đã build kèm trong ZIP
├── quadratic-equation-app/
│   ├── pom.xml                        # dependency file JAR bên ngoài
│   ├── lib/quadratic-equation-lib.jar # JAR nhúng có sẵn
│   ├── src/main/java/com/codegym/app/Main.java
│   ├── tests/QuadraticEquationSelfTest.java
│   ├── run-windows.bat / run-unix.sh
│   └── test-windows.bat / test-unix.sh
└── README.md
```

> **Lưu ý về GitHub:** Maven thường không đưa `target/` lên Git. File JAR **quan trọng để nộp bài** đã nằm sẵn tại `quadratic-equation-app/lib/quadratic-equation-lib.jar` và được giữ trong Git. Trong ZIP còn có bản sao JAR sau khi biên dịch tại `quadratic-equation-lib/target/`.

## Hướng dẫn chạy trên Windows (PowerShell)

Mở terminal tại thư mục `Quadratic_Equation_JAR`. Bản ZIP đã có JAR nên có thể chạy ngay với JDK 17+:

```powershell
cd quadratic-equation-app
.\run-windows.bat
.\run-windows.bat 1 -3 2
.\test-windows.bat
```

Nếu đã cài Maven, tự xây lại thư viện và chạy ứng dụng:

```powershell
cd quadratic-equation-lib
mvn clean package
Copy-Item target/quadratic-equation-lib-1.0.0.jar ../quadratic-equation-app/lib/quadratic-equation-lib.jar -Force
cd ../quadratic-equation-app
mvn clean package
java -Dfile.encoding=UTF-8 -cp "target/classes;lib/quadratic-equation-lib.jar" com.codegym.app.Main
java -Dfile.encoding=UTF-8 -cp "target/classes;lib/quadratic-equation-lib.jar" com.codegym.app.Main 1 -3 2
```

**macOS/Linux:** chạy `sh run-unix.sh` hoặc `sh run-unix.sh 1 -3 2`, `sh test-unix.sh` từ thư mục `quadratic-equation-app` (dấu phân cách classpath `:` khác Windows `;`).

## Các trường hợp được xử lý

| Hệ số `(a,b,c)` | Loại phương trình | Kết quả |
|---|---|---|
| `(1, -3, 2)` | Bậc hai, Δ > 0 | Hai nghiệm 1 và 2 |
| `(1, 2, 1)` | Bậc hai, Δ = 0 | Nghiệm kép -1 |
| `(1, 0, 1)` | Bậc hai, Δ < 0 | Không có nghiệm **thực** |
| `(0, 2, -8)` | Bậc nhất | Nghiệm 4 |
| `(0, 0, 5)` | Vô nghiệm | Không có nghiệm |
| `(0, 0, 0)` | Đồng nhất | Vô số nghiệm |

**API sử dụng:** `QuadraticEquation.solve(a,b,c)` trả về `EquationResult`; dùng `result.getType()`, `getX1()`, `getX2()`, `getDiscriminant()` để lấy kết quả. `getX1()`/`getX2()` là `Double` có thể bằng `null` khi không có nghiệm tương ứng. Với Δ > 0, nghiệm được sắp theo thứ tự tăng dần. Không xét nghiệm phức.

Đối với hệ số không hữu hạn (NaN/Infinity) hoặc Δ tràn kiểu `double`, thư viện chủ động báo lỗi thay vì đưa ra nghiệm sai. Để tránh mất độ chính xác do triệt tiêu số, tính hai nghiệm phân biệt bằng dạng biến đổi tương đương công thức nghiệm truyền thống.

## Điểm quan trọng của đóng gói JAR

- `quadratic-equation-lib` có `packaging=jar`. Có thể tạo lại bằng `mvn clean package`.
- `quadratic-equation-app` là dự án Maven **độc lập**. App không có bản sao của `QuadraticEquation.java` hay `EquationResult.java`.
- `app/pom.xml` dùng `system` scope với `${project.basedir}/lib/quadratic-equation-lib.jar` **theo mục tiêu luyện tập nhúng JAR cục bộ**. Cách này không được khuyến nghị cho dự án thực tế; hướng tốt hơn là cài thư viện bằng `mvn install` hoặc đẩy lên Maven repository và dùng dependency bình thường.
- Lệnh Java lúc chạy cần chứa **cả** `target/classes` lẫn `lib/quadratic-equation-lib.jar` trong classpath.

## Kiểm thử

Bài kiểm thử Java có sẵn tại `quadratic-equation-app/tests/QuadraticEquationSelfTest.java`, chạy qua `test-windows.bat`/`test-unix.sh`. Bao gồm: 2 nghiệm, nghiệm kép, vô nghiệm thực, bậc nhất, vô nghiệm, vô số nghiệm, nghiệm phân số, độ chính xác số và các hệ số không hợp lệ.

Ở môi trường tạo bài: thư viện đã được biên dịch bằng `javac --release 17`, đóng gói bằng lệnh `jar`, và **ứng dụng được biên dịch/chạy bằng classpath chỉ chứa JAR**. Maven không được cài tại môi trường này, nên cần xác nhận `mvn clean package` trên máy học viên.

## Nộp bài GitHub

Giải nén toàn bộ thư mục `Quadratic_Equation_JAR` vào repo `JSP-homework` và chạy tại gốc repo:

```bash
git add Quadratic_Equation_JAR/
git commit -m "feat: build and reuse quadratic equation JAR library"
git push origin main
```

Link README dự kiến sau khi push:
https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/Quadratic_Equation_JAR/README.md

## Mã nguồn Java quan trọng (bản sao đầy đủ để tiện chấm bài)

### Thư viện - QuadraticEquation.java

`quadratic-equation-lib/src/main/java/com/codegym/math/QuadraticEquation.java`

```java
package com.codegym.math;

import com.codegym.math.EquationResult.Type;

/**
 * Thư viện giải ax² + bx + c = 0 với a, b, c là số thực hữu hạn.
 * Khi a = 0, tự chuyển sang giải phương trình bậc nhất hoặc suy biến.
 */
public final class QuadraticEquation {
    private final double a;
    private final double b;
    private final double c;

    public QuadraticEquation(double a, double b, double c) {
        if (!Double.isFinite(a) || !Double.isFinite(b) || !Double.isFinite(c)) {
            throw new IllegalArgumentException("a, b, c phải là số thực hữu hạn.");
        }
        this.a = a;
        this.b = b;
        this.c = c;
    }

    public static EquationResult solve(double a, double b, double c) {
        return new QuadraticEquation(a, b, c).solve();
    }

    /** Giải phương trình trên tập số thực (không tính nghiệm phức). */
    public EquationResult solve() {
        if (a == 0.0) {
            if (b != 0.0) {
                return EquationResult.of(Type.LINEAR_ROOT, -c / b, null, null);
            }
            return EquationResult.of(c == 0.0 ? Type.INFINITE_SOLUTIONS : Type.NO_SOLUTION,
                    null, null, null);
        }

        double delta = b * b - 4.0 * a * c;
        if (!Double.isFinite(delta)) {
            throw new ArithmeticException("Delta vượt phạm vi biểu diễn của kiểu double.");
        }
        if (delta < 0.0) {
            return EquationResult.of(Type.NO_REAL_ROOTS, null, null, delta);
        }
        if (delta == 0.0) {
            return EquationResult.of(Type.DOUBLE_ROOT, -b / (2.0 * a), null, delta);
        }

        // Công thức tương đương (-b ± sqrt(delta)) / (2a),
        // viết theo dạng ổn định số để hạn chế mất chữ số khi trừ hai số gần nhau.
        double sqrtDelta = Math.sqrt(delta);
        double q = -0.5 * (b + Math.copySign(sqrtDelta, b));
        double x1;
        double x2;
        if (q != 0.0) {
            x1 = q / a;
            x2 = c / q;
        } else {
            x1 = (-b - sqrtDelta) / (2.0 * a);
            x2 = (-b + sqrtDelta) / (2.0 * a);
        }
        if (!Double.isFinite(x1) || !Double.isFinite(x2)) {
            throw new ArithmeticException("Nghiệm vượt phạm vi biểu diễn của kiểu double.");
        }
        if (x1 > x2) {
            double temp = x1;
            x1 = x2;
            x2 = temp;
        }
        return EquationResult.of(Type.TWO_REAL_ROOTS, x1, x2, delta);
    }

    public double getA() { return a; }
    public double getB() { return b; }
    public double getC() { return c; }
}
```

### Thư viện - EquationResult.java

`quadratic-equation-lib/src/main/java/com/codegym/math/EquationResult.java`

```java
package com.codegym.math;

/**
 * Kết quả bất biến của phép giải phương trình ax² + bx + c = 0 trên tập số thực.
 * Nếu không có nghiệm thực thì getX1()/getX2() trả về null.
 */
public final class EquationResult {
    public enum Type {
        TWO_REAL_ROOTS,
        DOUBLE_ROOT,
        NO_REAL_ROOTS,
        LINEAR_ROOT,
        NO_SOLUTION,
        INFINITE_SOLUTIONS
    }

    private final Type type;
    private final Double x1;
    private final Double x2;
    private final Double discriminant;

    private EquationResult(Type type, Double x1, Double x2, Double discriminant) {
        this.type = type;
        this.x1 = x1;
        this.x2 = x2;
        this.discriminant = discriminant;
    }

    static EquationResult of(Type type, Double x1, Double x2, Double discriminant) {
        return new EquationResult(type, x1, x2, discriminant);
    }

    public Type getType() {
        return type;
    }

    /** Nghiệm duy nhất hoặc nghiệm nhỏ hơn (khi có hai nghiệm). */
    public Double getX1() {
        return x1;
    }

    /** Nghiệm lớn hơn, chỉ có khi có hai nghiệm phân biệt. */
    public Double getX2() {
        return x2;
    }

    /** Delta = b*b - 4*a*c, null nếu phương trình suy biến thành bậc nhất. */
    public Double getDiscriminant() {
        return discriminant;
    }
}
```

### Ứng dụng - Main.java

`quadratic-equation-app/src/main/java/com/codegym/app/Main.java`

```java
package com.codegym.app;

import com.codegym.math.EquationResult;
import com.codegym.math.QuadraticEquation;
import java.util.Locale;

/** Minh họa việc import và sử dụng thư viện từ file JAR bên ngoài. */
public final class Main {
    private Main() { }

    public static void main(String[] args) {
        try {
            if (args.length == 3) {
                display(Double.parseDouble(args[0]), Double.parseDouble(args[1]),
                        Double.parseDouble(args[2]));
            } else if (args.length == 0) {
                System.out.println("DEMO: GỌI THƯ VIỆN PHƯƠNG TRÌNH BẬC HAI TỪ FILE .JAR");
                display(1, -3, 2);    // Hai nghiệm: 1 và 2
                display(1, 2, 1);     // Nghiệm kép: -1
                display(1, 0, 1);     // Không có nghiệm thực
                display(0, 2, -8);    // Bậc nhất: 4
                display(0, 0, 5);     // Vô nghiệm
                display(0, 0, 0);     // Vô số nghiệm
            } else {
                System.err.println("Cách dùng: java ... com.codegym.app.Main [a b c]");
                System.exit(2);
            }
        } catch (RuntimeException ex) {
            System.err.println("Dữ liệu không hợp lệ: " + ex.getMessage());
            System.exit(2);
        }
    }

    private static void display(double a, double b, double c) {
        EquationResult result = QuadraticEquation.solve(a, b, c);
        System.out.printf(Locale.US, "\n%.3fx² %+.3fx %+.3f = 0%n", a, b, c);
        switch (result.getType()) {
            case TWO_REAL_ROOTS -> System.out.printf(Locale.US,
                    "Hai nghiệm thực: x1 = %.6f; x2 = %.6f%n", result.getX1(), result.getX2());
            case DOUBLE_ROOT -> System.out.printf(Locale.US,
                    "Nghiệm kép: x = %.6f%n", result.getX1());
            case NO_REAL_ROOTS -> System.out.println("Phương trình vô nghiệm trên tập số thực.");
            case LINEAR_ROOT -> System.out.printf(Locale.US,
                    "Phương trình bậc nhất: x = %.6f%n", result.getX1());
            case NO_SOLUTION -> System.out.println("Phương trình vô nghiệm.");
            case INFINITE_SOLUTIONS -> System.out.println("Phương trình có vô số nghiệm.");
        }
    }
}
```

### Cấu hình dependency JAR trong app/pom.xml

```xml
<dependency>
    <groupId>com.codegym</groupId>
    <artifactId>quadratic-equation-lib</artifactId>
    <version>1.0.0</version>
    <scope>system</scope>
    <systemPath>${project.basedir}/lib/quadratic-equation-lib.jar</systemPath>
</dependency>
```
