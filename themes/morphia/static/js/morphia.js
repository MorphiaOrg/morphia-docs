/* Morphia Docs — site JS */
(function () {
  'use strict';

  /* ── Version switcher ── */
  var ver = document.getElementById('ver');
  var verBtn = document.getElementById('ver-btn');
  if (ver && verBtn) {
    verBtn.addEventListener('click', function () {
      var open = ver.classList.toggle('open');
      verBtn.setAttribute('aria-expanded', String(open));
    });
    document.addEventListener('click', function (e) {
      if (!ver.contains(e.target)) {
        ver.classList.remove('open');
        verBtn.setAttribute('aria-expanded', 'false');
      }
    });
    verBtn.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') {
        ver.classList.remove('open');
        verBtn.setAttribute('aria-expanded', 'false');
        verBtn.focus();
      }
    });
  }

  /* ── Copy buttons ── */
  function copyText(text) {
    if (navigator.clipboard) {
      navigator.clipboard.writeText(text).catch(function () { fallbackCopy(text); });
    } else {
      fallbackCopy(text);
    }
  }
  function fallbackCopy(text) {
    var ta = document.createElement('textarea');
    ta.value = text;
    ta.style.cssText = 'position:fixed;top:-9999px;left:-9999px;opacity:0';
    document.body.appendChild(ta);
    ta.select();
    try { document.execCommand('copy'); } catch (_) {}
    document.body.removeChild(ta);
  }
  document.querySelectorAll('[data-copy]').forEach(function (el) {
    el.addEventListener('click', function () {
      var textEl = el.querySelector('.text');
      var copyEl = el.querySelector('.copy');
      if (!textEl || !copyEl) return;
      copyText(textEl.textContent.trim());
      var prev = copyEl.textContent;
      copyEl.textContent = '✓';
      setTimeout(function () { copyEl.textContent = prev; }, 1400);
    });
  });

  /* ── Morph animation ── */
  var leftRows  = document.querySelectorAll('#java-pre .row.left');
  var rightRows = document.querySelectorAll('#bson-pre .row.right');
  var badge     = document.getElementById('bridge-badge');
  if (leftRows.length && rightRows.length) {
    var idx = 0;
    var dir = 'to-bson';
    function tick() {
      leftRows.forEach(function (r) { r.classList.remove('active'); });
      rightRows.forEach(function (r) { r.classList.remove('active'); });
      leftRows[idx].classList.add('active');
      rightRows[idx].classList.add('active');
      idx = (idx + 1) % leftRows.length;
      if (idx === 0) {
        dir = (dir === 'to-bson') ? 'to-java' : 'to-bson';
        if (badge) badge.textContent = dir === 'to-bson' ? 'morph →' : '← morph';
      }
    }
    tick();
    setInterval(tick, 1300);
  }

  /* ── Docs sidebar mobile toggle ── */
  var sidebar = document.getElementById('doc-sidebar');
  if (sidebar) {
    var sidebarToggle = document.createElement('button');
    sidebarToggle.setAttribute('aria-label', 'Toggle sidebar');
    sidebarToggle.textContent = '☰ Contents';
    sidebarToggle.style.cssText = 'display:none;font-family:var(--font-mono);font-size:0.8125rem;background:var(--paper);border:1px solid var(--rule-2);border-radius:var(--radius-pill);padding:6px 16px;margin:12px 16px;cursor:pointer;color:var(--ink)';
    var docMain = document.getElementById('doc-main');
    if (docMain) docMain.parentNode.insertBefore(sidebarToggle, docMain);
    sidebarToggle.addEventListener('click', function () { sidebar.classList.toggle('open'); });
    var mq = window.matchMedia('(max-width: 960px)');
    function handleMq(e) { sidebarToggle.style.display = e.matches ? 'block' : 'none'; }
    mq.addEventListener('change', handleMq);
    handleMq(mq);
  }

  /* ── Code copy buttons for doc pages ── */
  document.querySelectorAll('.doc-content pre').forEach(function (pre) {
    var copyBtn = document.createElement('button');
    copyBtn.setAttribute('aria-label', 'Copy code');
    copyBtn.style.cssText = 'position:absolute;top:10px;right:10px;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.12);border-radius:4px;padding:5px;cursor:pointer;color:rgba(255,255,255,0.5);line-height:0;transition:color .15s,background .15s';
    var svgCopy = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svgCopy.setAttribute('width', '14'); svgCopy.setAttribute('height', '14');
    svgCopy.setAttribute('viewBox', '0 0 24 24'); svgCopy.setAttribute('fill', 'none');
    svgCopy.setAttribute('stroke', 'currentColor'); svgCopy.setAttribute('stroke-width', '2');
    var r = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    r.setAttribute('x', '9'); r.setAttribute('y', '9'); r.setAttribute('width', '13'); r.setAttribute('height', '13'); r.setAttribute('rx', '2');
    var p = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    p.setAttribute('d', 'M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1');
    svgCopy.appendChild(r); svgCopy.appendChild(p);
    copyBtn.appendChild(svgCopy);
    copyBtn.addEventListener('click', function () {
      var code = pre.querySelector('code');
      var text = code ? code.innerText : pre.innerText;
      navigator.clipboard && navigator.clipboard.writeText(text);
    });
    pre.style.position = 'relative';
    pre.appendChild(copyBtn);
  });

})();
