# PayFlow — Nhật ký trao đổi AI (Index và SARGable)

## 1. Đọc kế hoạch EXPLAIN
**Vấn đề trao đổi:** Các giá trị `type` (`ALL`, `index`, `range`, `ref`, `const`) biểu thị điều gì?

**Kết luận:** `ALL` thường là full table scan, `index` có thể là quét toàn chỉ mục, `range` là quét một khoảng khóa, `ref` là tra cứu dựa trên giá trị khóa không duy nhất, và `const` là tìm tối đa một hàng bằng khóa phù hợp. Không thể kết luận hiệu năng từ riêng `type`; cần xem `rows`, `key`, `Extra` và dữ liệu thật.

## 2. Điều kiện SARGable
**Vấn đề trao đổi:** Vì sao `YEAR(created_at)` và `MONTH(created_at)` thường cản trở việc dùng chỉ mục B-tree trên `created_at`?

**Kết luận:** Bọc hàm quanh cột khiến MySQL khó dùng thứ tự khóa để tìm một khoảng ngày trực tiếp. Dùng `created_at >= mốc_đầu` và `created_at < mốc_tháng_sau` giữ nguyên ý nghĩa lọc tháng và dễ dùng index.

## 3. Index ghép
**Vấn đề trao đổi:** Với điều kiện một cột so sánh bằng và một cột lọc theo khoảng, nên xét thứ tự cột trong composite index ra sao?

**Kết luận:** B-tree index `(transaction_type, created_at)` có thể khai thác cột đầu cho điều kiện bằng, sau đó dùng cột thứ hai để giới hạn khoảng thời gian. Đây là lựa chọn cho truy vấn cụ thể này, không phải quy tắc đúng cho mọi truy vấn.

## 4. Kiểm chứng sau tối ưu
**Vấn đề trao đổi:** Có được suy ra số dòng quét thực tế từ `EXPLAIN rows` không?

**Kết luận:** Không. `rows` là ước lượng; để đánh giá sâu hơn có thể dùng `EXPLAIN ANALYZE` trên MySQL 8.0.18+ và đo trên dữ liệu phù hợp. Cần kiểm tra kết quả `SUM(amount)` trước/sau giống nhau.

> Nhật ký tổng hợp các câu hỏi kỹ thuật và câu trả lời trong quá trình làm bài với AI. Học viên cần rà lại cách diễn đạt để phản ánh đúng trải nghiệm của mình.
