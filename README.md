# Cosmic Neon Mandelbulb Visualizer (P1 — Hypnotic Pulse)

A browser-based, GPU-accelerated fractal music visualizer using **Three.js** + **WebGL ray-marching**.

---

## 💽 How to Run
1. Put `index.html` and `shader.glsl` in the same folder.  
2. Start a local server:  
   ```bash
   python3 -m http.server 8000
   ```

3. Visit **[http://localhost:8000](http://localhost:8000)** in Chrome/Edge/Firefox.
4. Upload an `.mp3` / `.wav`.
5. Watch the fractal pulse to the beat.

---

## 🎛 Controls

| Slider        | Function                                               |
| ------------- | ------------------------------------------------------ |
| **Intensity** | Multiplies final color brightness.                     |
| **Power**     | Changes Mandelbulb iteration power (shape complexity). |
| **HueShift**  | Shifts global hue (color rotation).                    |

---

## 🎧 Audio Mapping

| Audio Band | Used for    | Visual Effect                                    |
| ---------- | ----------- | ------------------------------------------------ |
| **Bass**   | u_audioLow  | Camera pulse + FOV modulation + tunnel breathing |
| **Mid**    | u_audioMid  | Color saturation + brightness                    |
| **High**   | u_audioHigh | Surface shimmer / highlights                     |

---

## ⚙️ Performance Tuning

If frame-rate drops:

* Reduce **MAX_STEPS** in `shader.glsl` from 150 → 100.
* Lower window size or browser zoom.
* Reduce `u_power` or `u_intensity`.

Your RTX 4070 should easily maintain 60 FPS.

---

## 🌌 Project Structure

```
/project
 ├─ index.html     # Three.js + audio analyzer + uniforms
 ├─ shader.glsl    # Fragment shader (Mandelbulb)
 └─ README.md
```

---

## 🔮 Next Phases

* **P2** → Add bloom + god-rays + chromatic aberration
* **P3** → Beat-synced camera cuts + fog + particles
* **P4** → AI-driven color themes + RAG music embedding
