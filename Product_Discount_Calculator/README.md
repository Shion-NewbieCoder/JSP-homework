# Product Discount Calculator — JSP & Servlet

> Bài tập CodeGym: nhập thông tin sản phẩm, giá niêm yết, tỷ lệ chiết khấu và tính tiền giảm / giá sau giảm bằng Servlet.

**Công nghệ:** Java 17, Maven WAR, Jakarta Servlet 6.0, JSP 3.1, JSTL 3.0, Apache Tomcat 10.1+.

## 1. Mục tiêu và chức năng

- Trang **`index.jsp`** gồm ba trường **Product Description** (`productDescription`), **List Price** (`listPrice`), **Discount Percent** (`discountPercent`).
- Form sử dụng **POST** tới **`/display-discount`** (tự động dùng context path, chạy được khi WAR không triển khai ở `/`).
- `DiscountServlet` nhận dữ liệu, kiểm tra và chuyển kết quả tới `WEB-INF/views/discount-result.jsp`.
- Kết quả gồm thông tin đã nhập, **Discount Amount** và **Discount Price**.
- Kiểm tra giá âm, chiết khấu ngoài `0–100%`, giá trị không phải số, ô rỗng, tối đa 2 chữ số thập phân; trả lại thông báo và giữ dữ liệu để người dùng sửa.
- Dùng `BigDecimal` thay vì `float/double` để tránh sai số tiền tệ; tiền giảm làm tròn HALF_UP đến 2 chữ số thập phân.
- Output động được hiển thị qua JSTL `<c:out>` để escape HTML.

## 2. Công thức và ví dụ

```text
Discount Amount = List Price × Discount Percent × 0.01
Discount Price  = List Price − Discount Amount
```

| Product Description | List Price | Discount Percent | Discount Amount | Discount Price |
|---|---:|---:|---:|---:|
| Bàn phím cơ | 1.000.000 | 20% | 200.000 | 800.000 |
| Chuột gaming | 500.000 | 0% | 0 | 500.000 |
| Tai nghe | 800.000 | 100% | 800.000 | 0 |
| Sản phẩm A | 123,45 | 12,5% | 15,43 | 108,02 |


*Đơn vị tiền tệ do người nhập quyết định; ứng dụng chỉ định dạng số theo `vi-VN`, không giả định USD hoặc VND.*

## 3. Cấu trúc dự án

```text
Product_Discount_Calculator/
├── README.md                       <- tài liệu để nộp GitHub
├── previews/                       <- ảnh giao diện mô phỏng
└── jsp-servlet-product-discount/
    ├── pom.xml
    ├── .gitignore
    ├── README.md
    ├── scripts/
    │   ├── test-windows.bat
    │   └── test-linux-macos.sh
    └── src/
        ├── main/
        │   ├── java/com/codegym/
        │   │   ├── DiscountServlet.java
        │   │   └── service/
        │   │       ├── DiscountCalculator.java
        │   │       └── DiscountResult.java
        │   └── webapp/
        │       ├── index.jsp
        │       ├── assets/styles.css
        │       └── WEB-INF/
        │           ├── web.xml
        │           └── views/discount-result.jsp
        └── test/java/com/codegym/service/DiscountCalculatorSelfTest.java
```

## 4. Hướng dẫn chạy trên Windows

1. Cài **JDK 17+**, **Maven**, **Apache Tomcat 10.1+**.
2. Mở thư mục `jsp-servlet-product-discount` (nơi có `pom.xml`).
3. Đóng gói:

```powershell
mvn clean package
```

4. Chép `target/jsp-servlet-product-discount.war` vào thư mục `webapps/` của Tomcat 10.1 và khởi động Tomcat.
5. Mở **http://localhost:8080/jsp-servlet-product-discount/** và bấm **Calculate Discount** sau khi điền dữ liệu.
6. Test logic không cần Tomcat (yêu cầu máy có JDK):

```powershell
.\scripts\test-windows.bat
```

Có script riêng cho Linux/macOS: `sh scripts/test-linux-macos.sh`.

**Lưu ý:** Mã nguồn dùng gói `jakarta.servlet.*` (Tomcat 10.1+), không chạy nguyên trạng trên Tomcat 9 (`javax.servlet.*`).

## 5. Sơ đồ luồng xử lý

```text
GET /                         -> index.jsp (form)
POST /display-discount        -> DiscountServlet.doPost()
  | hợp lệ                    -> DiscountCalculator.calculate()
  |                          -> /WEB-INF/views/discount-result.jsp
  | không hợp lệ             -> request.attribute(errorMessage)
  `                          -> /index.jsp (giữ các trường đã nhập, HTTP 400)
GET /display-discount         -> redirect trở về /
```

**JSP không chứa logic tính toán**; Servlet xử lý HTTP, `DiscountCalculator` xử lý nghiệp vụ, `DiscountResult` vận chuyển kết quả.

## 6. Mã nguồn chính (đọc trực tiếp trên GitHub)

Trang này đính kèm mã quan trọng để người chấm có thể kiểm tra ngay, không cần tải ZIP. Các file thật vẫn ở đúng thư mục Maven theo mục 3.

### 6.1. `DiscountCalculator.java` (xử lý nghiệp vụ)

**File:** [`jsp-servlet-product-discount/src/main/java/com/codegym/service/DiscountCalculator.java`](jsp-servlet-product-discount/src/main/java/com/codegym/service/DiscountCalculator.java)

```java
package com.codegym.service;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Pure Java business logic for the product discount calculation.
 * All money amounts use BigDecimal (never binary floating-point).
 */
public final class DiscountCalculator {
    private static final BigDecimal ONE_HUNDRED = new BigDecimal("100");
    private static final BigDecimal MAX_PRICE = new BigDecimal("999999999999.99");

    private DiscountCalculator() {
    }

    public static DiscountResult calculate(BigDecimal listPrice, BigDecimal discountPercent) {
        if (listPrice == null || discountPercent == null) {
            throw new IllegalArgumentException("Giá và phần trăm giảm giá không được bỏ trống.");
        }
        if (listPrice.signum() < 0 || listPrice.compareTo(MAX_PRICE) > 0) {
            throw new IllegalArgumentException("Giá phải từ 0 đến 999.999.999.999,99.");
        }
        if (listPrice.scale() > 2) {
            throw new IllegalArgumentException("Giá chỉ được có tối đa 2 chữ số thập phân.");
        }
        if (discountPercent.signum() < 0 || discountPercent.compareTo(ONE_HUNDRED) > 0) {
            throw new IllegalArgumentException("Phần trăm giảm giá phải từ 0 đến 100.");
        }
        if (discountPercent.scale() > 2) {
            throw new IllegalArgumentException("Phần trăm giảm giá có tối đa 2 chữ số thập phân.");
        }

        BigDecimal price = listPrice.setScale(2, RoundingMode.UNNECESSARY);
        BigDecimal amount = price.multiply(discountPercent)
                .divide(ONE_HUNDRED, 2, RoundingMode.HALF_UP);
        BigDecimal finalPrice = price.subtract(amount);
        return new DiscountResult(price, discountPercent, amount, finalPrice);
    }
}
```

### 6.2. `DiscountResult.java` (dữ liệu kết quả)

**File:** [`jsp-servlet-product-discount/src/main/java/com/codegym/service/DiscountResult.java`](jsp-servlet-product-discount/src/main/java/com/codegym/service/DiscountResult.java)

```java
package com.codegym.service;

import java.math.BigDecimal;

/** Immutable calculation result sent to the JSP through request attributes. */
public final class DiscountResult {
    private final BigDecimal listPrice;
    private final BigDecimal discountPercent;
    private final BigDecimal discountAmount;
    private final BigDecimal discountPrice;

    public DiscountResult(BigDecimal listPrice, BigDecimal discountPercent,
                          BigDecimal discountAmount, BigDecimal discountPrice) {
        this.listPrice = listPrice;
        this.discountPercent = discountPercent;
        this.discountAmount = discountAmount;
        this.discountPrice = discountPrice;
    }

    public BigDecimal getListPrice() {
        return listPrice;
    }

    public BigDecimal getDiscountPercent() {
        return discountPercent;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public BigDecimal getDiscountPrice() {
        return discountPrice;
    }
}
```

### 6.3. `DiscountServlet.java` (POST và xử lý lỗi)

**File:** [`jsp-servlet-product-discount/src/main/java/com/codegym/DiscountServlet.java`](jsp-servlet-product-discount/src/main/java/com/codegym/DiscountServlet.java)

```java
package com.codegym;

import com.codegym.service.DiscountCalculator;
import com.codegym.service.DiscountResult;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Locale;

/** Receives POST /display-discount, validates inputs and shows the result JSP. */
@WebServlet(name = "DiscountServlet", urlPatterns = "/display-discount")
public class DiscountServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String description = trimToEmpty(request.getParameter("productDescription"));
        String rawPrice = trimToEmpty(request.getParameter("listPrice"));
        String rawPercent = trimToEmpty(request.getParameter("discountPercent"));

        try {
            if (description.isEmpty() || description.length() > 255) {
                throw new IllegalArgumentException("Mô tả sản phẩm phải có từ 1 đến 255 ký tự.");
            }
            if (rawPrice.isEmpty() || rawPercent.isEmpty()) {
                throw new IllegalArgumentException("Vui lòng nhập đầy đủ giá và tỷ lệ chiết khấu.");
            }

            BigDecimal price = new BigDecimal(rawPrice);
            BigDecimal percent = new BigDecimal(rawPercent);
            DiscountResult result = DiscountCalculator.calculate(price, percent);

            NumberFormat moneyFormat = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
            moneyFormat.setMinimumFractionDigits(2);
            moneyFormat.setMaximumFractionDigits(2);

            request.setAttribute("productDescription", description);
            request.setAttribute("listPriceFormatted", moneyFormat.format(result.getListPrice()));
            request.setAttribute("discountPercent", result.getDiscountPercent().stripTrailingZeros().toPlainString());
            request.setAttribute("discountAmountFormatted", moneyFormat.format(result.getDiscountAmount()));
            request.setAttribute("discountPriceFormatted", moneyFormat.format(result.getDiscountPrice()));
            request.getRequestDispatcher("/WEB-INF/views/discount-result.jsp")
                    .forward(request, response);
        } catch (NumberFormatException ex) {
            forwardError(request, response, description, rawPrice, rawPercent,
                    "Vui lòng nhập số hợp lệ, dùng dấu chấm cho phần thập phân.");
        } catch (IllegalArgumentException ex) {
            forwardError(request, response, description, rawPrice, rawPercent, ex.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/");
    }

    private void forwardError(HttpServletRequest request, HttpServletResponse response,
                              String description, String price, String percent, String message)
            throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        request.setAttribute("errorMessage", message);
        request.setAttribute("productDescription", description);
        request.setAttribute("listPrice", price);
        request.setAttribute("discountPercent", percent);
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
```

### 6.4. `index.jsp` (form)

**File:** [`jsp-servlet-product-discount/src/main/webapp/index.jsp`](jsp-servlet-product-discount/src/main/webapp/index.jsp)

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Tính chiết khấu và giá sau khi giảm bằng JSP và Servlet.">
    <title>Product Discount Calculator — CodeGym</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css">
</head>
<body>
    <div class="page-shell">
        <header class="topbar">
            <a class="brand" href="${pageContext.request.contextPath}/">
                <span class="brand-icon" aria-hidden="true">%</span>
                <span>Discount<span class="brand-accent">Lab</span></span>
            </a>
            <span class="course-label">JSP · SERVLET · JAVA WEB</span>
        </header>

        <main class="hero-layout">
            <section class="intro" aria-labelledby="hero-title">
                <span class="eyebrow"><span class="eyebrow-dot"></span> PRODUCT DISCOUNT CALCULATOR</span>
                <h1 id="hero-title">Tính giá ưu đãi<br><span>trong vài giây.</span></h1>
                <p>Nhập thông tin sản phẩm và mức chiết khấu để biết chính xác số tiền được giảm và giá thanh toán.</p>
                <div class="formula"><span class="formula-icon">ƒ</span><span><strong>Discount Amount</strong> = List Price × Discount Percent ÷ 100</span></div>
                <div class="decor-line"><span></span><span></span><span></span></div>
            </section>

            <section class="panel" aria-labelledby="form-title">
                <div class="panel-top"><div><span class="step">01 / CALCULATOR</span><h2 id="form-title">Thông tin sản phẩm</h2><p>Điền các trường bên dưới để tính chiết khấu.</p></div><span class="panel-symbol" aria-hidden="true">↗</span></div>
                <c:if test="${not empty requestScope.errorMessage}">
                    <div class="alert" role="alert"><strong>Không thể tính chiết khấu.</strong> <c:out value="${requestScope.errorMessage}" /></div>
                </c:if>
                <form action="${pageContext.request.contextPath}/display-discount" method="post">
                    <div class="field"><label for="productDescription">Product Description <span>Mô tả sản phẩm</span></label>
                        <input id="productDescription" name="productDescription" type="text" maxlength="255" required placeholder="Ví dụ: Bàn phím cơ Keychron" value="<c:out value='${requestScope.productDescription}' />">
                    </div>
                    <div class="field-row">
                        <div class="field"><label for="listPrice">List Price <span>Giá niêm yết</span></label>
                            <div class="input-wrap"><input id="listPrice" name="listPrice" type="number" min="0" max="999999999999.99" step="0.01" inputmode="decimal" required placeholder="1000000" value="<c:out value='${requestScope.listPrice}' />"><span class="field-unit">PRICE</span></div>
                        </div>
                        <div class="field"><label for="discountPercent">Discount Percent <span>Tỷ lệ chiết khấu</span></label>
                            <div class="input-wrap"><input id="discountPercent" name="discountPercent" type="number" min="0" max="100" step="0.01" inputmode="decimal" required placeholder="20" value="<c:out value='${requestScope.discountPercent}' />"><span class="field-unit">%</span></div>
                        </div>
                    </div>
                    <button class="submit-btn" type="submit">Calculate Discount <span aria-hidden="true">→</span></button>
                </form>
                <p class="panel-footnote">Chấp nhận tỷ lệ 0–100%. Kết quả làm tròn đến 2 chữ số thập phân.</p>
            </section>
        </main>

        <footer class="footer"><span>CODEGYM EXERCISE · PRODUCT DISCOUNT</span><span>Java 17 / Tomcat 10.1+</span></footer>
    </div>
</body>
</html>
```

### 6.5. `discount-result.jsp` (trang kết quả)

**File:** [`jsp-servlet-product-discount/src/main/webapp/WEB-INF/views/discount-result.jsp`](jsp-servlet-product-discount/src/main/webapp/WEB-INF/views/discount-result.jsp)

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kết quả chiết khấu — DiscountLab</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/styles.css">
</head>
<body>
    <div class="page-shell">
        <header class="topbar"><a class="brand" href="${pageContext.request.contextPath}/"><span class="brand-icon" aria-hidden="true">%</span><span>Discount<span class="brand-accent">Lab</span></span></a><span class="course-label">JSP · SERVLET · JAVA WEB</span></header>
        <main class="result-layout">
            <div class="result-heading"><span class="eyebrow"><span class="eyebrow-dot"></span> DISCOUNT CALCULATED</span><h1>Chiết khấu <span>đã được tính.</span></h1><p>Đây là thông tin và kết quả tính toán từ sản phẩm của bạn.</p></div>
            <section class="result-card" aria-label="Kết quả tính chiết khấu">
                <div class="result-card-header"><span class="step">02 / RESULT</span><span class="status"><span aria-hidden="true">✓</span> Thành công</span></div>
                <div class="product-title"><span>PRODUCT DESCRIPTION</span><h2><c:out value="${requestScope.productDescription}" /></h2></div>
                <div class="metrics">
                    <div class="metric"><span>List Price <small>Giá niêm yết</small></span><strong><c:out value="${requestScope.listPriceFormatted}" /></strong></div>
                    <div class="metric"><span>Discount Percent <small>Tỷ lệ chiết khấu</small></span><strong><c:out value="${requestScope.discountPercent}" />%</strong></div>
                    <div class="metric savings"><span>Discount Amount <small>Số tiền được giảm</small></span><strong>− <c:out value="${requestScope.discountAmountFormatted}" /></strong></div>
                </div>
                <div class="total"><span>DISCOUNT PRICE <small>Giá sau chiết khấu</small></span><strong><c:out value="${requestScope.discountPriceFormatted}" /></strong></div>
                <a class="submit-btn back-btn" href="${pageContext.request.contextPath}/"><span aria-hidden="true">←</span> Tính sản phẩm khác</a>
                <p class="panel-footnote">Đơn vị tiền tệ theo giá bạn nhập. Giá được làm tròn đến 2 chữ số thập phân.</p>
            </section>
        </main>
        <footer class="footer"><span>CODEGYM EXERCISE · PRODUCT DISCOUNT</span><span>Java 17 / Tomcat 10.1+</span></footer>
    </div>
</body>
</html>
```

### 6.6. `web.xml` (cấu hình)

**File:** [`jsp-servlet-product-discount/src/main/webapp/WEB-INF/web.xml`](jsp-servlet-product-discount/src/main/webapp/WEB-INF/web.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">
    <display-name>Product Discount Calculator</display-name>
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
</web-app>
```

### 6.7. `pom.xml` (dependency Maven)

**File:** [`jsp-servlet-product-discount/pom.xml`](jsp-servlet-product-discount/pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.codegym</groupId>
    <artifactId>jsp-servlet-product-discount</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <name>Product Discount Calculator</name>
    <properties>
        <maven.compiler.release>17</maven.compiler.release>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    <dependencies>
        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>6.0.0</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>jakarta.servlet.jsp</groupId>
            <artifactId>jakarta.servlet.jsp-api</artifactId>
            <version>3.1.1</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>jakarta.servlet.jsp.jstl</groupId>
            <artifactId>jakarta.servlet.jsp.jstl-api</artifactId>
            <version>3.0.0</version>
        </dependency>
        <dependency>
            <groupId>org.glassfish.web</groupId>
            <artifactId>jakarta.servlet.jsp.jstl</artifactId>
            <version>3.0.1</version>
        </dependency>
    </dependencies>
    <build>
        <finalName>jsp-servlet-product-discount</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.13.0</version>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.4.0</version>
            </plugin>
        </plugins>
    </build>
</project>
```

### 6.8. Giao diện CSS và bài test

- CSS: [`assets/styles.css`](jsp-servlet-product-discount/src/main/webapp/assets/styles.css)
- Unit self-test: [`DiscountCalculatorSelfTest.java`](jsp-servlet-product-discount/src/test/java/com/codegym/service/DiscountCalculatorSelfTest.java)
- Script chạy test Windows: [`test-windows.bat`](jsp-servlet-product-discount/scripts/test-windows.bat)

## 7. Kết quả kiểm tra trong môi trường soạn bài

- **22/22 trường hợp test logic Java thuần đạt** (`DiscountCalculatorSelfTest`).
- **61/61 kiểm tra xử lý Servlet mô phỏng đạt** (gồm URL GET, POST thành công, phản hồi lỗi, mã HTTP, chuyển hướng, giữ dữ liệu).
- Java 17 biên dịch được khi sử dụng bộ mô phỏng tối thiểu cho API Servlet.
- XML của `pom.xml` và `web.xml` hợp lệ, có Java Servlet 6 / JSTL 3.
- Giao diện được chụp bằng Chromium từ mã HTML/CSS mô phỏng, không phải ảnh JSP đang chạy trên Tomcat.

**Giới hạn xác minh:** Máy soạn bài không có Maven/Tomcat để thực hiện `mvn clean package` hay deploy thật. Hãy chạy thử trên Tomcat 10.1+ trước khi nộp.

## 8. Gợi ý nộp bài CodeGym

Nộp link thư mục GitHub của dự án. Nếu repository `Shion-NewbieCoder/JSP-homework`, nhánh `main`, và thư mục được giải nén đúng vị trí, đường dẫn dự kiến là:

`https://github.com/Shion-NewbieCoder/JSP-homework/tree/main/Product_Discount_Calculator`
