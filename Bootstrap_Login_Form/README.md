# Bootstrap Login Form — CodeGym

## Mục tiêu

Luyện tập sử dụng Bootstrap 5 kết hợp CSS để xây dựng form đăng nhập giống mẫu CodeGym. Bài tập chỉ yêu cầu giao diện, **không có backend xác thực tài khoản**.

## Thành phần

- `index.html` — form gồm ảnh logo, email, password, checkbox `Remember me`, nút `Sign in` và dòng bản quyền.
- `styles.css` — canh giữa form bằng Flexbox, `max-width: 330px`, padding, viền và hiệu ứng focus cho ô nhập; có CSS dự phòng khi CDN không kết nối được.
- `bootstrap.png` — logo chữ B màu tím được vẽ lại để minh hoạ và sử dụng trực tiếp trong bài.
- `preview-desktop.png`, `preview-mobile.png` — ảnh chạy thử giao diện.

## Chạy thử

Mở `index.html` bằng Chrome, Edge hoặc Firefox. Có Internet thì thư viện Bootstrap 5.0.0-beta2 sẽ được tải từ jsDelivr; không có Internet, các quy tắc CSS dự phòng vẫn giúp form hiển thị cơ bản.

Thử nhập email hợp lệ, nhập mật khẩu và chọn **Remember me**. Khi bấm **Sign in**, trang chỉ hiện thông báo demo và **không gửi mật khẩu lên mạng**, do chưa có backend.

## Kiến thức Bootstrap sử dụng

`form-control`, `mb-3`, `mb-4`, `mt-5`, `h3`, `fw-normal`, `btn`, `btn-lg`, `btn-primary`, `w-100`, `text-center`, `text-muted`, `visually-hidden`.

> Bootstrap 5 dùng `fw-normal` thay cho `font-weight-normal` và `w-100` thay cho `btn-block` của các ví dụ Bootstrap 4 cũ.

## Mã nguồn HTML (`index.html`)

```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Bootstrap 5 sign-in form practice — CodeGym">
    <title>Login | Bootstrap Practice</title>
    <!-- Bootstrap 5 CSS: thu vien chinh cua bai tap -->
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css"
          integrity="sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl"
          crossorigin="anonymous">
    <!-- CSS tu viet: can giua form va dieu chinh box model -->
    <link rel="stylesheet" href="styles.css">
</head>
<body class="text-center">
    <main class="form-signin">
        <form id="login-form" action="#" method="post">
            <img class="mb-4" src="bootstrap.png" alt="Bootstrap logo" width="72" height="72">
            <h1 class="h3 mb-3 fw-normal">Please sign in</h1>

            <label class="visually-hidden" for="inputEmail">Email address</label>
            <input type="email" id="inputEmail" name="email" class="form-control"
                   placeholder="Email address" autocomplete="email" required autofocus>

            <label class="visually-hidden" for="inputPassword">Password</label>
            <input type="password" id="inputPassword" name="password" class="form-control"
                   placeholder="Password" autocomplete="current-password" required>

            <div class="checkbox mb-3">
                <label>
                    <input type="checkbox" id="rememberMe" name="remember-me"> Remember me
                </label>
            </div>

            <button class="w-100 btn btn-lg btn-primary" type="submit">Sign in</button>
            <p id="demo-note" class="demo-note" role="status" aria-live="polite"></p>
            <p class="mt-5 mb-3 text-muted copyright">&copy; 2017–2018</p>
        </form>
    </main>

    <!-- Bai tap chi thiet ke giao dien, khong gui password den server. -->
    <script>
        document.getElementById('login-form').addEventListener('submit', function (event) {
            event.preventDefault();
            document.getElementById('demo-note').textContent =
                'Demo form only — no authentication server is connected.';
        });
    </script>
</body>
</html>
```

## Mã nguồn CSS (`styles.css`)

```css
/* CodeGym: sign-in form bang Bootstrap 5 + CSS can giua.
   Bootstrap duoc nap tu CDN trong index.html. Cac quy tac nho duoi day
   giup giao dien van de xem duoc khi may khong co ket noi internet. */
html, body {
    height: 100%;
}

body {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    margin: 0;
    padding: 40px 12px;
    box-sizing: border-box;
    background-color: #f5f5f5;
    color: #212529;
    font-family: system-ui, -apple-system, "Segoe UI", Roboto, Arial, sans-serif;
    text-align: center;
}

.form-signin {
    width: 100%;
    max-width: 330px;
    padding: 15px;
    margin: 0 auto;
}

.form-signin .checkbox {
    font-weight: 400;
}

.form-signin .form-control {
    position: relative;
    display: block;
    width: 100%;
    box-sizing: border-box;
    height: auto;
    padding: 10px;
    font-size: 16px;
    line-height: 1.5;
    color: #212529;
    background: #fff;
    border: 1px solid #ced4da;
    border-radius: .25rem;
}

.form-signin .form-control:focus {
    z-index: 2;
    outline: 0;
    border-color: #86b7fe;
    box-shadow: 0 0 0 .25rem rgba(13,110,253,.25);
}

.form-signin input[type="email"] {
    margin-bottom: -1px;
    border-bottom-right-radius: 0;
    border-bottom-left-radius: 0;
}

.form-signin input[type="password"] {
    margin-bottom: 10px;
    border-top-left-radius: 0;
    border-top-right-radius: 0;
}

/* Fallback rieng cho mot so utility classes cua Bootstrap 5. */
.mb-4 { margin-bottom: 1.5rem; }
.mb-3 { margin-bottom: 1rem; }
.mt-5 { margin-top: 3rem; }
.h3 { margin-top: 0; font-size: 1.75rem; line-height: 1.2; }
.fw-normal { font-weight: 400; }
.text-muted { color: #6c757d; }
.w-100 { width: 100%; }
.visually-hidden {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border: 0;
}
.btn {
    display: inline-block;
    border: 1px solid transparent;
    border-radius: .3rem;
    font-weight: 400;
    cursor: pointer;
    text-align: center;
    vertical-align: middle;
}
.btn-lg { padding: .5rem 1rem; font-size: 1.25rem; line-height: 1.5; }
.btn-primary { background-color: #0d6efd; color: #fff; border-color: #0d6efd; }
.btn-primary:hover { background-color: #0b5ed7; border-color: #0a58ca; }
.btn-primary:focus-visible { outline: 3px solid #86b7fe; outline-offset: 2px; }

.demo-note { min-height: 1.5rem; margin: .75rem 0 0; font-size: 12px; color: #495057; }
.copyright { font-size: 14px; }

@media (max-width: 360px) {
    body { padding: 24px 8px; }
    .form-signin { padding: 10px; }
}
```
