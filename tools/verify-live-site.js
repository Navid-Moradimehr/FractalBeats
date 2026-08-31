// Live-site verification: boot the deployed GitHub Pages app in headless
// Chromium and confirm it runs — picker cards + preview assets load, the
// mandelbulb screen boots its WebGL path without errors.
import { createRequire } from 'node:module';
import { join } from 'node:path';

const require = createRequire(import.meta.url);
const globalNpm = join(process.env.APPDATA || '', 'npm', 'node_modules');
const { chromium } = require(join(globalNpm, '@playwright/mcp/node_modules/playwright'));

const URL = process.argv[2] || 'https://navid-moradimehr.github.io/FractalBeats/';
const channels = ['chrome', 'msedge', undefined];
let browser = null;
for (const channel of channels) {
  try { browser = await chromium.launch({ headless: true, channel }); break; }
  catch { if (channel === undefined) throw new Error('no browser'); }
}
const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
page.setDefaultTimeout(20000);
const errors = [];
page.on('pageerror', (e) => errors.push(e.message));
page.on('console', (m) => { if (m.type() === 'error') errors.push('console: ' + m.text()); });

await page.goto(URL, { waitUntil: 'load' });
await page.waitForSelector('#picker-overlay:not(.hidden)');
await page.waitForTimeout(1200); // let preview videos kick in

const cards = await page.evaluate(() => {
  const c = document.querySelectorAll('.screen-card');
  const videos = [...document.querySelectorAll('.preview-video')];
  return {
    count: c.length,
    names: [...c].map((el) => el.textContent.trim().replace(/\s+/g, ' ').slice(0, 40)),
    videosWithPoster: videos.filter((v) => v.poster).length,
    videosWithSrc: videos.filter((v) => v.getAttribute('data-src')).length,
    readyStateOk: videos.filter((v) => v.readyState >= 1).length,
  };
});
console.log('cards:', cards.count, '| names:', cards.names);
console.log('previews: poster', cards.videosWithPoster, '/ src', cards.videosWithSrc, '/ metadata', cards.readyStateOk);

await page.click('.screen-card:nth-child(1)', { force: true }); // mandelbulb
await page.waitForTimeout(3000);
const boot = await page.evaluate(() => {
  const app = window.__fractalApp;
  const cv = document.getElementById('c');
  const r = cv.getBoundingClientRect();
  return {
    app: !!app,
    screen: app && app.currentDef ? app.currentDef.id : null,
    webgl: !!app && !!app.renderer,
    canvasVisible: getComputedStyle(cv).display !== 'none',
    size: `${r.width | 0}x${r.height | 0}`,
    uniforms: app && app.current && app.current.uniforms ? Object.keys(app.current.uniforms).length : 0,
  };
});
console.log('boot:', JSON.stringify(boot));
console.log('pageerrors/console errors:', errors.length ? errors : 'none');
const ok = !errors.length && cards.count === 4 && boot.app && boot.screen === 'mandelbulb' && boot.webgl && boot.canvasVisible && boot.size.startsWith('1280');
console.log(ok ? 'LIVE CHECK PASSED' : 'LIVE CHECK FAILED');
await browser.close();
process.exit(ok ? 0 : 1);