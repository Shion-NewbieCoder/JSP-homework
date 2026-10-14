# Thực hành CSS — Menu ngang Dropdown (CodeGym)

## Mục tiêu

Tạo menu **ngang** hai cấp bằng HTML và CSS, submenu tự động **thả xuống bên dưới** khi rê chuột vào `Sem 1` hoặc `Sem 2`. Không sử dụng JavaScript.

## Nội dung và cách kiểm tra

- Menu chính: `Sem 1`, `Sem 2`, `Sem 3`, `Sem 4`.
- `Sem 1`: Computing Fundametal, C Programming, Building Dynamic Website, MS Transact-SQL, Project.
- `Sem 2`: Cloud Computing, APJ - I, APJ - II, APJ - III, eProject.
- Màu nền đen, chữ trắng; rê chuột vào menu đổi sang đỏ; submenu được ẩn với `visibility: hidden`, hiển thị bằng `:hover` (hỗ trợ thêm `:focus-within` cho bàn phím).
- `Sem 3` và `Sem 4` chưa có submenu, đúng mã nguồn mẫu.
- Trang chỉ có liên kết mẫu `href="#"` theo đề, không dẫn đến trang khác.

### Cấu trúc bài nộp

```text
MenuNgang_Dropdown_CSS/
├── index.html
├── styles.css
└── README.md
```

**Cách chạy:** Mở `index.html` trên trình duyệt (không cần server), hover `Sem 1` hoặc `Sem 2`. `styles.css` phải nằm cùng thư mục với `index.html`.

## Mã nguồn `index.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ACCP i10 - Menu ngang Dropdown</title>
    <!-- Nhung CSS tu file rieng theo yeu cau bai tap. -->
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div id="menu" role="navigation" aria-label="ACCP i10 semesters">
        <ul>
            <li><a href="#">Sem 1</a>
                <ul>
                    <li><a href="#">Computing Fundametal</a></li>
                    <li><a href="#">C Programming</a></li>
                    <li><a href="#">Building Dynamic Website</a></li>
                    <li><a href="#">MS Transact-SQL</a></li>
                    <li><a href="#">Project</a></li>
                </ul>
            </li>
            <li><a href="#">Sem 2</a>
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

## Mã nguồn `styles.css`

```css
/* Bai thuc hanh CodeGym: Menu ngang co dropdown. */
body {
    font-family: Arial, sans-serif;
}

/* Thanh menu ngang voi nen den, vien xam, cao 30px. */
#menu {
    height: 30px;
    padding: 0;
    margin: 0;
    background-color: #000000;
    border: 1px solid #CDCDCD;
}

#menu ul,
#menu li {
    padding: 0;
    margin: 0;
}

#menu li {
    position: relative;
    float: left;
    list-style: none;
    margin: 0;
    padding: 0;
}

/* Lien ket trong menu chinh. */
#menu li a {
    width: 100px;
    height: 30px;
    display: block;
    text-decoration: none;
    text-align: center;
    line-height: 30px;
    background-color: black;
    color: white;
}

/* Cac muc con xep theo chieu doc va rong hon menu chinh. */
#menu ul ul li {
    float: none;
}

#menu ul ul li a {
    width: 200px;
    text-align: left;
    padding-left: 10px;
}

/* Hieu ung doi nen do khi dua chuot vao lien ket. */
#menu li a:hover,
#menu li a:focus-visible,
#menu li:hover > a,
#menu li:focus-within > a {
    background-color: red;
}

/* An cac submenu va neo vi tri ngay duoi menu cha. */
#menu ul ul {
    position: absolute;
    top: 30px;
    left: 15px;
    width: 210px;
    visibility: hidden;
    z-index: 10;
}

/* Hover hoac focus vao muc cha thi hien submenu tuong ung. */
#menu ul li:hover > ul,
#menu ul li:focus-within > ul {
    visibility: visible;
}
```

## Đối chiếu bài mẫu

Mã HTML giữ cấu trúc `#menu > ul > li > a` với `ul` lồng nhau như nhánh `develop` của repository CodeGym `jwbd-make-navbar`. CSS sử dụng `float: left`, `position: relative/absolute`, `top: 30px`, `left: 15px`, `visibility` và `:hover` theo bài hướng dẫn. Hai bổ sung nhỏ là `float: none` cho `<li>` của submenu để xếp dọc ổn định, và `:focus-within` hỗ trợ điều hướng bằng bàn phím.
