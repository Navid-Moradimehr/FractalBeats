import * as THREE from '../../vendor/three.module.js';
import { GUI } from '../../vendor/lil-gui.module.min.js';
import { createShaderScreen, addUniforms } from './shader-screen.js';

const TOUR = [
  { x: -0.5, y: 0.0, scale: 1.6 },
  { x: -0.7, y: 0.0, scale: 1.1 },
  { x: -0.74543, y: 0.11301, scale: 0.02 },
  { x: -0.16, y: 1.0405, scale: 0.03 },
  { x: -0.7269, y: 0.1889, scale: 0.008 },
  { x: 0.28693, y: 0.01449, scale: 0.0007 },
  { x: -0.748, y: 0.1, scale: 0.004 },
];

const SEGMENT_SECONDS = 16;

export default {
  id: 'julia',
  name: 'Julia Explorer',
  icon: '🌀',
  type: 'webgl',
  tagline: 'Fly through famous Mandelbrot coordinates or morph a musical Julia set.',
  glow: 'rgba(69,183,209,0.20)',
  accent: 'rgba(69,183,209,0.65)',

  async create(ctx) {
    const s = await createShaderScreen({ renderer: ctx.renderer, fragmentUrl: './src/screens/julia.glsl' });
    addUniforms(s, {
      u_time: 0,
      u_resolution: new THREE.Vector2(s.initialSize.width, s.initialSize.height),
      u_center: new THREE.Vector2(-0.5, 0),
      u_scale: 1.6,
      u_juliaMix: 0,
      u_juliaC: new THREE.Vector2(0.355, 0.355),
      u_maxIter: 160,
      u_palette: 0,
      u_saturation: 1.0,
      u_brightness: 1.0,
      u_bass: 0, u_mid: 0, u_high: 0, u_beat: 0,
    });

    const params = {
      mode: 'Mandelbrot Tour',
      autoTour: true,
      tourSpeed: 1.0,
      iterations: 160,
      palette: 0,
      saturation: 1.0,
      brightness: 1.0,
    };

    let time = 0;
    let tourPos = Math.random() * (TOUR.length - 1);
    let pulseScale = 1;
    let juliaAngle = Math.random() * Math.PI * 2;

    // --- Interaction: wheel zoom + drag pan (turns off auto tour) ---
    const canvas = ctx.renderer.domElement;
    let dragging = false;
    let lastX = 0, lastY = 0;
    function userTookControl() { params.autoTour = false; guiControllers.autoTour.updateDisplay(); }
    function onWheel(e) {
      e.preventDefault();
      const f = Math.exp(e.deltaY * 0.0012);
      params._scaleTarget = (params._scaleTarget || s.uniforms.u_scale.value) * f;
      userTookControl();
    }
    function onDown(e) { dragging = true; lastX = e.clientX; lastY = e.clientY; }
    function onMove(e) {
      if (!dragging) return;
      const rect = canvas.getBoundingClientRect();
      const sx = s.uniforms.u_scale.value * (e.clientX - lastX) / rect.height;
      const sy = s.uniforms.u_scale.value * (e.clientY - lastY) / rect.height;
      const c = s.uniforms.u_center.value;
      if (params.mode === 'Mandelbrot Tour') {
        c.x -= sx; c.y += sy;
        userTookControl();
      }
      lastX = e.clientX; lastY = e.clientY;
    }
    function onUp() { dragging = false; }
    canvas.addEventListener('wheel', onWheel, { passive: false });
    canvas.addEventListener('pointerdown', onDown);
    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);

    const gui = new GUI({ container: ctx.guiHost, title: '🌀 Julia Explorer' });
    const guiControllers = {};
    guiControllers.mode = gui.add(params, 'mode', ['Mandelbrot Tour', 'Julia Morph']).name('Mode');
    guiControllers.autoTour = gui.add(params, 'autoTour').name('Auto Tour');
    gui.add(params, 'tourSpeed', 0.25, 4, 0.25).name('Tour Speed');
    gui.add(params, 'iterations', 40, 600, 10).name('Iterations');
    gui.add(params, 'palette', 0, 3, 1).name('Palette');
    gui.add(params, 'saturation', 0, 2, 0.01).name('Saturation');
    gui.add(params, 'brightness', 0.4, 2, 0.01).name('Brightness');

    return {
      update(dt, audio) {
        time += dt;
        const u = s.uniforms;

        // Mode crossfade
        const targetMix = params.mode === 'Julia Morph' ? 1 : 0;
        u.u_juliaMix.value += (targetMix - u.u_juliaMix.value) * Math.min(1, dt * 3);
        const mix = u.u_juliaMix.value;

        // Center & zoom
        if (mix < 0.98 && params.autoTour) {
          tourPos = (tourPos + dt * (params.tourSpeed / SEGMENT_SECONDS)) % (TOUR.length - 1);
          const i = Math.floor(tourPos);
          const t = tourPos - i;
          const ease = t * t * (3 - 2 * t);
          const a = TOUR[i], b = TOUR[Math.min(i + 1, TOUR.length - 1)];
          u.u_center.value.set(
            a.x + (b.x - a.x) * ease,
            a.y + (b.y - a.y) * ease
          );
          const logS = Math.log(a.scale) + (Math.log(b.scale) - Math.log(a.scale)) * ease;
          params._baseScale = Math.exp(logS);
        } else if (mix < 0.98 && !params.autoTour) {
          params._baseScale = THREE.MathUtils.clamp(params._scaleTarget || params._baseScale || u.u_scale.value, 1e-6, 4);
        }

        // Bass-driven zoom pulse
        pulseScale += ((1 - audio.low * 0.22 - audio.beatIntensity * 0.06) - pulseScale) * Math.min(1, dt * 8);
        if (mix > 0.98) {
          // Julia morph: c orbits the unit-ish circle, wobble from mids/highs
          juliaAngle += dt * (0.15 + audio.mid * 0.9 + audio.energy * 0.4) * params.tourSpeed;
          const r = 0.7885 + Math.sin(time * 0.11) * 0.08;
          u.u_juliaC.value.set(
            r * Math.cos(juliaAngle),
            r * Math.sin(juliaAngle) + audio.high * 0.12
          );
          u.u_center.value.lerp(new THREE.Vector2(0, 0), Math.min(1, dt * 2));
          u.u_scale.value += ((params._baseScale || 1.6) * pulseScale - u.u_scale.value) * Math.min(1, dt * 4);
        } else {
          u.u_scale.value = (params._baseScale || u.u_scale.value) * pulseScale;
        }

        u.u_time.value = time;
        u.u_maxIter.value = params.iterations + audio.high * 120;
        u.u_palette.value = params.palette;
        u.u_saturation.value = params.saturation;
        u.u_brightness.value = params.brightness;
        u.u_bass.value = audio.low;
        u.u_mid.value = audio.mid;
        u.u_high.value = audio.high;
        u.u_beat.value = audio.beatIntensity;
      },
      render() { s.render(); },
      resize(w, h) { s.resize(w, h); },
      dispose() {
        canvas.removeEventListener('wheel', onWheel);
        canvas.removeEventListener('pointerdown', onDown);
        window.removeEventListener('pointermove', onMove);
        window.removeEventListener('pointerup', onUp);
        gui.destroy();
        s.dispose();
      },
    };
  },
};
