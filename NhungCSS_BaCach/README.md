# Bài tập CodeGym: Ba cách nhúng CSS vào HTML

**Mục tiêu:** Luyện tập thay đổi màu chữ bằng Inline CSS, Internal CSS và External CSS.

## Các bài làm

| Phần | Cách nhúng | File bài làm | Vị trí viết CSS |
|---|---|---|---|
| 1 | **Inline Style** | [`index.html`](index.html) | Thuộc tính `style` trên `<h1>` và `<p>` |
| 2 | **Internal Style** | [`internal-style.html`](internal-style.html) | Thẻ `<style>` trong `<head>` |
| 3 | **External Style** | [`external-style.html`](external-style.html) + [`style.css`](style.css) | File CSS được liên kết bằng `<link rel="stylesheet" href="style.css">` |

**Mỗi trang** có đúng một thẻ `<h1>` và một thẻ `<p>`, với cùng nội dung và cùng kết quả hiển thị: tiêu đề **màu xanh (`blue`)**, đoạn văn **màu đỏ (`red`)**. Các trang không cần JavaScript, thư viện hoặc internet.

## Bằng chứng mã nguồn cho từng phần

### Phần 1 — Inline CSS

Trong `index.html`:

```html
<h1 style="color: blue;">Đây là tiêu đề</h1>
<p style="color: red;">Đây là đoạn văn bản.</p>
```

### Phần 2 — Internal CSS

Trong `internal-style.html`:

```html
<style>
    h1 { color: blue; }
    p { color: red; }
</style>
```

### Phần 3 — External CSS

Trong `external-style.html`:

```html
<link rel="stylesheet" href="style.css">
```

Nội dung file `style.css`:

```css
h1 { color: blue; }
p { color: red; }
```

## Kiểm tra và nộp

1. Mở lần lượt `index.html`, `internal-style.html`, `external-style.html` trong trình duyệt và kiểm tra màu chữ giống nhau.
2. Đặt nguyên thư mục `NhungCSS_BaCach` vào repo `JSP-homework` (giữ `style.css` cùng thư mục `external-style.html`).
3. Chạy `git add NhungCSS_BaCach/`, `git commit -m "feat: practice three CSS inclusion methods"`, `git push origin main`.
4. Nộp link README để hệ thống chấm thấy **đầy đủ cả ba phần trong một tệp**: `https://github.com/Shion-NewbieCoder/JSP-homework/blob/main/NhungCSS_BaCach/README.md`.

Có thể mở trực tiếp từng file HTML trên GitHub để xem mã nguồn; trình duyệt local dùng để xem kết quả giao diện.
