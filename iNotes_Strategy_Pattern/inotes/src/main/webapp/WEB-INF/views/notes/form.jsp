<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../partials/header.jspf" %>
<div class="page-intro"><a class="back" href="${pageContext.request.contextPath}/notes">← Về danh sách</a>
 <p class="eyebrow">NOTE EDITOR</p>
 <h1>${editing ? 'Chỉnh sửa ghi chú' : 'Tạo ghi chú mới'}</h1>
 <p class="subtitle">Những điều quan trọng xứng đáng có một chỗ để lưu lại.</p>
</div>
<section class="panel editor-panel">
<c:if test="${not empty formError}"><div class="alert alert-error" role="alert"><c:out value="${formError}"/></div></c:if>
<form action="${pageContext.request.contextPath}/notes" method="post">
 <input type="hidden" name="action" value="save"/>
 <c:if test="${editing}"><input type="hidden" name="id" value="${note.id}"/></c:if>
 <div class="form-field"><label for="title">Tiêu đề <span class="required">*</span></label>
  <input id="title" name="title" type="text" maxlength="255" required placeholder="Ví dụ: Ôn tập Strategy Pattern" value="<c:out value='${note.title}'/>"/></div>
 <div class="form-field"><label for="typeId">Phân loại <span class="required">*</span></label>
  <select id="typeId" name="typeId" required>
   <option value="">Chọn loại ghi chú</option>
   <c:forEach var="type" items="${types}"><option value="${type.id}" ${note.typeId == type.id ? 'selected="selected"' : ''}><c:out value="${type.name}"/></option></c:forEach>
  </select></div>
 <div class="form-field"><label for="content">Nội dung</label>
  <textarea id="content" name="content" maxlength="12000" rows="10" placeholder="Viết ý tưởng của bạn ở đây..."><c:out value="${note.content}"/></textarea>
  <p class="hint">Hỗ trợ xuống dòng và ký tự đặc biệt, kể cả dấu | khi lưu file TXT.</p></div>
 <div class="form-buttons"><button class="btn btn-primary" type="submit">${editing ? 'Lưu thay đổi' : 'Lưu ghi chú'}</button><a class="btn btn-outline" href="${pageContext.request.contextPath}/notes">Hủy bỏ</a></div>
</form>
</section>
<%@ include file="../partials/footer.jspf" %>
