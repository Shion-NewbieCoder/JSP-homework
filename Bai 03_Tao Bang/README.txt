# Bài 3 - Tạo bảng bằng SQL

## Yêu cầu
- Tạo CSDL `demo`
- Tạo bảng `Student`
- Các trường: `id`, `name`, `age`, `country`

## Câu lệnh SQL

```sql
CREATE DATABASE demo;

USE demo;

CREATE TABLE Student (
    id INT,
    name VARCHAR(200),
    age INT,
    country VARCHAR(50)
);