<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Result | Simple Calculator</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="container">
    <p class="eyebrow">JAVA WEB / PRACTICE</p>
    <h1>Result</h1>
    <% if (request.getAttribute("error") != null) { %>
    <section class="result-card error" role="alert">
        <span class="result-label">Calculation error</span>
        <p class="error-message">${error}</p>
    </section>
    <% } else { %>
    <section class="result-card" aria-label="Calculation result">
        <span class="result-label">YOUR CALCULATION</span>
        <p class="calculation">${firstOperand} ${operator} ${secondOperand} =</p>
        <p class="answer">${result}</p>
    </section>
    <% } %>
    <a class="back-link" href="${pageContext.request.contextPath}/">← Back to calculator</a>
    <footer>CodeGym • JSP / Servlet / Maven demo</footer>
</main>
</body>
</html>
