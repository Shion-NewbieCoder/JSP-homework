# Currency Converter — JSP + Servlet (CodeGym)

Bài thực hành tạo ứng dụng Java Web **chuyển đổi từ USD sang VNĐ với tỉ giá người dùng tự nhập**, theo mô hình **Form JSP → Servlet → HTML response**. Dự án viết độc lập, sử dụng Java 17, Maven và **Jakarta Servlet API 6.0 / Tomcat 10.1+**.

## Yêu cầu và trạng thái

| Mục của đề | Cách thực hiện |
|---|---|
| `index.jsp` có ô `rate`, `usd` | `src/main/webapp/index.jsp` |
| Gửi form `POST /convert` | `action="${pageContext.request.contextPath}/convert"` |
| Servlet nhận dữ liệu và tính `VND = USD × Rate` | `ConverterServlet.java` kết hợp `CurrencyCalculator.java` |
| Hiển thị kết quả VNĐ trên trang trình duyệt | Servlet viết HTML UTF-8 qua `PrintWriter` |
| Tomcat 10.1+ dùng Jakarta Servlet | `jakarta.servlet.*`, `pom.xml`, `web.xml` |
| Bắt lỗi nếu nhập không phải số | HTTP 400 + trang thông báo tiếng Việt |

**Cải tiến có chủ đích so với mã mẫu:** dùng `BigDecimal` thay cho `float` để giảm sai số tính tiền. Tỉ giá phải lớn hơn 0, USD không được âm. Kết quả hiển thị làm tròn đến tối đa 2 chữ số thập phân, còn phép nhân trong Java giữ kết quả `BigDecimal` chính xác.

## Cấu trúc dự án

```text
jsp-servlet-currency-converter/
├── pom.xml
├── README.md
├── run-tests-windows.bat
├── run-tests-unix.sh
└── src/
    ├── main/
    │   ├── java/com/codegym/
    │   │   ├── ConverterServlet.java
    │   │   └── CurrencyCalculator.java
    │   └── webapp/
    │       ├── index.jsp
    │       ├── css/style.css
    │       └── WEB-INF/web.xml
    └── test/java/com/codegym/CurrencyCalculatorTest.java
```

## Hướng dẫn chạy (Windows / VS Code / IntelliJ)

**Yêu cầu:** JDK 17+, Apache Maven 3.8+, Apache Tomcat **10.1+** (không dùng Tomcat 9 vì `javax.servlet` khác `jakarta.servlet`).

1. Giải nén ZIP và mở thư mục `jsp-servlet-currency-converter`, nơi chứa `pom.xml`.
2. Trong Terminal, chạy:
   ```powershell
   mvn clean package
   ```
3. Sau khi xuất hiện `BUILD SUCCESS`, copy `target/jsp-servlet-currency-converter.war` vào thư mục `webapps` của Tomcat 10.1 hoặc deploy qua plugin Server trong IDE.
4. Chạy Tomcat và mở trang: <http://localhost:8080/jsp-servlet-currency-converter/>
5. Nhập tỉ giá `25000`, USD `100` → kết quả dự kiến **2.500.000 VNĐ**.

**Chú ý URL:** `/convert` là endpoint bên trong *context path* của ứng dụng. Khi deploy WAR, URL hoàn chỉnh là `/jsp-servlet-currency-converter/convert`.

## Kiểm thử

**Test logic không cần Maven:**

- Windows: `run-tests-windows.bat`
- macOS/Linux: `sh run-tests-unix.sh`
- Kiểm tra 11 tình huống (số nguyên, số thập phân, USD = 0, giá trị lớn, input null, rate <= 0, USD âm). Kết quả mong đợi `PASS 11/11 conversion cases`.

Kiểm thử mã của bản nộp trong môi trường soạn bài: **11/11 test logic đạt**, đồng thời **58 lượt kiểm tra Servlet giả lập trên 11 kịch bản đạt**, có biên dịch Java 17 và xác minh cú pháp XML. Những phép thử Servlet chỉ dùng API mô phỏng, **chưa thay thế cho `mvn clean package` và deploy Tomcat thực tế**.

## Luồng dữ liệu

1. `index.jsp` tạo HTML form `method="post"` với hai input `name="rate"` và `name="usd"`.
2. `@WebServlet(urlPatterns = "/convert")` gắn `ConverterServlet` với URL `/convert`; `web.xml` khai báo `index.jsp` là welcome file, không trùng định tuyến.
3. `ConverterServlet#doPost` đọc tham số, chuyển thành `BigDecimal`, gọi `CurrencyCalculator.convert()`.
4. Servlet xuất HTML kết quả qua `response.getWriter()` hoặc thông báo lỗi và mã HTTP 400.

> Đây là bài tập nhập tỉ giá thủ công. Không có API tỉ giá trực tuyến; các giá trị trong ảnh/README chỉ là ví dụ để kiểm tra phép tính.

## Mã nguồn đầy đủ (tiện kiểm tra trực tiếp trên GitHub)

Các file dưới đây cũng có trong cây mã nguồn, trình bày thêm tại README để người chấm có thể đọc liền mạch.

### `pom.xml`

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.codegym</groupId>
    <artifactId>jsp-servlet-currency-converter</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <name>JSP Servlet Currency Converter</name>

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
    </dependencies>

    <build>
        <finalName>jsp-servlet-currency-converter</finalName>
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

### `src/main/webapp/WEB-INF/web.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">
    <display-name>JSP Servlet Currency Converter</display-name>
    <!-- The /convert mapping is declared with @WebServlet on ConverterServlet. -->
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
</web-app>
```

### `src/main/java/com/codegym/CurrencyCalculator.java`

```java
package com.codegym;

import java.math.BigDecimal;

/**
 * Business logic: convert USD to VND using a user-supplied exchange rate.
 * BigDecimal avoids binary floating-point inaccuracies with money.
 */
public final class CurrencyCalculator {
    private CurrencyCalculator() {
    }

    /**
     * @param rate positive VND value per one USD
     * @param usd non-negative amount of USD
     * @return the converted VND amount (exact BigDecimal multiplication)
     * @throws IllegalArgumentException when input is null or outside the allowed range
     */
    public static BigDecimal convert(BigDecimal rate, BigDecimal usd) {
        if (rate == null || usd == null) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ tỉ giá và lượng USD.");
        }
        if (rate.signum() <= 0) {
            throw new IllegalArgumentException("Tỉ giá phải lớn hơn 0.");
        }
        if (usd.signum() < 0) {
            throw new IllegalArgumentException("Lượng USD không được âm.");
        }
        return rate.multiply(usd);
    }
}
```

### `src/main/java/com/codegym/ConverterServlet.java`

```java
package com.codegym;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.NumberFormat;
import java.util.Locale;

/** Receives POST /convert from index.jsp and renders the conversion result. */
@WebServlet(name = "ConverterServlet", urlPatterns = "/convert")
public class ConverterServlet extends HttpServlet {
    private static final Locale VIETNAM = Locale.forLanguageTag("vi-VN");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try {
            BigDecimal rate = parseDecimal(request.getParameter("rate"), "tỉ giá");
            BigDecimal usd = parseDecimal(request.getParameter("usd"), "lượng USD");
            BigDecimal vnd = CurrencyCalculator.convert(rate, usd);
            showResult(response, request.getContextPath(), rate, usd, vnd);
        } catch (IllegalArgumentException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            showError(response, request.getContextPath(), ex.getMessage());
        }
    }

    private static BigDecimal parseDecimal(String raw, String field) {
        if (raw == null || raw.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập " + field + ".");
        }
        String normalized = raw.trim();
        if (normalized.length() > 30) {
            throw new IllegalArgumentException("Giá trị " + field + " quá dài.");
        }
        try {
            BigDecimal value = new BigDecimal(normalized);
            if (value.precision() > 18 || value.scale() > 6 || value.scale() < -12) {
                throw new IllegalArgumentException("Giá trị " + field + " vượt quá giới hạn hỗ trợ.");
            }
            return value;
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Giá trị " + field + " phải là số hợp lệ.");
        }
    }

    private static String formatNumber(BigDecimal number) {
        NumberFormat nf = NumberFormat.getNumberInstance(VIETNAM);
        nf.setGroupingUsed(true);
        nf.setMaximumFractionDigits(2);
        nf.setRoundingMode(RoundingMode.HALF_UP);
        return nf.format(number);
    }

    private static void pageStart(PrintWriter out, String contextPath, String title) {
        out.println("<!DOCTYPE html>");
        out.println("<html lang=\"vi\"><head><meta charset=\"UTF-8\">");
        out.println("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
        out.println("<title>" + title + "</title>");
        out.println("<link rel=\"stylesheet\" href=\"" + contextPath + "/css/style.css\">");
        out.println("</head><body><main class=\"container\">");
    }

    private static void pageEnd(PrintWriter out) {
        out.println("</main></body></html>");
    }

    private static void showResult(HttpServletResponse response, String contextPath,
                                   BigDecimal rate, BigDecimal usd, BigDecimal vnd)
            throws IOException {
        try (PrintWriter out = response.getWriter()) {
            pageStart(out, contextPath, "Kết quả chuyển đổi");
            out.println("<article class=\"card result-card\">");
            out.println("<div class=\"eyebrow\">USD → VND · KẾT QUẢ</div>");
            out.println("<h1>Chuyển đổi thành công</h1>");
            out.println("<p class=\"helper\">Giá trị được tính từ tỉ giá do bạn nhập.</p>");
            out.println("<div class=\"result-amount\">" + formatNumber(vnd) + " <span>VNĐ</span></div>");
            out.println("<div class=\"breakdown\"><div><span>Tỉ giá</span><strong>"
                    + formatNumber(rate) + " VNĐ / USD</strong></div>");
            out.println("<div><span>Số tiền USD</span><strong>" + formatNumber(usd) + " USD</strong></div></div>");
            out.println("<a class=\"button\" href=\"" + contextPath + "/\">Chuyển đổi tiếp</a>");
            out.println("</article>");
            pageEnd(out);
        }
    }

    private static void showError(HttpServletResponse response, String contextPath,
                                  String message) throws IOException {
        // message only comes from fixed server-side validation strings (never raw input).
        try (PrintWriter out = response.getWriter()) {
            pageStart(out, contextPath, "Lỗi chuyển đổi");
            out.println("<article class=\"card result-card\">");
            out.println("<div class=\"eyebrow error-text\">DỮ LIỆU KHÔNG HỢP LỆ</div>");
            out.println("<h1>Không thể chuyển đổi</h1>");
            out.println("<p class=\"error-message\">" + message + "</p>");
            out.println("<a class=\"button\" href=\"" + contextPath + "/\">Quay lại biểu mẫu</a>");
            out.println("</article>");
            pageEnd(out);
        }
    }
}
```

### `src/main/webapp/index.jsp`

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chuyển đổi tiền tệ USD sang VNĐ</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<main class="container">
    <article class="card">
        <div class="eyebrow">CURRENCY CONVERTER · JSP / SERVLET</div>
        <h1>Chuyển đổi USD sang VNĐ</h1>
        <p class="helper">Nhập tỉ giá và số USD cần đổi để tính số tiền VNĐ tương ứng.</p>

        <form action="${pageContext.request.contextPath}/convert" method="post">
            <div class="form-group">
                <label for="rate">Tỉ giá (VNĐ / USD)</label>
                <input id="rate" name="rate" type="number" inputmode="decimal" min="0.000001"
                       step="any" value="25000" placeholder="Ví dụ: 25000" required>
            </div>
            <div class="form-group">
                <label for="usd">Lượng USD cần đổi</label>
                <input id="usd" name="usd" type="number" inputmode="decimal" min="0"
                       step="any" placeholder="Ví dụ: 100" required>
            </div>
            <button class="button" type="submit">Chuyển đổi sang VNĐ <span aria-hidden="true">→</span></button>
        </form>
        <p class="note">Tỉ giá do người dùng tự nhập; ứng dụng không lấy tỉ giá thời gian thực.</p>
    </article>
</main>
</body>
</html>
```

### `src/main/webapp/css/style.css`

```css
:root {
    color-scheme: light;
    --ink: #192a43;
    --muted: #65768c;
    --border: #dbe5f0;
    --accent: #2454ce;
    --accent-hover: #1b42a7;
}
* { box-sizing: border-box; }
body { margin: 0; min-height: 100vh; background: linear-gradient(135deg,#f1f6ff 0%,#f9fbfd 100%);
       font: 16px/1.55 system-ui,-apple-system,"Segoe UI",Roboto,Arial,sans-serif; color: var(--ink); }
.container { max-width: 620px; margin: 0 auto; padding: clamp(24px,7vh,84px) 20px; }
.card { background: #fff; border: 1px solid var(--border); border-radius: 20px;
        padding: clamp(24px,5vw,42px); box-shadow: 0 18px 55px rgba(34,63,104,.08); }
.eyebrow { font-size: 12px; letter-spacing: .13em; font-weight: 800; color: var(--accent); }
h1 { font-size: clamp(25px,4.5vw,35px); line-height: 1.18; letter-spacing: -.035em; margin: 14px 0; }
.helper { color: var(--muted); margin: 0 0 28px; }
.form-group { margin-bottom: 20px; }
label { display: block; font-weight: 700; font-size: 14px; margin-bottom: 8px; }
input { display: block; font: inherit; color: var(--ink); width: 100%; background: #fff;
        border: 1px solid #cbd6e5; border-radius: 11px; padding: 13px 14px; }
input:focus { outline: 3px solid #c7d8ff; border-color: var(--accent); }
.button { display: flex; align-items: center; justify-content: center; gap: 12px;
          width: 100%; min-height: 48px; padding: 11px 18px; background: var(--accent);
          border: 0; border-radius: 11px; font: inherit; font-weight: 700; color: #fff;
          text-align: center; text-decoration: none; cursor: pointer; }
.button:hover { background: var(--accent-hover); }
.note { font-size: 12px; color: var(--muted); margin: 22px 0 0; text-align: center; }
.result-card { text-align: center; }
.result-card .helper { margin-bottom: 22px; }
.result-amount { overflow-wrap: anywhere; color: #177650; font-size: clamp(26px,5vw,41px); font-weight: 800;
                line-height: 1.25; margin: 24px 0; }
.result-amount span { font-size: 17px; color: var(--ink); }
.breakdown { border: 1px solid var(--border); border-radius: 12px; margin-bottom: 25px; padding: 2px 16px; text-align: left; }
.breakdown > div { display: flex; flex-wrap: wrap; justify-content: space-between; gap: 8px; padding: 13px 0; }
.breakdown > div + div { border-top: 1px solid var(--border); }
.breakdown span { color: var(--muted); }
.error-text { color: #ae354b; }
.error-message { padding: 14px; border-radius: 10px; background: #fff0f2; color: #8d2338; }
@media (max-width: 420px) {
    .container { padding: 24px 12px; }
    .card { padding: 22px 18px; }
    .breakdown > div { display: block; }
    .breakdown strong { display: block; }
}
```

## Nộp bài lên GitHub

Giải nén toàn bộ thư mục `JSP_Servlet_Currency_Converter` vào repository `JSP-homework`, sau đó chạy ở root repository:

```powershell
git add JSP_Servlet_Currency_Converter/
git commit -m "feat: implement JSP Servlet USD to VND converter"
git push origin main
```

Link dự kiến sau khi push:

<https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/JSP_Servlet_Currency_Converter/README.md>

**Lưu ý:** Đường dẫn trên chỉ tồn tại sau khi bạn tự push folder lên GitHub. Bản ZIP được cung cấp để bạn giải nén và đẩy lên, không thể mặc định khẳng định đã có trên repo.
