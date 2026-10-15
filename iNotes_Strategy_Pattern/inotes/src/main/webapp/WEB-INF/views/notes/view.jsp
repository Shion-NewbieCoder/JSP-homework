<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../partials/header.jspf" %>
<div class="page-intro"><a class="back" href="${pageContext.request.contextPath}/notes">← Về danh sách</a><p class="eyebrow">NOTE DETAILS</p><h1>Chi tiết ghi chú</h1></div>
<article class="panel detail-panel">
 <div class="detail-head"><span class="muted">Ghi chú #${note.id}</span><div class="detail-actions"><a class="btn btn-outline" href="${pageContext.request.contextPath}/notes?action=edit&amp;id=${note.id}">Sửa</a><a class="btn btn-danger-outline" href="${pageContext.request.contextPath}/notes?action=delete&amp;id=${note.id}">Xóa</a></div></div>
 <h2><c:out value="${note.title}"/></h2>
 <c:forEach var="type" items="${types}"><c:if test="${type.id == note.typeId}"><span class="tag tag-${type.id}"><c:out value="${type.name}"/></span></c:if></c:forEach>
 <hr/>
 <div class="note-body"><c:out value="${note.content}"/></div>
</article>
<%@ include file="../partials/footer.jspf" %>
