/* Tương tác tối giản cho giao diện demo; không có tài khoản hay backend. */
const composerForm = document.querySelector('#composer-form');
const postInput = document.querySelector('#post-input');
const postList = document.querySelector('#posts-list');
const searchInput = document.querySelector('#global-search');
const toast = document.querySelector('#toast');
let toastTimer;

function showToast(message) {
  toast.textContent = message;
  toast.classList.add('show');
  window.clearTimeout(toastTimer);
  toastTimer = window.setTimeout(() => toast.classList.remove('show'), 2600);
}

function createPost(text) {
  const article = document.createElement('article');
  article.className = 'card post';
  article.dataset.searchable = `minh nguyễn ${text.toLocaleLowerCase('vi')}`;
  const header = document.createElement('div');
  header.className = 'post-header';
  header.innerHTML = '<span class="avatar avatar-me">M</span><div class="post-author"><strong>Minh Nguyễn</strong><span>Vừa xong · 🌐</span></div>';
  const paragraph = document.createElement('p');
  paragraph.className = 'post-text';
  paragraph.textContent = text; // textContent để nội dung nhập vào không trở thành HTML.
  const stats = document.createElement('div');
  stats.className = 'post-stats';
  stats.innerHTML = '<span><span class="reaction-dot">♥</span> <span class="like-count">0</span> lượt thích</span><span>0 bình luận</span>';
  const actions = document.createElement('div');
  actions.className = 'post-actions';
  actions.innerHTML = '<button type="button" class="action-button like-button" aria-pressed="false">♡ Thích</button><button type="button" class="action-button comment-button">☏ Bình luận</button><button type="button" class="action-button share-button">➤ Chia sẻ</button>';
  const commentBox = document.createElement('div');
  commentBox.className = 'comments-box';
  commentBox.hidden = true;
  commentBox.innerHTML = '<input class="comment-input" aria-label="Viết bình luận" placeholder="Viết bình luận..." maxlength="200"><button class="comment-submit" type="button">Gửi</button><div class="comment-items"></div>';
  article.append(header, paragraph, stats, actions, commentBox);
  return article;
}

composerForm.addEventListener('submit', (event) => {
  event.preventDefault();
  const text = postInput.value.trim();
  if (!text) {
    document.querySelector('#composer-status').textContent = 'Nhập nội dung trước khi đăng nhé.';
    postInput.focus();
    return;
  }
  document.querySelector('#composer-status').textContent = '';
  postList.prepend(createPost(text));
  postInput.value = '';
  searchInput.value = '';
  postList.querySelectorAll('.post').forEach(post => { post.hidden = false; });
  showToast('Đã đăng bài trong trang demo!');
});

postList.addEventListener('click', async (event) => {
  const target = event.target;
  const post = target.closest('.post');
  if (!post) return;
  const like = target.closest('.like-button');
  if (like) {
    const pressed = like.getAttribute('aria-pressed') === 'true';
    like.setAttribute('aria-pressed', String(!pressed));
    like.classList.toggle('liked', !pressed);
    const count = post.querySelector('.like-count');
    count.textContent = String(Math.max(0, Number(count.textContent) + (pressed ? -1 : 1)));
    return;
  }
  if (target.closest('.comment-button')) {
    const box = post.querySelector('.comments-box');
    box.hidden = !box.hidden;
    if (!box.hidden) box.querySelector('input').focus();
    return;
  }
  if (target.closest('.comment-submit')) {
    const input = post.querySelector('.comment-input');
    const value = input.value.trim();
    if (!value) { input.focus(); return; }
    const comment = document.createElement('div');
    comment.className = 'comment-item';
    comment.textContent = `Minh Nguyễn: ${value}`;
    post.querySelector('.comment-items').prepend(comment);
    input.value = '';
    showToast('Đã thêm bình luận trong trang demo!');
    return;
  }
  if (target.closest('.share-button')) {
    try {
      if (navigator.clipboard && window.isSecureContext) {
        await navigator.clipboard.writeText(window.location.href);
        showToast('Đã sao chép liên kết trang!');
      } else {
        showToast('Tính năng chia sẻ chỉ là mô phỏng khi mở file offline.');
      }
    } catch {
      showToast('Chưa thể sao chép liên kết trong trình duyệt này.');
    }
  }
});

searchInput.addEventListener('input', () => {
  const term = searchInput.value.trim().toLocaleLowerCase('vi');
  let visible = 0;
  postList.querySelectorAll('.post').forEach(post => {
    const match = post.dataset.searchable.includes(term) || post.innerText.toLocaleLowerCase('vi').includes(term);
    post.hidden = !match;
    if (match) visible += 1;
  });
  if (term && !visible) showToast('Không có bài viết phù hợp.');
});

document.querySelector('[data-focus-composer]').addEventListener('click', () => {
  postInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
  postInput.focus();
});

for (const button of document.querySelectorAll('.request-actions button')) {
  button.addEventListener('click', () => {
    button.closest('.friend-request').remove();
    showToast(button.classList.contains('request-accept') ? 'Đã xác nhận trong bản demo.' : 'Đã ẩn lời mời trong bản demo.');
  });
}
