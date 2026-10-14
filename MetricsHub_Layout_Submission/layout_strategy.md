# MetricsHub — Chiến lược layout

**Audit:** Navbar Grid có cột cố định gây tràn chữ. Dashboard dùng Flexbox lồng nhau (“div soup”), khó cho widget chiếm hai chiều. Pricing dùng `float` và media query thủ công, gây khó bảo trì.

**Giải pháp:** Flexbox xử lý bố cục một chiều của Navbar: `justify-content`, `align-items`, `flex-wrap` và `gap` giúp menu tự co giãn. CSS Grid xử lý Bento hai chiều: các widget là con trực tiếp, ô lớn dùng `grid-column: span 2` và `grid-row: span 2`. Bootstrap sử dụng lưới 12 cột với `row` và `col-12 col-md-4`, cho ba gói giá nằm ngang trên desktop và xếp dọc trên mobile.

**Đánh đổi:** Grid hợp bố cục phức tạp; Flexbox hợp căn chỉnh thành phần. Bootstrap triển khai nhanh nhưng thêm phụ thuộc thư viện. Kiểm thử 375px, 768px và desktop.
