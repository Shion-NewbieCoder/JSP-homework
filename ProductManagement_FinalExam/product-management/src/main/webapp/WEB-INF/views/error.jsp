<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="header.jspf" %>
<section class="confirm-card error-card"><div class="warning-symbol">!</div><h1><c:out value="${errorTitle}"/></h1><p class="muted"><c:out value="${errorMessage}"/></p><a class="button button-primary" href="${pageContext.request.contextPath}/products">Về danh sách sản phẩm</a></section>
<%@ include file="footer.jspf" %>
