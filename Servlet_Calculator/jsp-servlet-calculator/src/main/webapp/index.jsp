<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Simple Calculator using Java JSP and Servlet.">
    <title>Simple Calculator | JSP &amp; Servlet</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="container">
    <p class="eyebrow">JAVA WEB / PRACTICE</p>
    <h1>Simple Calculator</h1>
    <p class="lead">Perform the four basic arithmetic operations with a Java Servlet.</p>

    <form class="calculator-card" action="${pageContext.request.contextPath}/calculate" method="post">
        <fieldset>
            <legend>Calculator</legend>
            <label for="first-operand">First operand</label>
            <input id="first-operand" name="first-operand" type="number" step="any"
                   placeholder="e.g. 231" required autofocus>

            <label for="operator">Operator</label>
            <select id="operator" name="operator" required>
                <option value="+">Addition (+)</option>
                <option value="-">Subtraction (-)</option>
                <option value="*">Multiplication (×)</option>
                <option value="/">Division (÷)</option>
            </select>

            <label for="second-operand">Second operand</label>
            <input id="second-operand" name="second-operand" type="number" step="any"
                   placeholder="e.g. 234" required>

            <button type="submit">Calculate <span aria-hidden="true">→</span></button>
        </fieldset>
    </form>

    <p class="note">Tip: Try <strong>231 + 234</strong> or <strong>10 ÷ 0</strong> to see error handling.</p>
    <footer>CodeGym • JSP / Servlet / Maven demo</footer>
</main>
</body>
</html>
