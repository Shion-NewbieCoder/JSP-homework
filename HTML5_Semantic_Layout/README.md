# Thực hành CodeGym — Bố cục trang web bằng các thẻ HTML5

## Mục tiêu
Thiết kế trang web dùng các thẻ ngữ nghĩa HTML5: `header`, `nav`, `section`, `article`, `aside`, `footer`; bố trí và trang trí bằng CSS.

## Cấu trúc
- `index.html`: mã HTML5, dùng `main` chứa `section` (hai `article`) và `aside`.
- `styles.css`: style giao diện, CSS Grid cho 2 cột và media query cho điện thoại.

## Cách chạy
Mở `index.html` trực tiếp bằng Chrome, Edge hoặc Firefox. Không cần cài đặt thư viện, máy chủ hay JavaScript. Có thể nhấp các liên kết trong `nav` và `aside` để cuộn tới vùng tương ứng.

## Mô tả bố cục
```text
+----------------------------------------------+
|                    HEADER                    |
+----------------------------------------------+
|                     NAV                      |
+-------------------------------+--------------+
|            SECTION            |    ASIDE     |
|   +-----------------------+   |              |
|   |       ARTICLE 1       |   |              |
|   +-----------------------+   |              |
|   |       ARTICLE 2       |   |              |
|   +-----------------------+   |              |
+-------------------------------+--------------+
|                    FOOTER                    |
+----------------------------------------------+
```

## Kiểm tra yêu cầu
| Phần | Tag HTML5 | Vai trò |
|---|---|---|
| Đầu trang | `header` | Tiêu đề và giới thiệu |
| Điều hướng | `nav` | Menu dẫn tới các khu vực |
| Nội dung chính | `section` | Nhóm nội dung chung chủ đề |
| Bài viết | `article` | Hai bài viết độc lập |
| Thanh bên | `aside` | Liên kết nhanh và ghi chú |
| Chân trang | `footer` | Thông tin cuối trang |

> Bố cục minh hoạ được dựng từ mô tả yêu cầu. Ảnh gốc lưu trữ trên máy chủ CodeGym không truy cập được tại thời điểm thực hiện nên có thể khác màu sắc/khoảng cách so với mẫu.

## Nguồn code — HTML
> Mã HTML đầy đủ được chép tại đây để hệ thống chấm đọc được khi chỉ nhận một liên kết README.

```html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Bài thực hành thiết kế bố cục HTML5 với header, nav, section, article, aside và footer.">
    <title>Bố cục trang web bằng HTML5 và CSS</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body id="dau-trang">
    <div class="page-wrapper">
        <!-- HEADER: đầu trang, chứa tiêu đề và giới thiệu. -->
        <header class="site-header">
            <span class="region-label">&lt;header&gt;</span>
            <h1>Khám phá HTML5 &amp; CSS</h1>
            <p>Một trang web mẫu với cấu trúc ngữ nghĩa rõ ràng</p>
        </header>

        <!-- NAV: khu vực điều hướng chính của trang. -->
        <nav class="main-nav" aria-label="Điều hướng chính">
            <span class="region-label">&lt;nav&gt;</span>
            <ul>
                <li><a href="#dau-trang">Trang chủ</a></li>
                <li><a href="#gioi-thieu">Giới thiệu</a></li>
                <li><a href="#bai-viet-1">Bài viết</a></li>
                <li><a href="#thanh-ben">Liên kết</a></li>
                <li><a href="#chan-trang">Liên hệ</a></li>
            </ul>
        </nav>

        <!-- MAIN: nội dung duy nhất của trang, gồm SECTION và ASIDE. -->
        <main class="content-layout" id="noi-dung">
            <!-- SECTION: nhóm bài viết cùng chủ đề. -->
            <section class="articles-section" id="gioi-thieu" aria-labelledby="section-title">
                <span class="region-label">&lt;section&gt;</span>
                <h2 id="section-title">Nội dung chính</h2>
                <p class="section-intro">HTML5 giúp chúng ta tổ chức trang web thành những phần có ý nghĩa, dễ đọc và dễ bảo trì.</p>

                <!-- ARTICLE: bài viết độc lập bên trong SECTION. -->
                <article class="article-card" id="bai-viet-1">
                    <span class="region-label">&lt;article&gt;</span>
                    <h3>Bài viết 1: Các thẻ ngữ nghĩa HTML5</h3>
                    <p>Thẻ <code>header</code> thường là vùng đầu trang, <code>nav</code> chứa liên kết điều hướng,
                        còn <code>section</code> dùng để gom nhóm những nội dung có chung chủ đề.</p>
                    <p>Mỗi <code>article</code> là một khối nội dung tương đối độc lập, chẳng hạn tin tức hoặc bài blog.</p>
                </article>

                <article class="article-card" id="bai-viet-2">
                    <span class="region-label">&lt;article&gt;</span>
                    <h3>Bài viết 2: Kết hợp CSS để tạo layout</h3>
                    <p>CSS giúp thiết lập màu nền, khoảng cách, đường viền và vị trí của từng vùng.
                        Trong ví dụ này, <code>display: grid</code> đặt nội dung chính và thanh bên cạnh nhau.</p>
                    <p>Khi cửa sổ nhỏ, media query đưa hai vùng về một cột để dễ theo dõi trên điện thoại.</p>
                </article>
            </section>

            <!-- ASIDE: thông tin bổ trợ bên cạnh SECTION. -->
            <aside class="sidebar" id="thanh-ben" aria-labelledby="aside-title">
                <span class="region-label">&lt;aside&gt;</span>
                <h2 id="aside-title">Thanh bên</h2>
                <p>Thông tin liên quan đến nội dung chính.</p>
                <h3>Mục lục nhanh</h3>
                <ul>
                    <li><a href="#bai-viet-1">Các thẻ HTML5</a></li>
                    <li><a href="#bai-viet-2">Bố cục bằng CSS</a></li>
                    <li><a href="#chan-trang">Thông tin cuối trang</a></li>
                </ul>
                <div class="tip-box">
                    <strong>Mẹo học:</strong> Mở Developer Tools (F12) để xem trực tiếp vị trí của các phần tử.
                </div>
            </aside>
        </main>

        <!-- FOOTER: phần cuối trang. -->
        <footer class="site-footer" id="chan-trang">
            <span class="region-label">&lt;footer&gt;</span>
            <p>© 2026 · Bài thực hành HTML5 Semantic Layout · CodeGym</p>
            <a href="#dau-trang">↑ Về đầu trang</a>
        </footer>
    </div>
</body>
</html>

```

## Nguồn code — CSS
```css
/* BÀI THỰC HÀNH CODEGYM: HTML5 SEMANTIC LAYOUT
   Các thẻ chính: header, nav, section, article, aside, footer.
   Bố cục: HEADER / NAV / [SECTION + ASIDE] / FOOTER.
*/

:root {
    font-family: Arial, Helvetica, sans-serif;
    color: #1d3147;
    background-color: #f2f5fa;
}

* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body { margin: 0; }
a { color: #1454a0; }
a:focus-visible { outline: 3px solid #f5a623; outline-offset: 3px; }

.page-wrapper {
    width: min(1100px, calc(100% - 48px));
    margin: 32px auto;
}

.region-label {
    display: inline-block;
    font-family: Consolas, 'Courier New', monospace;
    font-size: .78rem;
    font-weight: 700;
    letter-spacing: .04em;
    padding: 5px 9px;
    border-radius: 6px;
    color: #1d5188;
    background: #e3effc;
    margin-bottom: 10px;
}

/* 1. HEADER - nằm trên cùng. */
.site-header {
    padding: 35px 42px;
    text-align: center;
    background-color: #ddeafa;
    border: 2px solid #94b7de;
    border-radius: 14px 14px 0 0;
}
.site-header h1 { margin: 2px 0 8px; color: #163d6c; font-size: clamp(1.7rem, 4vw, 2.5rem); }
.site-header p { margin: 0; color: #496582; }

/* 2. NAV - đặt ngay dưới header. */
.main-nav {
    background-color: #214b78;
    padding: 13px 24px;
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
    align-items: center;
}
.main-nav .region-label { margin: 0; background: #426b99; color: #fff; }
.main-nav ul { margin: 0; padding: 0; list-style: none; display: flex; flex-wrap: wrap; gap: 8px; }
.main-nav a { display: block; color: #fff; font-size: .94rem; font-weight: 600; padding: 10px 12px; border-radius: 7px; text-decoration: none; }
.main-nav a:hover, .main-nav a:focus-visible { background: #376caa; }

/* 3. MAIN: section chiếm phần lớn, aside nằm bên phải. */
.content-layout {
    display: grid;
    grid-template-columns: minmax(0, 2fr) minmax(240px, 1fr);
    gap: 20px;
    padding: 20px 0;
}
.articles-section, .sidebar {
    border-radius: 12px;
    border: 2px solid #b7cde5;
    padding: 24px;
}
.articles-section { background: #e9f2fc; }
.articles-section h2, .sidebar h2 { margin: 0 0 12px; font-size: 1.6rem; }
.section-intro { margin: 0 0 20px; line-height: 1.65; color: #49617e; }

/* 4. ARTICLE: bài viết riêng nằm trong section. */
.article-card {
    background-color: #fff;
    border: 1px solid #cbd9e7;
    border-left: 5px solid #4280bc;
    border-radius: 9px;
    padding: 20px 22px;
    margin-top: 16px;
    box-shadow: 0 4px 12px rgb(25 65 105 / 5%);
}
.article-card .region-label { color: #246b55; background: #e3f7ee; }
.article-card h3 { margin: 0 0 12px; font-size: 1.16rem; }
.article-card p { margin: 10px 0; line-height: 1.65; }
.article-card code { color: #9b3960; background: #f9edf2; padding: 2px 4px; border-radius: 3px; }

/* 5. ASIDE: cột thông tin bổ trợ. */
.sidebar { background-color: #f0eefa; border-color: #cdc5e9; }
.sidebar .region-label { color: #7043a1; background: #e6ddf6; }
.sidebar p { line-height: 1.6; }
.sidebar h3 { font-size: 1rem; margin: 22px 0 8px; }
.sidebar ul { margin: 0; padding-left: 20px; }
.sidebar li { margin: 12px 0; }
.sidebar a { text-decoration-thickness: 1px; text-underline-offset: 3px; }
.tip-box { margin-top: 26px; padding: 16px; background: #fff; border-radius: 8px; line-height: 1.6; border: 1px solid #ded6f3; }

/* 6. FOOTER: kết thúc và trải rộng theo trang. */
.site-footer {
    background-color: #dce8f4;
    border: 2px solid #acc4dd;
    border-radius: 0 0 14px 14px;
    padding: 24px 32px;
    text-align: center;
}
.site-footer .region-label { display: table; margin: 0 auto 12px; }
.site-footer p { margin: 0 0 8px; color: #436180; }
.site-footer a { font-weight: 600; }

/* Responsive: màn hình hẹp thì section và aside xếp dọc. */
@media (max-width: 760px) {
    .page-wrapper { width: min(100% - 24px, 550px); margin: 12px auto; }
    .site-header { padding: 28px 16px; }
    .main-nav { padding: 13px; gap: 10px; }
    .main-nav ul { gap: 3px; }
    .main-nav a { padding: 9px; }
    .content-layout { grid-template-columns: 1fr; gap: 14px; padding: 14px 0; }
    .articles-section, .sidebar { padding: 18px; }
    .article-card { padding: 16px; }
    .site-footer { padding: 20px 12px; }
}

```
