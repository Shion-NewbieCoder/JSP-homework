# Bài thực hành: Sử dụng Index trong MySQL (`classicmodels`)

## Chuẩn bị

1. Tải **MySQL Sample Database** (`classicmodels`) từ [MySQLTutorial.org](https://www.mysqltutorial.org/getting-started-with-mysql/mysql-sample-database/) (đường tải trực tiếp: https://www.mysqltutorial.org/wp-content/uploads/2023/10/mysqlsampledatabase.zip).
2. Giải nén, trong **MySQL Workbench** chọn **File → Open SQL Script**, mở `mysqlsampledatabase.sql` và chạy để nhập cơ sở dữ liệu. **Chỉ import khi máy chưa có `classicmodels`.** Dữ liệu mẫu dùng để học, không phải 500.000 bản ghi như ví dụ minh họa trong đề.
3. Kiểm tra:

   ```sql
   SHOW DATABASES LIKE 'classicmodels';
   USE classicmodels;
   SELECT COUNT(*) AS total_customers FROM customers;
   ```

## Thực hành

Mở `using_index.sql` trong Workbench và chạy toàn bộ **một lần**. Các phần được đánh dấu rõ:

- EXPLAIN trước khi có `idx_customerName`.
- Tạo `idx_customerName(customerName)` và EXPLAIN sau khi tạo.
- EXPLAIN có `FORCE INDEX` để **minh họa** việc sử dụng chỉ mục nếu optimizer chọn quét bảng nhỏ. Không nên xem FORCE INDEX là cách tối ưu mặc định.
- Tạo chỉ mục ghép `idx_full_name(contactFirstName, contactLastName)`, chạy truy vấn theo `contactFirstName`, sau đó xóa chỉ mục ghép.

**Nên chụp lại Result Grid** của hai lần `EXPLAIN` chính và phần `SHOW INDEX` để chứng minh đã thực hiện.

### Cách đọc EXPLAIN

| Trường | Ý nghĩa |
|---|---|
| `type` | Cách truy cập dữ liệu (`ALL` = quét toàn bảng; `ref` = tìm theo chỉ mục không duy nhất). |
| `possible_keys` | Các chỉ mục có thể được dùng. |
| `key` | Chỉ mục optimizer thực sự chọn (`NULL` nếu không chọn). |
| `rows` | Ước lượng số dòng cần xem xét, **không phải** thời gian thực thi hay số dòng quét thực tế. |
| `Extra` | Thông tin bổ sung của kế hoạch thực thi. |

**Lưu ý quan trọng:** `classicmodels` chính thức có rất ít khách hàng so với ví dụ nửa triệu dòng trong đề. Vì thế **optimizer vẫn có thể chọn `type=ALL` sau khi thêm index** nếu quét cả bảng được ước lượng là rẻ hơn. Đó không phải bằng chứng lệnh `CREATE INDEX` thất bại: kiểm tra `SHOW INDEX`, `possible_keys`, và truy vấn `FORCE INDEX` chỉ để học cơ chế. Không được tự ghi số đo tốc độ không được kiểm chứng.

Nếu MySQL phiên bản >= 8.0.18, có thể dùng `EXPLAIN ANALYZE SELECT ...` trước/sau để quan sát số hàng và thời gian thực tế, nhưng với tập dữ liệu nhỏ số đo có thể dao động và ít ý nghĩa.

## Chạy lại

Script cố ý chỉ chạy một lần vì sau lần đầu `idx_customerName` đã tồn tại. Nếu muốn tái chạy toàn bộ từ đầu:

```sql
USE classicmodels;
ALTER TABLE customers DROP INDEX idx_customerName;
```

Sau đó mới chạy lại `using_index.sql`. Không cần xóa cơ sở dữ liệu.

## Nộp bài

Đẩy thư mục `UsingIndex_ClassicModels` lên repository `JSP-homework` và **dán link trực tiếp đến `using_index.sql`** cho CodeGym, không dùng URL `.git` của cả repo.
