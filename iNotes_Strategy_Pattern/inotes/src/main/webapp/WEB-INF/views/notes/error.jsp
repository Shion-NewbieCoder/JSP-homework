<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../partials/header.jspf" %>
<section class="panel error-panel"><div class="warning-icon">!</div><h1>Không thể mở kho ghi chú</h1>
<p><c:out value="${message}"/></p><p class="mini">Kho hiện tại: ${storage == 'mysql' ? 'MySQL' : 'File TXT'}.</p>
<div class="form-buttons"><a class="btn btn-outline" href="${pageContext.request.contextPath}/notes">Thử lại</a>
<form action="${pageContext.request.contextPath}/notes" method="post"><input type="hidden" name="action" value="switch"/><input type="hidden" name="storage" value="file"/><button type="submit" class="btn btn-primary">Dùng File TXT</button></form></div>
</section>
<%@ include file="../partials/footer.jspf" %>
