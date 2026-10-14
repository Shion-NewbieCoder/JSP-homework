# MetricsHub — Nhật ký trao đổi kỹ thuật với AI

Các prompt dưới đây ghi lại những câu hỏi thiết kế và phần giải thích kỹ thuật dùng trong quá trình hoàn thiện bài thực hành. **Đây là log học tập/trao đổi kiến thức, không phải kết quả đo hiệu năng trình duyệt do AI tự bịa.**

## Prompt 1 — Flexbox so với CSS Grid

**Câu hỏi:** “Một widget cần chiếm chính xác hai hàng và hai cột, đan xen với các widget nhỏ khác. Nên dùng Grid hay Flexbox, và vì sao?”

**AI trả lời:** Grid giải quyết trục hàng và cột cùng lúc; `grid-column: span 2` và `grid-row: span 2` tạo hình Bento trực tiếp. Flexbox tối ưu một trục trong mỗi flex container, muốn tái hiện bố cục phức tạp dễ phải lồng nhiều wrapper khó bảo trì.

**Ứng dụng:** Sáu `.widget` là các phần tử anh em nằm trực tiếp dưới `.grid-dashboard`. Không tạo các `.column` lồng nhau như Legacy.

## Prompt 2 — Flexbox Navbar và tên dài

**Câu hỏi:** “Dùng `flex-wrap` và `gap` thế nào để thanh điều hướng có nhãn dài tiếng Đức không đè lên logo?”

**AI trả lời:** `display: flex; align-items: center; justify-content: space-between` cho navbar; `flex-wrap: wrap` cho cả container và vùng liên kết; dùng `min-width: 0`, `overflow-wrap: anywhere` cho nhãn dài; không dùng các cột pixel cố định.

**Ứng dụng:** Navbar có mục `Datenanalyse-Dashboard` để kiểm thử nhãn dài. Ở màn hình hẹp, khu liên kết tự xuống hàng và không ép logo biến dạng.

## Prompt 3 — Bootstrap 12 cột

**Câu hỏi:** “`col-sm-4` khác `col-md-4` thế nào? Khi nào dùng Bootstrap cho ba thẻ giá thay vì tự viết Grid?”

**AI trả lời:** Cả hai chiếm 4/12 cột, nhưng `sm` có hiệu lực từ 576px và `md` từ 768px. `col-12 col-md-4` khiến mỗi card toàn hàng ở mobile và ba card nằm ngang từ màn hình tablet. Dùng Bootstrap khi bố cục tiêu chuẩn, cần triển khai nhanh và đồng nhất.

**Ứng dụng:** `.row.g-4` chứa đúng ba `.col-12.col-md-4`. Không tự định nghĩa `width: 33.33%` hoặc `float` cho pricing.

## Prompt 4 — `gap` trong Flexbox và Grid

**Câu hỏi:** “`gap` có dùng được cho cả CSS Grid và Flexbox không? Nó tốt hơn đặt margin tùy tiện ở đâu?”

**AI trả lời:** Có. `gap` tạo khoảng trống đều giữa các item của một container mà không thêm margin ở viền ngoài. Có thể dùng `row-gap` và `column-gap` khi cần khác nhau. Với Flexbox nhiều dòng, `gap` tách cả các dòng và mục; với Grid, `gap` tách các track.

**Ứng dụng:** Navbar sử dụng `gap: 12px 28px`; Dashboard sử dụng `gap: 18px`. Không đặt `margin: 5px` lên từng widget.

## Prompt 5 — Vấn đáp lựa chọn kiến trúc

**Câu hỏi:** “Có thể kết hợp Grid với Flexbox không? Bootstrap Grid có dùng Flexbox ngầm không? Khi nào chọn Grid cho hình zig-zag?”

**AI trả lời:** Có thể kết hợp: Grid bố trí widget ở cấp trang, còn Flexbox căn icon với chữ bên trong mỗi widget. Bootstrap 5 sử dụng Flexbox trong `.row` và `.col-*` để tạo lưới 12 cột. Bố cục zig-zag nhiều hàng/cột có quan hệ hình học nên ưu tiên CSS Grid; Flexbox phù hợp menu hoặc nhóm nút trên một chiều.

**Ứng dụng:** Bento dùng Grid cấp cha, `.widget-header` và `.metric-top` dùng Flexbox cấp con.

## Prompt 6 — Kiểm tra tính trung thực của UI demo

**Câu hỏi:** “Dashboard tĩnh được dùng để thực hành layout nên trình bày các số liệu thế nào?”

**AI trả lời:** Nên ghi rõ dữ liệu là minh họa, không dùng số liệu như thể lấy từ API thật. Với bài tập này không cần thêm backend, chart library hay JavaScript; mục tiêu chính là layout.

**Ứng dụng:** Trang hiển thị dấu `Demo Mode` và ghi chú dữ liệu mẫu.
