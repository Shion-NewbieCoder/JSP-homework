<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.codegym.model.CustomerData" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Buoc 5: lay danh sach khach hang mau, dua vao request scope cho JSTL.
    request.setAttribute("customers", CustomerData.getCustomers());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Bài thực hành JSP và JSTL: hiển thị danh sách khách hàng.">
    <title>Danh sách khách hàng | JSP &amp; JSTL</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<main class="page-shell">
    <header class="page-header">
        <span class="eyebrow">BÀI THỰC HÀNH JAVA WEB • JSTL CORE</span>
        <h1>Danh sách khách hàng</h1>
        <p>Hiển thị dữ liệu mẫu bằng JSP và vòng lặp JSTL <code>c:forEach</code>.</p>
    </header>

    <section class="table-card" aria-labelledby="list-title">
        <div class="card-heading">
            <h2 id="list-title">Thông tin khách hàng</h2>
            <span class="total-count">5 khách hàng</span>
        </div>
        <div class="table-scroll">
            <table class="customer-table">
                <thead>
                <tr>
                    <th scope="col">Tên</th>
                    <th scope="col">Ngày sinh</th>
                    <th scope="col">Địa chỉ</th>
                    <th scope="col">Ảnh</th>
                </tr>
                </thead>
                <tbody>
                <%-- Buoc 6: JSTL lap qua List<Customer>, EL doc cac getter cua JavaBean. --%>
                <c:forEach var="customer" items="${customers}">
                    <c:url value="/images/${customer.photo}" var="photoUrl" />
                    <tr>
                        <td data-label="Tên" class="customer-name"><c:out value="${customer.name}" /></td>
                        <td data-label="Ngày sinh"><c:out value="${customer.birthday}" /></td>
                        <td data-label="Địa chỉ"><c:out value="${customer.address}" /></td>
                        <td data-label="Ảnh" class="photo-cell">
                            <img class="customer-avatar" src="${photoUrl}" alt="Ảnh minh họa khách hàng" width="54" height="54" />
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty customers}">
                    <tr><td colspan="4" class="empty-state">Chưa có khách hàng nào.</td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
        <div class="card-footer">Dữ liệu minh họa · Không kết nối cơ sở dữ liệu</div>
    </section>
</main>
</body>
</html>
