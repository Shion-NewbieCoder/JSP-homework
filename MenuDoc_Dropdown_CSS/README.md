# Bài thực hành CSS: Tạo menu dọc Dropdown (CodeGym)

**Mục tiêu:** Luyện tập sử dụng CSS để tạo menu dọc, hiển thị menu con khi hover.

## Hướng dẫn xem trang

Mở `index.html` bằng trình duyệt (hoặc VS Code Live Server). Đặt `index.html` và `styles.css` cùng một thư mục. Rê chuột lên **Sem 1** hoặc **Sem 2** để danh sách môn học bung sang phải; mục được hover đổi nền **đỏ**. **Sem 3** và **Sem 4** không có menu con.

## Đối chiếu yêu cầu

- HTML gồm tiêu đề `ACCP i10`, `div#menu`, danh sách `ul > li` và hai danh sách `ul` lồng nhau.
- Đã nhúng file CSS bên ngoài bằng `<link rel="stylesheet" href="styles.css">`.
- Menu nền đen, chữ trắng, bỏ bullet và gạch chân; đổi nền đỏ khi hover.
- Menu con `position: absolute; top: 0; left: 140px; visibility: hidden` theo mẫu.
- CSS `:hover` và `:focus-within` cho phép hiện menu con mà không dùng JavaScript.
- Giữ đủ các mục Sem 1, Sem 2, Sem 3, Sem 4 và tên môn học như đề.
- Điều chỉnh chiều rộng mục submenu để các tên môn dài hiển thị trọn vẹn.

## Mã nguồn đầy đủ để giảng viên / AI chấm đọc trong một file

### index.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ACCP i10 - Menu dọc Dropdown</title>
    <!-- Nhúng CSS ngoài theo đúng yêu cầu bài thực hành. -->
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h3>ACCP i10</h3>
    <div id="menu">
        <ul>
            <li>
                <a href="#">Sem 1</a>
                <ul>
                    <li><a href="#">Computing Fundametal</a></li>
                    <li><a href="#">C Programming</a></li>
                    <li><a href="#">Building Dynamic Website</a></li>
                    <li><a href="#">MS Transact-SQL</a></li>
                    <li><a href="#">Project</a></li>
                </ul>
            </li>
            <li>
                <a href="#">Sem 2</a>
                <ul>
                    <li><a href="#">Cloud Computing</a></li>
                    <li><a href="#">APJ - I</a></li>
                    <li><a href="#">APJ - II</a></li>
                    <li><a href="#">APJ - III</a></li>
                    <li><a href="#">eProject</a></li>
                </ul>
            </li>
            <li><a href="#">Sem 3</a></li>
            <li><a href="#">Sem 4</a></li>
        </ul>
    </div>
</body>
</html>
```

### styles.css

```css
/* THỰC HÀNH: TẠO MENU DỌC DROPDOWN BẰNG CSS - CODEGYM */
body {
    font-family: Arial, sans-serif;
}

/* Bỏ margin/padding mặc định của menu và các danh sách lồng nhau. */
#menu, #menu ul, #menu li {
    padding: 0;
    margin: 0;
}

/* Các mục chính rộng 140px = width 100px + padding ngang 40px. */
#menu li {
    list-style: none;
    position: relative;
    width: 100px;
    height: 30px;
    padding: 0 20px;
    background-color: black;
    line-height: 30px;
    cursor: pointer;
}

#menu li a {
    text-decoration: none;
    color: white;
    display: block;
    white-space: nowrap;
}

/* Hover đổi nền sang đỏ; :focus-within cũng hỗ trợ dùng bàn phím. */
#menu li:hover,
#menu li:focus-within {
    background-color: red;
}

/* Menu con ẩn mặc định, xuất hiện bên phải mục chính. */
#menu ul ul {
    position: absolute;
    top: 0;
    left: 140px;
    visibility: hidden;
}

/* Khi rê chuột vào Sem 1 / Sem 2, hiện danh sách con tương ứng. */
#menu ul li:hover > ul,
#menu ul li:focus-within > ul {
    visibility: visible;
}

/* Giãn riêng submenu để các tên môn học dài không tràn viền nền. */
#menu ul ul li {
    width: 220px;
}

#menu a:focus-visible {
    outline: 2px solid #ffd166;
    outline-offset: -2px;
}
```
