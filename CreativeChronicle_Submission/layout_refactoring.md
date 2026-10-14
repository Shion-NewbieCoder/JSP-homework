# CreativeChronicle — Báo cáo Refactoring Layout

Kỹ thuật cũ đặt ảnh đại diện và nút chia sẻ bằng `float`, khiến việc căn giữa theo chiều dọc khó kiểm soát. Phần tử `float` tách khỏi luồng thông thường nên đôi khi phần tử cha không tự ôm đủ chiều cao, buộc dùng `clearfix`. Tôi chuyển thanh tác giả sang **Flexbox** với `align-items: center`, `justify-content: space-between` và `flex-wrap: wrap` để tên dài hoặc màn hình hẹp không đè lên nút.

Thư viện cũ dùng `position: absolute` và chiều cao 400px, làm ảnh thoát khỏi luồng bố cục, vùng cha có thể không phản ánh nội dung, gây chồng lấn khi thu nhỏ màn hình. Tôi thay bằng **CSS Grid** hai cột tỷ lệ `2fr 1fr`, ảnh chính `grid-row: span 2`, và một cột trên mobile; ảnh dùng `object-fit: cover` để không méo.

Bài đề xuất dùng **Bootstrap `row`, `col-12 col-md-6 col-lg-3`** nên tự đổi 1–2–4 cột theo thiết bị.
