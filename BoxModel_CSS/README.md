# Bài thực hành: Sử dụng CSS Box Model

## Mục tiêu

Sử dụng `border`, `padding`, `margin` và các bộ chọn CSS (`class`, `id`) để định dạng trang HTML theo yêu cầu CodeGym.

## Các bước và kết quả

1. Tạo tài liệu HTML có `head`, `body`, `div` và 3 thẻ `p`.
2. Tạo `class="boxmodel"` với `width: 800px`, `border: 10px solid`, bốn màu viền `chartreuse aqua blue blueviolet`, `padding: 10px` và `margin: 0 auto`.
3. Định dạng `.boxmodel p` bằng `border: 3px dotted darkred` và `padding: 10px`.
4. Dùng 3 bộ chọn ID `#boxmodel1`, `#boxmodel2`, `#boxmodel3` để đặt `margin-bottom` lần lượt **20px**, **40px** và **60px**.

Mã HTML/CSS nằm trong **một file** `index.html`, không có thư viện hay tệp phụ thuộc; chỉ cần mở file bằng trình duyệt.

## Cách xem trên máy tính

Tải hoặc clone repository, sau đó mở `BoxModel_CSS/index.html` bằng Chrome/Edge/Firefox. Khung có chiều rộng nội dung 800px giống mẫu CodeGym nên phù hợp nhất trên màn hình máy tính.

## Toàn bộ mã nguồn bài nộp

Đưa mã trực tiếp vào README để hệ thống chấm có thể xem cả HTML và CSS ngay trong một link.

```html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sử dụng Boxmodel</title>
    <style>
        /* Bước 2: Định dạng khối bao ngoài theo CSS Box Model. */
        .boxmodel {
            margin: 0 auto;
            width: 800px;
            border: 10px;
            padding: 10px;
            border-color: chartreuse aqua blue blueviolet;
            border-style: solid;
        }

        /* Bước 3: Thêm viền chấm và khoảng đệm cho các đoạn văn. */
        .boxmodel p {
            border: 3px dotted darkred;
            padding: 10px;
        }

        /* Bước 4: Đặt khoảng cách lề dưới cho từng đoạn. */
        #boxmodel1 {
            margin-bottom: 20px;
        }

        #boxmodel2 {
            margin-bottom: 40px;
        }

        #boxmodel3 {
            margin-bottom: 60px;
        }
    </style>
</head>
<body>
    <div class="boxmodel">
        <p id="boxmodel1">Mô hình hộp trong CSS về cơ bản là một hộp bao quanh phần tử HTML.
            Nó bao gồm: lề (margin), viền (border), phần đệm (padding) và nội dung (content)</p>
        <p id="boxmodel2">Mô hình hộp trong CSS về cơ bản là một hộp bao quanh phần tử HTML.
            Nó bao gồm: lề (margin), viền (border), phần đệm (padding) và nội dung (content)</p>
        <p id="boxmodel3">Mô hình hộp trong CSS về cơ bản là một hộp bao quanh phần tử HTML.
            Nó bao gồm: lề (margin), viền (border), phần đệm (padding) và nội dung (content)</p>
    </div>
</body>
</html>
```

## Tham khảo

Mã đã đối chiếu với repo CodeGym `codegym-vn/jwbd-using-box-model`, nhánh `develop`, file `index.html`.
