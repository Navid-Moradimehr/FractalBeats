# 🌌 FractalBeats

**Real-time audio-reactive fractal visualizer with 4 switchable screens.** Load any music file (or use your microphone) and pick a fractal universe to fly through. Runs 100% in your browser — no install, no server.

**[Live Demo](https://navid-moradimehr.github.io/FractalBeats)**

## 🖥️ The Screens

Press `1`–`4` (or the ⊞ button) to switch anytime — the music keeps playing:

| # | Screen | What it does |
|---|--------|--------------|
| 1 | 🪐 **Mandelbulb Nebula** | Ray-marched 3D Mandelbulb with orbit-trap coloring, real lighting (specular/AO/fresnel) and ACES tonemapping. Structure breathes with beats; drag to orbit, wheel/pinch to zoom. ~14 sliders in folders. |
| 2 | 🕳️ **Fractal Tunnel** | One continuous fly-through of kali-set blossoms for the whole song — velocity follows a smoothed energy envelope, and your position survives screen switches. |
| 3 | 📊 **Spectrum Bloom** | Lightweight 2D radial spectrum with waveform ring and beat-triggered particle bursts — perfect for weak GPUs. |
| 4 | 🔮 **Kaleidoscope** | Mirror-symmetric kali mandala with a smoothed, capped spin rate that eases with the music. |

> 🌀 A fifth screen, **Julia Explorer** (Mandelbrot coordinate tours + Julia morphing), ships **disabled** — its code lives in `src/screens/julia.js`; re-enable it by uncommenting its import in `src/main.js`.

## 🎧 Audio Sources

- **File**: click 🎵 Load, or just **drag & drop** an audio file anywhere on the page (mp3/wav/ogg/m4a/flac)
- **Microphone**: pick *Source: Mic* — visualize Spotify, concerts, your voice, anything
- Full transport: play/pause, **seek bar**, track name, time display

## ⌨️ Shortcuts

| Key | Action |
|-----|--------|
| `Space` | Play / pause |
| `1`–`4` | Switch screen |
| `S` | Open/close the screen picker |
| `Esc` | Close the picker |
| `F` | Fullscreen |

**Touch (mobile):** swipe ←/→ to switch screens · swipe ↑ to open the picker · pull down from the top edge to refresh · ⚙ opens the settings drawer.

## 🎞️ Regenerating the screen previews

The looping clips on the landing page are generated automatically — no manual recording:

```bash
node tools/gen-demo-audio.js      # synthesize the demo track (tools/demo-track.wav)
node tools/record-previews.js     # drive the app in Chromium, record each screen (tools/raw/)
# then encode with ffmpeg:
# ffmpeg -i tools/raw/<id>.webm -t 3.0 -vf scale=480:270 -an -c:v libvpx-vp9 -b:v 350k assets/previews/<id>.webm
# ffmpeg -ss 1.6 -i tools/raw/<id>.webm -frames:v 1 -vf scale=480:270 -q:v 4 assets/previews/<id>.jpg
node tools/smoke-test.js          # end-to-end checks (desktop + mobile emulation)
```

## ✨ Features

- **Landing-page previews** — every screen card plays a short looping clip of the actual visualizer (`assets/previews/`, recorded automatically, see `tools/`)
- **Mobile support** — responsive touch layout (bottom-docked transport, safe-area aware), swipe ←/→ to switch screens, swipe ↑ for the picker, ⚙ settings drawer, pull-down from the top edge to refresh
- 7-band FFT analysis (sub-bass → air) with attack/release envelopes
- Multi-level spectral-flux **beat detection** with dynamic threshold
- **Runtime adaptive quality**: measures real FPS and scales render resolution to hold 60fps (no more one-time hardware guesses)
- Per-screen control panels (lil-gui) with reset
- High-DPI aware rendering
- Self-contained: Three.js + lil-gui vendored locally — works offline, no CDN dependency
- Zero build step — plain ES modules, served statically

## 🚀 Run Locally

```bash
git clone https://github.com/Navid-Moradimehr/FractalBeats.git
cd FractalBeats
python -m http.server 8000
# open http://localhost:8000
```

(Any static file server works. Opening `index.html` via `file://` will not work due to ES module + fetch restrictions.)

## 🧱 Architecture

```
index.html                  app shell: header, transport, screen-picker overlay
assets/previews/            looping preview clips + posters for the picker cards
src/
  main.js                   bootstrap, ScreenManager, render loop, adaptive quality
  audio-engine.js           file/mic sources, FFT bands, beat detection
  ui.js                     cards + previews, transport, drag&drop, shortcuts, touch gestures, toasts
  style.css
  screens/
    shader-screen.js        shared fullscreen-quad shader helper
    mandelbulb.js/.glsl
    julia.js/.glsl
    tunnel.js/.glsl
    kaleidoscope.js/.glsl (kaleido.glsl)
    spectrum.js             2D canvas screen
tools/                      preview-generation + smoke-test scripts (dev only)
vendor/                     vendored three.module.js + lil-gui (no CDN needed)
```

Every screen implements `{ create(ctx), update(dt, audio), render(), resize(), dispose() }` and is lazily initialized — only the active screen's shader is compiled. Adding a new screen = drop a module in `src/screens/`, register it in `main.js`, and a card appears automatically.

## 🌐 Hosting

Static hosting only (GitHub Pages works as-is). Microphone access requires HTTPS or `localhost`.

## License

MIT
