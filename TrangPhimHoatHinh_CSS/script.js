'use strict';

// Bài tập HTML5: video nội bộ có lời đọc tiếng Việt; các video YouTube
// dùng URL nhúng chính thức. Số lượt xem là snapshot minh họa từ nguồn tra cứu,
// không phải dữ liệu realtime/API.
const VIDEOS = [
  {
    id: 'traffic-local', type: 'html5', title: 'Bé học đèn giao thông — Video HTML5',
    channel: 'Bé Vui Xem · Video tự tạo', date: '2026-10-15', views: 0,
    emoji: '🚦', thumb: '#d9edf7', category: 'skills', quality: 'HTML5 · HD 720p',
    kind: 'Kỹ năng sống',
    description: 'Video giáo dục ngắn do bài tập tự tạo, có lời đọc tiếng Việt và hình minh họa ba màu đèn giao thông. Không có quảng cáo.',
    url: 'assets/be-hoc-den-giao-thong-720p.mp4'
  },
  {
    id: 'eJ-ZD_B6ySQ', type: 'youtube', title: 'Lucy học luật an toàn giao thông',
    channel: 'Wolfoo Việt Nam', date: '2026-01-11', views: 230524,
    emoji: '🚗', thumb: '#f6e5d6', category: 'skills', quality: 'YouTube · Tiếng Việt',
    kind: 'An toàn giao thông',
    description: 'Wolfoo Việt Nam: Lucy và các bạn học đèn xanh, đèn đỏ và cách sang đường an toàn.',
    url: 'https://www.youtube.com/watch?v=eJ-ZD_B6ySQ'
  },
  {
    id: 'R9kvGmhC-L8', type: 'youtube', title: 'Năm mới đầy niềm vui với gia đình Wolfoo',
    channel: 'Wolfoo Tiếng Việt', date: '2024-12-30', views: 1889771,
    emoji: '🎆', thumb: '#f5dff0', category: 'family', quality: 'YouTube · Tiếng Việt',
    kind: 'Gia đình',
    description: 'Một tập đặc biệt về không khí năm mới và khoảnh khắc vui vẻ cùng gia đình Wolfoo.',
    url: 'https://www.youtube.com/watch?v=R9kvGmhC-L8'
  },
  {
    id: 'uy31yJ_KikA', type: 'youtube', title: 'Phòng bí mật tránh bão — Bài học an toàn',
    channel: 'Wolfoo Tiếng Việt', date: '2024-12-14', views: 2658297,
    emoji: '🌈', thumb: '#ddf3e7', category: 'skills', quality: 'YouTube · Tiếng Việt',
    kind: 'Kỹ năng sống',
    description: 'Wolfoo cùng các bạn khám phá bài học về an toàn khi gặp bão, qua câu chuyện vui nhộn.',
    url: 'https://www.youtube.com/watch?v=uy31yJ_KikA'
  },
  {
    id: 'iPFYdfbepW8', type: 'youtube', title: 'Wolfoo Tết gắn kết — Chuyện gia đình ngày Tết',
    channel: 'Wolfoo Tiếng Việt', date: '2024-02-09', views: 3057937,
    emoji: '🧧', thumb: '#faebd3', category: 'family', quality: 'YouTube · Tiếng Việt',
    kind: 'Gia đình',
    description: 'Tập đặc biệt về Tết, sum họp gia đình và những lời chúc năm mới.',
    url: 'https://www.youtube.com/watch?v=iPFYdfbepW8'
  }
];

const $ = id => document.getElementById(id);
const playlist = $('playlist');
const searchInput = $('searchInput');
const sortSelect = $('sortSelect');
const html5Player = $('html5Player');
const youtubePlayer = $('youtubePlayer');
let activeId = VIDEOS[0].id;
let category = 'all';

const humanDate = iso => iso.split('-').reverse().join('/');
const viewLabel = n => n === 0 ? 'Video tự tạo' : `${new Intl.NumberFormat('vi-VN', {notation: 'compact', maximumFractionDigits: 1}).format(n)} lượt xem*`;
function filteredVideos() {
  const term = searchInput.value.trim().toLocaleLowerCase('vi-VN');
  const result = VIDEOS.filter(v => (category === 'all' || v.category === category || (category === 'html5' && v.type === 'html5')) && `${v.title} ${v.channel} ${v.kind}`.toLocaleLowerCase('vi-VN').includes(term));
  if (sortSelect.value === 'popular') result.sort((a,b) => b.views - a.views);
  else if (sortSelect.value === 'name') result.sort((a,b) => a.title.localeCompare(b.title,'vi'));
  else result.sort((a,b) => b.date.localeCompare(a.date));
  return result;
}
function renderPlaylist() {
  const videos = filteredVideos();
  playlist.replaceChildren();
  $('videoCount').textContent = `${videos.length} phim`;
  if (!videos.length) {
    const empty = document.createElement('p');
    empty.className = 'empty-state';
    empty.textContent = 'Chưa tìm thấy phim phù hợp. Thử tên khác nhé!';
    playlist.appendChild(empty);
  }
  for (const video of videos) {
    const card = document.createElement('button');
    card.type = 'button';
    card.className = `episode-card${activeId === video.id ? ' selected' : ''}`;
    card.setAttribute('aria-pressed', String(activeId === video.id));
    const thumb = document.createElement('span');
    thumb.className = 'card-thumb';
    thumb.style.setProperty('--thumb-bg',video.thumb);
    thumb.textContent=video.emoji;
    const play = document.createElement('span');
    play.className='play-mark'; play.textContent='▶'; thumb.append(play);
    const text = document.createElement('span');
    const title = document.createElement('span');
    title.className='card-title'; title.textContent=video.title;
    const meta = document.createElement('span'); meta.className='card-meta';
    const kind = document.createElement('span'); kind.className='video-kind';kind.textContent=video.type==='html5'?'HTML5':'YouTube';
    const date = document.createElement('span'); date.textContent=humanDate(video.date);
    meta.append(kind,date); text.append(title,meta); card.append(thumb,text);
    card.addEventListener('click',() => selectVideo(video.id));
    playlist.append(card);
  }
  $('playlistHint').textContent = sortSelect.value==='popular' ? '*Lượt xem của YouTube là số liệu tham khảo tại thời điểm tìm nguồn, không cập nhật tự động.' : 'Chọn một video để bắt đầu xem nhé!';
}
function selectVideo(id) {
  const video = VIDEOS.find(v => v.id === id);
  if (!video) return;
  activeId=id;
  // Stop playback of the previously active player, including embedded YouTube.
  html5Player.pause();
  youtubePlayer.src='about:blank';
  const useYoutube = video.type === 'youtube';
  html5Player.hidden=useYoutube;
  youtubePlayer.hidden=!useYoutube;
  if(useYoutube) {
    // Do not autoplay: a child/parent starts playback intentionally.
    youtubePlayer.title = `Hoạt hình: ${video.title}`;
    youtubePlayer.src=`https://www.youtube-nocookie.com/embed/${video.id}?rel=0`;
  } else {
    html5Player.currentTime=0;
    html5Player.load();
  }
  $('currentTitle').textContent=video.title;
  $('currentDescription').textContent=video.description;
  $('currentChannel').textContent=video.channel;
  $('currentDate').textContent=humanDate(video.date);
  $('qualityTag').textContent=video.quality;
  $('typePill').textContent=video.kind;
  $('sourceLink').href=video.url;
  $('sourceLink').textContent=useYoutube?'↗ Mở video gốc trên YouTube':'↗ Mở video HTML5';
  renderPlaylist();
}

function applyCategory(next) {
  category=next;
  document.querySelectorAll('[data-nav]').forEach(el=>el.classList.toggle('active',el.dataset.nav===category));
  renderPlaylist();
  // Keep selected video playing until user explicitly selects another one.
}
document.querySelectorAll('[data-nav]').forEach(link=>{
  link.addEventListener('click',()=>applyCategory(link.dataset.nav));
});
$('searchForm').addEventListener('submit',e=>{e.preventDefault();renderPlaylist();$('danh-sach').scrollIntoView({behavior:'smooth'});});
searchInput.addEventListener('input',renderPlaylist);
sortSelect.addEventListener('change',renderPlaylist);
selectVideo(VIDEOS[0].id);
