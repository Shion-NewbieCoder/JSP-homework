# AI Prompt Log — QuickFeed Index & Storage

Các câu hỏi kiến thức dưới đây được đối chiếu với phần mô tả bài tập, kèm trả lời giải thích của AI cho bài nộp. Đây **không phải nhật ký thực nghiệm MySQL**; số liệu đo phải lấy trực tiếp từ Workbench.

### Prompt 1: B-Tree Index làm tăng chi phí ghi thế nào?

**Câu hỏi:** "Trong InnoDB, khi INSERT một bài viết vào bảng có năm secondary index, Database phải làm thêm những thao tác gì?"

**AI giải thích:** Ngoài ghi hàng vào clustered index (`PRIMARY KEY`), InnoDB phải thêm entry tương ứng vào từng secondary index. Điều này tiêu tốn CPU, I/O, buffer pool và redo log; đôi khi gây tách trang B-Tree. Bỏ ba index giúp tránh ba lượt cập nhật index phụ cho mỗi hàng mới, không có nghĩa INSERT tự động nhanh gấp ba lần.

### Prompt 2: Cardinality là gì?

**Câu hỏi:** "Vì sao Index trên `is_visible` có hai trạng thái có thể bị MySQL Optimizer bỏ qua khi 99% bản ghi có giá trị 1?"

**AI giải thích:** Cardinality là số lượng giá trị phân biệt (thống kê thường là ước lượng). Khi điều kiện trả về gần như toàn bảng, việc đọc index rồi quay về các hàng dữ liệu có thể đắt hơn quét tuần tự. Index trên cột ít giá trị vẫn có thể hữu ích nếu lọc một trạng thái cực hiếm hoặc là một phần của composite index phù hợp.

### Prompt 3: Đo Data và Index theo MB thế nào?

**Câu hỏi:** "Tôi xem `DATA_LENGTH`, `INDEX_LENGTH` của bảng InnoDB qua `information_schema.TABLES` như thế nào?"

**AI giải thích:** Lọc theo `TABLE_SCHEMA = 'quickfeed_db'` và `TABLE_NAME = 'Posts'`, rồi chia các giá trị byte cho `1024*1024`. Đây là số liệu thống kê ước lượng; với InnoDB, `DATA_LENGTH` phản ánh clustered index, `INDEX_LENGTH` phản ánh secondary indexes, chưa chắc tương đương dung lượng file được trả ngay về hệ điều hành.

### Prompt 4: Nên tìm kiếm TEXT bằng cách nào?

**Câu hỏi:** "Nếu cần tìm từ khóa trong `content` kiểu TEXT thì `FULLTEXT` khác gì B-Tree `content(255)`?"

**AI giải thích:** `FULLTEXT` có chỉ mục đảo phục vụ truy vấn từ khóa bằng `MATCH ... AGAINST`; B-Tree tiền tố thường phục vụ so khớp bắt đầu từ đầu chuỗi, không tối ưu tìm từ nằm bất kỳ vị trí nào. FULLTEXT vẫn có chi phí dung lượng và ghi, vì vậy chỉ tạo khi chức năng tìm kiếm yêu cầu.

### Prompt 5: Index trên bảng Archive có bất lợi không?

**Câu hỏi:** "Nếu Posts chủ yếu chỉ được đọc và hiếm khi INSERT/UPDATE/DELETE, có nên xóa nhiều Index như bảng hoạt động không?"

**AI giải thích:** Chi phí bảo trì Index giảm khi số thao tác ghi rất ít. Có thể duy trì nhiều Index phục vụ báo cáo, nhưng vẫn phải cân đối dung lượng và lợi ích truy vấn; quyết định dựa trên truy vấn thực tế, không chỉ đếm số Index.
