# CreativeChronicle — AI Prompt Log

**Phạm vi:** Các câu hỏi về kỹ thuật dùng trong bài tập. Câu trả lời là giải thích thiết kế; kiểm tra hiển thị được ghi riêng trong README. Không xem đây là benchmark hiệu năng.

### 1. Vì sao `float` khó dùng để căn giữa thanh tác giả?

**Prompt:** “`float: left/right` hoạt động thế nào với chiều cao phần tử cha và căn giữa avatar, tên tác giả, ngày đăng?”

**AI giải thích:** `float` chủ yếu dành cho nội dung chạy vòng quanh hình; phần tử float không còn tham gia chiều cao của container như phần tử trong luồng thông thường. Vì thế thường cần clearfix. Nó không có cơ chế `align-items: center` như Flexbox.

### 2. Tại sao `position: absolute` dễ gây chồng lấn ảnh và đoạn văn?

**Prompt:** “Khi ảnh được đặt bằng `position: absolute` trong container cao 400px, điều gì xảy ra khi giảm viewport?”

**AI giải thích:** Phần tử absolute bị tách khỏi luồng tài liệu, không đẩy chiều cao của container; nếu ảnh và nội dung co giãn, container có chiều cao cứng không đủ và ảnh có thể đè vào đoạn văn kế tiếp. Grid giải quyết quan hệ 2D trong luồng bố cục.

### 3. Grid với một ảnh lớn và hai ảnh nhỏ nên viết thế nào?

**Prompt:** “Cú pháp CSS Grid dùng `grid-template-columns: 2fr 1fr`, `grid-row: span 2` cho mosaic ba ảnh là gì?”

**AI giải thích:** Dùng `.mosaic-gallery { display:grid; grid-template-columns: 2fr 1fr; grid-template-rows: repeat(2,minmax(0,1fr)); }`. Cho ảnh đầu `.photo-main { grid-row:span 2; }`. Grid tự căn hàng/cột và giữ nội dung trong luồng.

### 4. Thêm ảnh thứ tư, thứ năm vào Mosaic thì sao?

**Prompt:** “CSS Grid có tự tạo thêm hàng mới nếu thêm nhiều phần tử con không?”

**AI giải thích:** Có. Grid tạo **implicit rows** tùy `grid-auto-flow` và `grid-auto-rows`. Tuy nhiên, cần kiểm tra lại tỷ lệ, thứ tự và responsive để bố cục đẹp với ảnh bổ sung.

### 5. Bootstrap 5 đổi 4–2–1 card tại breakpoint nào?

**Prompt:** “`col-12 col-md-6 col-lg-3` nghĩa là gì ở 375px, 768px, 1200px? Khác `col-sm-6` thế nào?”

**AI giải thích:** Dưới 768px: mỗi card chiếm 12/12, một cột. Từ 768px đến dưới 992px: 6/12, hai cột. Từ 992px: 3/12, bốn cột. `col-sm-6` chuyển sang hai cột sớm hơn, từ 576px.

### 6. Bootstrap utilities nào giúp giảm CSS thủ công?

**Prompt:** “Có thể dùng `d-flex`, `align-items-center`, `justify-content-between`, `g-4`, `mt-3`, `pb-2` thế nào?”

**AI giải thích:** Đây là các class tiện ích cho display, căn chỉnh, khoảng cách hàng/cột và margin/padding. Trong khu Recommended dùng `row g-4`, `h-100`, `card`, `card-body`; Flexbox riêng hợp lý cho thanh tác giả khi cần điều chỉnh `flex-wrap` và `min-width`.

### 7. Khi nào dùng Flexbox trong widget nằm trong Grid?

**Prompt:** “Flexbox và CSS Grid có thể kết hợp với nhau trong một thiết kế không?”

**AI giải thích:** Có. Grid quy hoạch vị trí các khối hai chiều; bên trong từng widget, Flexbox căn biểu tượng và dòng chữ theo một chiều. Việc kết hợp hai công cụ thường đơn giản hơn lồng nhiều lớp layout giả lập.
