# QuickFeed — Báo cáo Storage & Performance

**CSDL:** `quickfeed_db` — bảng `Posts` (InnoDB).  
**Môi trường MySQL / ngày đo:** _Điền sau khi chạy Workbench._  
**Dữ liệu:** _Bộ dữ liệu thử nghiệm 10.000 dòng nếu ban đầu bảng rỗng; nếu có dữ liệu sẵn, ghi đúng số liệu thực tế._

## Số liệu đo từ `information_schema.TABLES`

| Thời điểm | Data Length (MB) | Index Length (MB) |
|---|---:|---:|
| Trước DROP | _Điền từ Result Grid `BEFORE`_ | _Điền từ `BEFORE`_ |
| Sau DROP | _Điền từ Result Grid `AFTER`_ | _Điền từ `AFTER`_ |
| Mức thay đổi | _Tính từ số đo_ | _Trước trừ sau_ |

## Báo cáo phân tích (khoảng 200 từ)

Bảng `Posts` có năm chỉ mục phụ và một khóa chính. Khi `INSERT`, InnoDB ghi hàng vào clustered index, đồng thời bảo trì năm cây B-Tree phụ. Điều này tiêu tốn CPU, bộ đệm, ghi đĩa và redo log. Tôi đo `DATA_LENGTH` và `INDEX_LENGTH` bằng `information_schema.TABLES` trước và sau tối ưu; số liệu cụ thể được điền từ MySQL Workbench, không suy đoán.

Tôi giữ `idx_user_id` để truy vấn bài theo người dùng và `idx_created_at` để lọc, sắp xếp theo thời gian. Tôi xóa `idx_content` vì B-Tree tiền tố trên `TEXT` tốn dung lượng và không phù hợp tìm kiếm toàn văn; có thể cân nhắc `FULLTEXT` khi có nhu cầu. Tôi cũng xóa `idx_post_type` và `idx_is_visible` vì chúng có rất ít giá trị phân biệt và ít hữu ích trong kịch bản này. Tuy nhiên, Index có Cardinality thấp vẫn có thể có ích khi lọc giá trị hiếm hoặc kết hợp nhiều cột.

Sau tối ưu, mỗi bài viết mới không còn phải bảo trì ba Index phụ đã bỏ. Đổi lại, truy vấn phụ thuộc vào chúng có thể chậm hơn. `INDEX_LENGTH` là số liệu ước lượng và tệp vật lý không nhất thiết thu nhỏ ngay; không thể khẳng định tăng tốc bao nhiêu lần nếu thiếu đo đạc thực tế.

**Ảnh minh chứng nên chụp:** `SHOW INDEX`, Result Grid `BEFORE`, Result Grid `AFTER` và bảng so sánh cuối script.
