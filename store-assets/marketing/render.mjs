// Renders the captioned store frames into store-assets/marketing/out/.
//
//   cd store-assets/marketing && npm install && npm run render
//
// iPhone and iPad are rendered as one wide panorama and cut into frames, so
// the ribbon joins across neighbouring screenshots on the App Store. Android
// frames are rendered one by one: Google Play shows them with gaps, where a
// panorama would break.
import { createServer } from 'node:http';
import { readFile, mkdir } from 'node:fs/promises';
import { extname, join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';
import { FRAMES, DEVICES } from './frames.js';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..'); // store-assets/
const types = { '.html': 'text/html', '.js': 'text/javascript', '.jpg': 'image/jpeg', '.png': 'image/png' };

const server = createServer(async (req, res) => {
  try {
    const path = join(root, decodeURIComponent(new URL(req.url, 'http://x').pathname));
    if (!path.startsWith(root)) throw new Error('outside root');
    res.writeHead(200, { 'content-type': types[extname(path)] ?? 'application/octet-stream' });
    res.end(await readFile(path));
  } catch {
    res.writeHead(404).end();
  }
});
await new Promise((r) => server.listen(0, '127.0.0.1', r));
const base = `http://127.0.0.1:${server.address().port}/marketing/page.html`;

// CHROMIUM_PATH lets a machine reuse any cached Chromium build instead of the
// one this Playwright version would download.
const browser = await chromium.launch(
  process.env.CHROMIUM_PATH ? { executablePath: process.env.CHROMIUM_PATH } : {},
);
try {
  for (const [name, d] of Object.entries(DEVICES)) {
    const outDir = join(here, 'out', name);
    await mkdir(outDir, { recursive: true });
    const jobs = d.panorama
      ? [{ url: `${base}?device=${name}`, frames: FRAMES.map((_, i) => i) }]
      : FRAMES.map((_, i) => ({ url: `${base}?device=${name}&frame=${i}`, frames: [i] }));
    for (const job of jobs) {
      const page = await browser.newPage({
        viewport: { width: d.width * job.frames.length, height: d.height },
        deviceScaleFactor: 1,
      });
      await page.goto(job.url);
      await page.waitForSelector('body[data-ready="1"]', { timeout: 60_000 });
      for (const [slot, i] of job.frames.entries()) {
        const file = join(outDir, `${String(i + 1).padStart(2, '0')}-${FRAMES[i].shot.slice(3)}.jpg`);
        await page.screenshot({
          path: file, type: 'jpeg', quality: 92,
          clip: { x: slot * d.width, y: 0, width: d.width, height: d.height },
        });
        console.log(`${name}: ${file.slice(root.length + 1)}`);
      }
      await page.close();
    }
  }
} finally {
  await browser.close();
  server.close();
}
