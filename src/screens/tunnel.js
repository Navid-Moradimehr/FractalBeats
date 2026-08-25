import * as THREE from '../../vendor/three.module.js';
import { GUI } from '../../vendor/lil-gui.module.min.js';
import { createShaderScreen, addUniforms } from './shader-screen.js';

const TEMPO_BPM = 107.7;

export default {
  id: 'tunnel',
  name: 'Fractal Tunnel',
  icon: '🕳️',
  type: 'webgl',
  tagline: 'Infinite fly-through — the beat drives your speed through a kali tunnel.',
  glow: 'rgba(150,206,180,0.20)',
  accent: 'rgba(150,206,180,0.65)',

  async create(ctx) {
    const s = await createShaderScreen({ renderer: ctx.renderer, fragmentUrl: './src/screens/tunnel.glsl' });
    addUniforms(s, {
      u_time: 0,
      u_resolution: new THREE.Vector2(s.initialSize.width, s.initialSize.height),
      u_camZ: Math.random() * 100,
      u_bass: 0, u_mid: 0, u_high: 0, u_beat: 0,
      u_warp: 1.0,
      u_iterations: 7,
      u_palette: 0,
      u_brightness: 1.15,
    });

    const params = {
      baseSpeed: 1.0,
      warp: 1.0,
      iterations: 7,
      palette: 0,
      brightness: 1.15,
    };

    let time = Math.random() * 100;
    let camZ = s.uniforms.u_camZ.value;

    const gui = new GUI({ container: ctx.guiHost, title: '🕳️ Fractal Tunnel' });
    gui.add(params, 'baseSpeed', 0.2, 4, 0.05).name('Base Speed');
    gui.add(params, 'warp', 0.4, 1.6, 0.01).name('Warp');
    gui.add(params, 'iterations', 3, 10, 1).name('Iterations');
    gui.add(params, 'palette', 0, 3, 1).name('Palette');
    gui.add(params, 'brightness', 0.4, 2.5, 0.01).name('Brightness');

    return {
      update(dt, audio) {
        time += dt;
        // Camera velocity = tempo × musical energy; beats give a kick.
        const tempoFactor = (TEMPO_BPM / 60) * 0.12;
        camZ += dt * params.baseSpeed * tempoFactor * (0.6 + audio.energy * 2.4 + audio.beatIntensity * 1.2);

        const u = s.uniforms;
        u.u_time.value = time;
        u.u_camZ.value = camZ;
        u.u_bass.value = audio.low;
        u.u_mid.value = audio.mid;
        u.u_high.value = audio.high;
        u.u_beat.value = audio.beatIntensity;
        u.u_warp.value = params.warp;
        u.u_iterations.value = params.iterations;
        u.u_palette.value = params.palette;
        u.u_brightness.value = params.brightness * (0.85 + audio.energy * 0.5);
      },
      render() { s.render(); },
      resize(w, h) { s.resize(w, h); },
      dispose() { gui.destroy(); s.dispose(); },
    };
  },
};
