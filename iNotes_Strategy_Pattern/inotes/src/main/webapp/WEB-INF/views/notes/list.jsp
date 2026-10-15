<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../partials/header.jspf" %>
<section class="hero">
 <div>
  <p class="eyebrow">YOUR NOTES, YOUR WAY</p>
  <h1>Ý tưởng của bạn, <span>được lưu giữ.</span></h1>
  <p class="subtitle">Sắp xếp ghi chú gọn gàng, tìm lại điều quan trọng trong vài giây.</p>
 </div>
 <a class="btn btn-primary hero-create" href="${pageContext.request.contextPath}/notes?action=create">+ Thêm ghi chú</a>
</section>
<c:if test="${not empty flash}"><div class="alert alert-success" role="status"><c:out value="${flash}"/></div></c:if>
<section class="panel tools-panel">
 <div class="storage-row">
  <div><div class="section-label">NƠI LƯU TRỮ</div><strong>${storage == 'mysql' ? 'MySQL Database' : 'File TXT'}</strong><p class="mini">Chuyển Strategy mà không đổi giao diện. Hai kho lưu dữ liệu riêng biệt.</p></div>
  <form action="${pageContext.request.contextPath}/notes" method="post" class="storage-form">
   <input type="hidden" name="action" value="switch"/>
   <label class="sr-only" for="storage">Chọn nơi lưu trữ</label>
   <select id="storage" name="storage">
    <option value="file" ${storage == 'file' ? 'selected="selected"' : ''}>File (.txt)</option>
    <option value="mysql" ${storage == 'mysql' ? 'selected="selected"' : ''}>MySQL</option>
   </select>
   <button type="submit" class="btn btn-outline">Chuyển đổi</button>
  </form>
 </div>
 <form class="search-row" method="get" action="${pageContext.request.contextPath}/notes">
  <label class="sr-only" for="q">Từ khóa</label>
  <input id="q" class="search-input" type="search" name="q" maxlength="100" placeholder="⌕  Tìm theo tiêu đề hoặc nội dung..." value="<c:out value='${q}'/>"/>
  <label class="sr-only" for="type">Danh mục</label>
  <select id="type" name="type">
   <option value="0">Tất cả phân loại</option>
   <c:forEach var="type" items="${types}"><option value="${type.id}" ${type.id == selectedType ? 'selected="selected"' : ''}><c:out value="${type.name}"/></option></c:forEach>
  </select>
  <button class="btn btn-dark" type="submit">Tìm kiếm</button>
  <a class="reset-link" href="${pageContext.request.contextPath}/notes">Xóa lọc</a>
 </form>
</section>
<div class="section-heading"><h2>Danh sách ghi chú</h2><span class="count-pill">${fn:length(notes)} ghi chú</span></div>
<section class="panel table-panel">
 <c:choose>
  <c:when test="${empty notes}">
   <div class="empty-state"><div class="empty-emoji">✎</div><h3>Chưa tìm thấy ghi chú</h3><p>Hãy thử từ khóa khác hoặc tạo ghi chú đầu tiên.</p><a class="btn btn-primary" href="${pageContext.request.contextPath}/notes?action=create">Tạo ghi chú mới</a></div>
  </c:when>
  <c:otherwise>
   <div class="table-scroll"><table>
    <thead><tr><th>#</th><th>TIÊU ĐỀ VÀ NỘI DUNG</th><th>PHÂN LOẠI</th><th>THAO TÁC</th></tr></thead>
    <tbody>
    <c:forEach items="${notes}" var="note" varStatus="loop">
     <tr>
      <td class="muted">${loop.count}</td>
      <td class="note-cell"><a class="note-title" href="${pageContext.request.contextPath}/notes?action=view&amp;id=${note.id}"><c:out value="${note.title}"/></a><div class="excerpt"><c:out value="${note.excerpt}"/></div></td>
      <td><c:forEach items="${types}" var="type"><c:if test="${note.typeId == type.id}"><span class="tag tag-${type.id}"><c:out value="${type.name}"/></span></c:if></c:forEach></td>
      <td class="actions"><a href="${pageContext.request.contextPath}/notes?action=view&amp;id=${note.id}">Xem</a><a href="${pageContext.request.contextPath}/notes?action=edit&amp;id=${note.id}">Sửa</a><a class="danger-link" href="${pageContext.request.contextPath}/notes?action=delete&amp;id=${note.id}">Xóa</a></td>
     </tr>
    </c:forEach>
    </tbody>
   </table></div>
  </c:otherwise>
 </c:choose>
</section>
<%@ include file="../partials/footer.jspf" %>
