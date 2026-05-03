/* Morphia Docs — site JS */
(function () {
  'use strict';

  /* ── Version selector ── */
  function initVersionSelector() {
    var selector = document.getElementById('version-selector');
    var btn      = document.getElementById('version-btn');
    var dropdown = document.getElementById('version-dropdown');
    if (!selector || !btn) return;

    btn.addEventListener('click', function (e) {
      e.stopPropagation();
      var open = selector.classList.toggle('open');
      btn.setAttribute('aria-expanded', String(open));
    });

    document.addEventListener('click', function () {
      selector.classList.remove('open');
      btn.setAttribute('aria-expanded', 'false');
    });

    dropdown && dropdown.addEventListener('click', function (e) {
      e.stopPropagation();
    });

    /* Keyboard navigation */
    btn.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') {
        selector.classList.remove('open');
        btn.setAttribute('aria-expanded', 'false');
        btn.focus();
      }
    });
  }

  /* ── Sticky nav scroll effect ── */
  function initStickyNav() {
    var nav = document.getElementById('site-nav');
    if (!nav) return;
    var threshold = 10;
    function update() {
      nav.classList.toggle('scrolled', window.scrollY > threshold);
    }
    window.addEventListener('scroll', update, { passive: true });
    update();
  }

  /* ── Mobile nav toggle ── */
  function initMobileNav() {
    var toggle = document.getElementById('nav-mobile-toggle');
    var links  = document.querySelector('.nav-links');
    if (!toggle || !links) return;

    toggle.addEventListener('click', function () {
      var open = links.classList.toggle('open');
      toggle.setAttribute('aria-expanded', String(open));
    });
  }

  /* ── Hero morph animation ── */
  function initHeroMorph() {
    var panels = document.querySelectorAll('.morph-panel');
    var arrow  = document.querySelector('.morph-arrow');
    if (!panels.length) return;

    var state = 'java'; // 'java' | 'bson'
    var interval = 3200;

    function toggle() {
      state = state === 'java' ? 'bson' : 'java';
      panels.forEach(function (p) {
        p.style.opacity = '0.4';
        p.style.transform = 'scale(0.97)';
      });
      if (arrow) { arrow.style.transform = state === 'bson' ? 'scaleX(-1)' : 'scaleX(1)'; }
      setTimeout(function () {
        panels.forEach(function (p) {
          p.style.opacity = '1';
          p.style.transform = 'scale(1)';
        });
      }, 200);
    }

    panels.forEach(function (p) {
      p.style.transition = 'opacity 0.2s, transform 0.2s';
    });
    if (arrow) { arrow.style.transition = 'transform 0.3s'; }

    var timer = setInterval(toggle, interval);

    /* Pause on hover */
    var figure = document.querySelector('.hero-figure');
    if (figure) {
      figure.addEventListener('mouseenter', function () { clearInterval(timer); });
      figure.addEventListener('mouseleave', function () { timer = setInterval(toggle, interval); });
    }
  }

  /* ── Docs sidebar mobile toggle ── */
  function initSidebarToggle() {
    var sidebar = document.getElementById('doc-sidebar');
    if (!sidebar) return;

    var toggle = document.createElement('button');
    toggle.className = 'sidebar-mobile-toggle';
    toggle.setAttribute('aria-label', 'Toggle sidebar');
    toggle.textContent = '☰ Contents';
    toggle.style.cssText = [
      'display:none',
      'font-family:var(--font-mono)',
      'font-size:0.8125rem',
      'background:var(--color-bg-card)',
      'border:1.5px solid var(--color-border-strong)',
      'border-radius:var(--radius-pill)',
      'padding:6px 16px',
      'margin:12px 16px',
      'cursor:pointer',
      'color:var(--color-ink)',
    ].join(';');

    var main = document.getElementById('doc-main');
    if (main) {
      main.parentNode.insertBefore(toggle, main);
    }

    toggle.addEventListener('click', function () {
      sidebar.classList.toggle('open');
    });

    var mq = window.matchMedia('(max-width: 768px)');
    function handleMq(e) {
      toggle.style.display = e.matches ? 'block' : 'none';
    }
    mq.addEventListener('change', handleMq);
    handleMq(mq);
  }

  /* ── Code copy buttons ── */
  function initCodeCopy() {
    document.querySelectorAll('pre').forEach(function (pre) {
      var btn = document.createElement('button');
      btn.className = 'code-copy-btn';
      btn.setAttribute('aria-label', 'Copy code');
      btn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>';
      btn.style.cssText = [
        'position:absolute',
        'top:10px',
        'right:10px',
        'background:rgba(255,255,255,0.08)',
        'border:1px solid rgba(255,255,255,0.12)',
        'border-radius:4px',
        'padding:5px',
        'cursor:pointer',
        'color:rgba(255,255,255,0.5)',
        'line-height:0',
        'transition:color 0.15s,background 0.15s',
      ].join(';');

      btn.addEventListener('mouseenter', function () {
        btn.style.color = '#fff';
        btn.style.background = 'rgba(255,255,255,0.15)';
      });
      btn.addEventListener('mouseleave', function () {
        btn.style.color = 'rgba(255,255,255,0.5)';
        btn.style.background = 'rgba(255,255,255,0.08)';
      });

      btn.addEventListener('click', function () {
        var code = pre.querySelector('code');
        var text = code ? code.innerText : pre.innerText;
        navigator.clipboard.writeText(text).then(function () {
          btn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>';
          setTimeout(function () {
            btn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>';
          }, 1500);
        });
      });

      pre.style.position = 'relative';
      pre.appendChild(btn);
    });
  }

  /* ── Init ── */
  document.addEventListener('DOMContentLoaded', function () {
    initVersionSelector();
    initStickyNav();
    initMobileNav();
    initHeroMorph();
    initSidebarToggle();
    initCodeCopy();
  });

})();
