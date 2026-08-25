# 🌌 FractalBeats

**Real-time audio-reactive fractal visualizer with 5 switchable screens.** Load any music file (or use your microphone) and pick a fractal universe to fly through. Runs 100% in your browser — no install, no server.

**[Live Demo](https://navid-moradimehr.github.io/FractalBeats)**

## 🖥️ The Screens

Press `1`–`5` (or the ⊞ button) to switch anytime — the music keeps playing:

| # | Screen | What it does |
|---|--------|--------------|
| 1 | 🪐 **Mandelbulb Nebula** | Ray-marched 3D Mandelbulb with 19 tweakable audio-reactive parameters — the classic experience. |
| 2 | 🌀 **Julia Explorer** | Auto-tours through 7 famous Mandelbrot coordinates (Seahorse Valley, Elephant Valley…), or morphs a Julia set whose `c` orbits with the mids. Wheel-zoom and drag to explore manually. |
| 3 | 🕳️ **Fractal Tunnel** | Infinite fly-through of kali-set blossoms. Your tempo × energy sets the flight speed; beats fire light rings down the corridor. |
| 4 | 📊 **Spectrum Bloom** | Lightweight 2D radial spectrum with waveform ring and beat-triggered particle bursts — perfect for weak GPUs. |
| 5 | 🔮 **Kaleidoscope** | Mirror-symmetric kali mandala that reshapes with every beat. |

## 🎧 Audio Sources

- **File**: click 🎵 Load, or just **drag & drop** an audio file anywhere on the page (mp3/wav/ogg/m4a/flac)
- **Microphone**: pick *Source: Mic* — visualize Spotify, concerts, your voice, anything
- Full transport: play/pause, **seek bar**, track name, time display

## ⌨️ Shortcuts

| Key | Action |
|-----|--------|
| `Space` | Play / pause |
| `1`–`5` | Switch screen |
| `S` | Open/close the screen picker |
| `F` | Fullscreen |

## ✨ Features

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
src/
  main.js                   bootstrap, ScreenManager, render loop, adaptive quality
  audio-engine.js           file/mic sources, FFT bands, beat detection
  ui.js                     cards, transport, drag&drop, shortcuts, toasts
  style.css
  screens/
    shader-screen.js        shared fullscreen-quad shader helper
    mandelbulb.js/.glsl
    julia.js/.glsl
    tunnel.js/.glsl
    kaleidoscope.js/.glsl (kaleido.glsl)
    spectrum.js             2D canvas screen
vendor/                     vendored three.module.js + lil-gui (no CDN needed)
```

Every screen implements `{ create(ctx), update(dt, audio), render(), resize(), dispose() }` and is lazily initialized — only the active screen's shader is compiled. Adding a new screen = drop a module in `src/screens/`, register it in `main.js`, and a card appears automatically.

## 🌐 Hosting

Static hosting only (GitHub Pages works as-is). Microphone access requires HTTPS or `localhost`.

## License

MIT
