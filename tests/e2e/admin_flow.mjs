// E2E del panel admin con token de DESARROLLO (FERROLAB_ENV=development).
// Uso: node tests/e2e/admin_flow.mjs <token> [baseUrl]
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const { chromium } = require('playwright');
const [token, BASE = 'http://127.0.0.1:8080'] = process.argv.slice(2);
const OUT = new URL('./screenshots/', import.meta.url).pathname;
const b = await chromium.launch();
const p = await b.newPage({ viewport: { width: 1280, height: 860 }, deviceScaleFactor: 2 });
let ok = 0, total = 0;
const check = (n, c) => { total++; if (c) ok++; console.log(`${c ? 'PASS' : 'FAIL'}  ${n}`); };
const body = async () => p.evaluate(() => document.body.innerText + [...document.querySelectorAll('[aria-label]')].map(e => e.getAttribute('aria-label')).join(' '));
await p.goto(BASE + '/#/admin'); await p.waitForTimeout(5000);
check('login admin visible (sin sesión no hay datos)', (await body()).includes('Token de desarrollo'));
const box = p.getByRole('textbox').last(); await box.focus(); await box.fill(token);
await p.getByRole('button', { name: 'Iniciar sesión' }).last().dispatchEvent('click'); await p.waitForTimeout(3000);
check('sesión con rol admin', (await body()).includes('Rol: admin'));
check('lista de borradores', (await body()).includes('aisi_1045'));
await p.screenshot({ path: OUT + 'admin-01-registros.png' });
// Destino «Publicaciones» del NavigationRail (posición fija en escritorio 1280 px).
const nav = p.locator('[aria-label*="Publicaciones"]').last();
const bb = (await nav.count()) ? await nav.boundingBox() : null;
await p.mouse.click(bb ? bb.x + bb.width / 2 : 48, bb ? bb.y + bb.height / 2 : 155);
await p.waitForTimeout(2500);
check('publicación dev activa listada', (await body()).includes('0.1.0-dev+unreviewed'));
await p.screenshot({ path: OUT + 'admin-02-publicaciones.png' });
console.log(`${ok}/${total} comprobaciones superadas`);
await b.close();
process.exit(ok === total ? 0 : 1);
