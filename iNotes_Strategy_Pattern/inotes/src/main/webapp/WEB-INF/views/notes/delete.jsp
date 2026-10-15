<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../partials/header.jspf" %>
<div class="page-intro"><a class="back" href="${pageContext.request.contextPath}/notes">← Về danh sách</a><p class="eyebrow">CONFIRM DELETE</p><h1>Xóa ghi chú?</h1></div>
<section class="panel delete-panel"><div class="warning-icon">!</div>
 <h2>Bạn chắc chắn muốn xóa ghi chú này?</h2>
 <p><strong><c:out value="${note.title}"/></strong> sẽ bị xóa vĩnh viễn khỏi kho lưu trữ hiện tại (<strong>${storage == 'mysql' ? 'MySQL' : 'File TXT'}</strong>).</p>
 <form action="${pageContext.request.contextPath}/notes" method="post" class="form-buttons">
  <input type="hidden" name="action" value="delete"/><input type="hidden" name="id" value="${note.id}"/>
  <button type="submit" class="btn btn-danger">Xóa ghi chú</button><a class="btn btn-outline" href="${pageContext.request.contextPath}/notes">Hủy bỏ</a>
 </form>
</section>
<%@ include file="../partials/footer.jspf" %>
