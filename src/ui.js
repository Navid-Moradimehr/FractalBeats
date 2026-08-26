const KEY_TO_INDEX = { '1': 0, '2': 1, '3': 2, '4': 3, '5': 4 };

function fmtTime(s) {
  if (!isFinite(s)) return '0:00';
  const m = Math.floor(s / 60);
  const sec = Math.floor(s % 60);
  return `${m}:${String(sec).padStart(2, '0')}`;
}

export function initUI({ engine, app, screenDefs, onSwitch }) {
  const $ = (id) => document.getElementById(id);
  const playBtn = $('play-btn');
  const playIcon = () => (engine.isPlaying ? '⏸' : '▶');
  const overlay = $('picker-overlay');
  let seeking = false;

  // --- Screen cards ---
  const grid = $('card-grid');
  const keyRange = screenDefs.length > 1 ? `1–${screenDefs.length}` : '1';
  document.querySelector('#picker-overlay .picker-sub').textContent =
    `Pick a visual screen — switch anytime with keys ${keyRange} or the ⊞ button`;
  const hintKbd = document.querySelectorAll('#hint-bar kbd')[1];
  if (hintKbd) hintKbd.textContent = keyRange;
  screenDefs.forEach((def, i) => {
    const card = document.createElement('div');
    card.className = 'screen-card';
    card.style.setProperty('--card-glow', def.glow);
    card.style.setProperty('--card-accent', def.accent);
    card.innerHTML = `
      <span class="key-hint">${i + 1}</span>
      <div class="icon">${def.icon}</div>
      <div class="name">${def.name}</div>
      <div class="tagline">${def.tagline}</div>`;
    card.addEventListener('click', async () => {
      hideOverlay();
      await onSwitch(def.id);
      if (!engine.isPlaying && engine.sourceMode !== 'none') {
        try { await engine.play(); } catch (e) { /* gesture required */ }
      }
      syncPlayBtn();
    });
    grid.appendChild(card);
  });

  function showOverlay() { overlay.classList.remove('hidden'); }
  function hideOverlay() { overlay.classList.add('hidden'); }
  $('screens-btn').addEventListener('click', showOverlay);
  overlay.addEventListener('click', (e) => { if (e.target === overlay) hideOverlay(); });

  // --- Play / pause ---
  function syncPlayBtn() {
    playBtn.textContent = `${playIcon()} ${engine.isPlaying ? 'Pause' : 'Play'}`;
  }
  playBtn.addEventListener('click', async () => {
    if (engine.sourceMode === 'none') { app.showToast('Load a track or enable the mic first'); return; }
    if (engine.isPlaying) engine.pause();
    else await engine.play();
    syncPlayBtn();
  });
  engine.addEventListener('trackloaded', (e) => {
    $('track-name').textContent = e.detail.name;
    app.showToast(`Loaded: ${e.detail.name}`);
  });
  engine.addEventListener('nosource', () => app.showToast('Load a track or enable the mic first'));
  engine.addEventListener('micerror', (e) => app.showToast(`Mic error: ${e.detail.message}`));
  engine.addEventListener('ended', () => syncPlayBtn());

  // --- Seek bar ---
  const seekbar = $('seekbar');
  seekbar.addEventListener('input', () => { seeking = true; });
  seekbar.addEventListener('change', () => {
    const t = (seekbar.value / 1000) * engine.duration;
    engine.seek(t);
    seeking = false;
  });

  setInterval(() => {
    if (seeking || !isFinite(engine.duration) || engine.duration <= 0) return;
    seekbar.value = String(Math.round((engine.currentTime / engine.duration) * 1000));
    $('time-cur').textContent = fmtTime(engine.currentTime);
    $('time-total').textContent = fmtTime(engine.duration);
  }, 250);

  // --- File loading ---
  const fileInput = $('audio-file');
  $('load-btn').addEventListener('click', () => fileInput.click());
  fileInput.addEventListener('change', async () => {
    const f = fileInput.files[0];
    if (!f) return;
    await engine.loadFile(f);
    $('source-select').value = 'file';
    await engine.play();
    syncPlayBtn();
    hideOverlay();
  });

  // --- Source select ---
  $('source-select').addEventListener('change', async (e) => {
    const mode = e.target.value;
    if (mode === 'mic') {
      const ok = await engine.enableMic();
      if (!ok) { e.target.value = engine.sourceMode === 'file' ? 'file' : 'none'; return; }
      app.showToast('Microphone live — play something!');
    } else if (mode === 'file') {
      if (!engine.audioEl || !engine.audioEl.src) { fileInput.click(); return; }
      await engine.useFileSource();
    } else {
      engine.pause();
    }
    syncPlayBtn();
  });

  // --- Fullscreen ---
  $('fs-btn').addEventListener('click', toggleFullscreen);

  // --- Drag & drop ---
  const drop = $('drop-overlay');
  let dragDepth = 0;
  window.addEventListener('dragenter', (e) => {
    e.preventDefault();
    dragDepth++;
    drop.classList.add('active');
  });
  window.addEventListener('dragleave', (e) => {
    e.preventDefault();
    dragDepth = Math.max(0, dragDepth - 1);
    if (dragDepth === 0) drop.classList.remove('active');
  });
  window.addEventListener('dragover', (e) => e.preventDefault());
  window.addEventListener('drop', async (e) => {
    e.preventDefault();
    dragDepth = 0;
    drop.classList.remove('active');
    const file = [...(e.dataTransfer?.files || [])].find((f) => f.type.startsWith('audio/') || /\.(mp3|wav|ogg|m4a|flac)$/i.test(f.name));
    if (!file) { app.showToast('That does not look like an audio file'); return; }
    await engine.loadFile(file);
    $('source-select').value = 'file';
    await engine.play();
    syncPlayBtn();
    hideOverlay();
  });

  // --- Keyboard shortcuts ---
  window.addEventListener('keydown', (e) => {
    if (e.target.tagName === 'INPUT' && e.target.type === 'file') return;
    if (KEY_TO_INDEX[e.key] !== undefined) {
      const def = screenDefs[KEY_TO_INDEX[e.key]];
      if (def) { onSwitch(def.id); hideOverlay(); }
    } else if (e.code === 'Space') {
      e.preventDefault();
      if (engine.sourceMode === 'none') { app.showToast('Load a track or enable the mic first'); return; }
      if (engine.isPlaying) engine.pause(); else engine.play();
      syncPlayBtn();
    } else if (e.key.toLowerCase() === 's') {
      overlay.classList.contains('hidden') ? showOverlay() : hideOverlay();
    } else if (e.key.toLowerCase() === 'f') {
      toggleFullscreen();
    }
  });

  function toggleFullscreen() {
    if (document.fullscreenElement) document.exitFullscreen();
    else document.documentElement.requestFullscreen();
  }

  // Auto-fade hint bar
  setTimeout(() => $('hint-bar').classList.add('fade'), 9000);
}
