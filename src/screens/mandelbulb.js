import * as THREE from '../../vendor/three.module.js';
import { GUI } from '../../vendor/lil-gui.module.min.js';
import { createShaderScreen, addUniforms } from './shader-screen.js';

const defaults = {
  u_intensity: 1.0,
  u_power: 8.0,
  u_hueShift: 0.0,
  u_shapeMod: 0.5,
  u_distortion: 0.3,
  u_rotationSpeed: 0.5,
  u_chaos: 0.4,
  u_morphing: 0.6,
  u_frequencyResponse: 0.8,
  u_shapeRegen: 0.6,
  u_beatSync: 0.8,
  u_structureChange: 0.5,
  u_breathing: 0.3,
  u_pulse: 0.4,
  u_movementLimit: 0.5,
  u_sizeControl: 0.8,
  u_colorPalette: 0.0,
  u_saturation: 1.0,
  u_brightness: 1.0,
};

const ranges = {
  u_power: [2.0, 12.0, 0.1],
  u_colorPalette: [0, 3, 1],
};

const perfDefaults = {
  u_adaptiveMaxSteps: 300,
  u_adaptiveMaxIterations: 22,
};

const perfRanges = {
  u_adaptiveMaxSteps: [50, 500, 10],
  u_adaptiveMaxIterations: [6, 40, 1],
};

export default {
  id: 'mandelbulb',
  name: 'Mandelbulb Nebula',
  icon: '🪐',
  type: 'webgl',
  tagline: 'The classic — a ray-marched 3D fractal that breathes with your music.',
  glow: 'rgba(78,205,196,0.20)',
  accent: 'rgba(78,205,196,0.65)',

  async create(ctx) {
    const s = await createShaderScreen({ renderer: ctx.renderer, fragmentUrl: './src/screens/mandelbulb.glsl' });
    addUniforms(s, {
      ...defaults,
      ...perfDefaults,
      u_time: 0,
      u_resolution: new THREE.Vector2(s.initialSize.width, s.initialSize.height),
      u_audioLow: 0, u_audioMid: 0, u_audioHigh: 0,
      u_audioSubBass: 0, u_audioBass: 0, u_audioLowMid: 0, u_audioMidRange: 0,
      u_audioUpperMid: 0, u_audioHighFreq: 0, u_audioAir: 0,
      u_beatIntensity: 0, u_energy: 0,
      u_superSamplingFactor: 1.0,
    });

    const params = { ...defaults };
    let time = Math.random() * 100;

    const gui = new GUI({ container: ctx.guiHost, title: '🪐 Mandelbulb' });
    const controllers = {};
    for (const key of Object.keys(defaults)) {
      const name = key.replace('u_', '');
      const range = ranges[key] || [0, 3, 0.01];
      controllers[key] = gui.add(params, key, ...range).name(name);
    }
    const perf = { ...perfDefaults };
    for (const key of Object.keys(perfDefaults)) {
      controllers[key] = gui.add(perf, key, ...perfRanges[key]).name(key.replace('u_', ''));
    }
    gui.add({
      reset: () => {
        Object.assign(params, defaults);
        Object.assign(perf, perfDefaults);
        for (const [key, val] of Object.entries({ ...defaults, ...perfDefaults })) {
          s.uniforms[key].value = val;
          if (controllers[key]) controllers[key].updateDisplay();
        }
      },
    }, 'reset').name('🔄 RESET ALL');

    return {
      update(dt, audio) {
        time += dt;
        const u = s.uniforms;
        for (const key of Object.keys(defaults)) u[key].value = params[key];
        for (const key of Object.keys(perfDefaults)) u[key].value = perf[key];
        u.u_time.value = time;
        u.u_audioLow.value = audio.low;
        u.u_audioMid.value = audio.mid;
        u.u_audioHigh.value = audio.high;
        u.u_audioSubBass.value = audio.bands.subBass;
        u.u_audioBass.value = audio.bands.bass;
        u.u_audioLowMid.value = audio.bands.lowMid;
        u.u_audioMidRange.value = audio.bands.midRange;
        u.u_audioUpperMid.value = audio.bands.upperMid;
        u.u_audioHighFreq.value = audio.bands.highFreq;
        u.u_audioAir.value = audio.bands.air;
        u.u_beatIntensity.value = audio.beatIntensity;
        u.u_energy.value = audio.energy;
      },
      render() { s.render(); },
      resize(w, h) { s.resize(w, h); },
      dispose() { gui.destroy(); s.dispose(); },
    };
  },
};
