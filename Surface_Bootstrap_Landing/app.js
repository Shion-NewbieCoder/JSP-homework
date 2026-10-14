/* Minimal progressive enhancement: local illustrations always render; official photos are swapped in if loadable. */
(() => {
  const menu = document.getElementById('mainNav');
  const toggle = document.getElementById('menuToggle');
  toggle?.addEventListener('click', () => {
    const expanded = toggle.getAttribute('aria-expanded') === 'true';
    toggle.setAttribute('aria-expanded', String(!expanded));
    menu.classList.toggle('show', !expanded);
  });
  menu?.querySelectorAll('a[href^="#"]').forEach(link => link.addEventListener('click', () => {
    menu.classList.remove('show');
    toggle?.setAttribute('aria-expanded', 'false');
  }));
  document.querySelectorAll('[data-faq]').forEach(button => button.addEventListener('click', () => {
    const target = document.getElementById(button.dataset.faq);
    if (!target) return;
    const isOpen = button.getAttribute('aria-expanded') === 'true';
    document.querySelectorAll('[data-faq]').forEach(b => {b.setAttribute('aria-expanded','false');b.classList.add('collapsed');});
    document.querySelectorAll('.accordion-collapse').forEach(p => p.classList.remove('show'));
    if (!isOpen) {button.setAttribute('aria-expanded','true');button.classList.remove('collapsed');target.classList.add('show');}
  }));
  // Make the page useful offline; remote images are only an enhancement.
  document.querySelectorAll('img[data-official]').forEach(img => {
    const url = img.dataset.official;
    const official = new Image();
    official.onload = () => { img.src = url; };
    official.onerror = () => {}; // Keep local vector illustration in offline mode.
    official.src = url;
  });
})();
