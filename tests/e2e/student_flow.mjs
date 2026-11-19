// Prueba E2E del recorrido de estudiante sin cuenta (UX-01, doc 13).
// Requiere: API en :8000 y build web servido en :8080 (ver scripts/run_e2e.sh).
// Uso: node tests/e2e/student_flow.mjs [baseUrl]
import { createRequire } from 'node:module';
import { mkdirSync } from 'node:fs';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright');

const BASE = process.argv[2] ?? 'http://127.0.0.1:8080';
const OUT = new URL('./screenshots/', import.meta.url).pathname;
mkdirSync(OUT, { recursive: true });

const results = [];
function check(name, ok, detail = '') {
  results.push({ name, ok, detail });
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${detail ? ' — ' + detail : ''}`);
}

async function text(page) {
  return (await page.evaluate(() => {
    const parts = [];
    document.querySelectorAll('flt-semantics, [aria-label]').forEach((e) => {
      const l = e.getAttribute('aria-label');
      if (l) parts.push(l);
      if (e.textContent) parts.push(e.textContent);
    });
    return parts.join(' \n ');
  })) ?? '';
}

async function waitText(page, s, timeout = 15000) {
  const t0 = Date.now();
  while (Date.now() - t0 < timeout) {
    if ((await text(page)).includes(s)) return true;
    await page.waitForTimeout(250);
  }
  return false;
}

async function click(page, name) {
  const loc = page.getByRole('button', { name, exact: false }).first();
  await loc.waitFor({ timeout: 15000 });
  // Si la capa de semántica de un campo enfocado tapa el botón, se despacha el clic directamente.
  await loc.click({ timeout: 4000 }).catch(() => loc.dispatchEvent('click'));
  await page.waitForTimeout(500);
}

async function fill(page, label, value) {
  const box = page.getByRole('textbox', { name: label }).first();
  await box.waitFor({ timeout: 10000 });
  for (let attempt = 0; attempt < 3; attempt++) {
    await box.focus();
    await box.fill('');
    await box.pressSequentially(String(value), { delay: 40 });
    await page.waitForTimeout(400);
    if ((await box.inputValue()) === String(value)) break;
  }
  await page.waitForTimeout(300);
}

async function flow(viewport, tag) {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport, deviceScaleFactor: 2, locale: 'es-ES' });
  const page = await ctx.newPage();
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto(BASE);
  check(`${tag}: bienvenida sin cuenta`, await waitText(page, 'Gratis · Sin cuenta', 30000));
  await page.screenshot({ path: `${OUT}${tag}-01-bienvenida.png` });
  await click(page, 'Omitir introducción');
  check(`${tag}: inicio`, await waitText(page, 'Iniciar simulación'));
  await page.screenshot({ path: `${OUT}${tag}-02-inicio.png` });
  await click(page, 'Iniciar simulación');
  check(`${tag}: tres materiales`, (await waitText(page, 'ASTM A48 Clase 30')) && (await text(page)).includes('AISI 8620'));
  await click(page, 'AISI 1045');
  await page.screenshot({ path: `${OUT}${tag}-03-material.png` });
  await click(page, 'Continuar');
  check(`${tag}: seis tratamientos`, (await waitText(page, 'Martempering')) && (await text(page)).includes('Austempering'));
  const tt = await text(page);
  check(`${tag}: estados de compatibilidad visibles`, tt.includes('Condicional') && tt.includes('Compatible'));
  await click(page, 'Temple');
  await page.screenshot({ path: `${OUT}${tag}-04-tratamiento.png` });
  await click(page, 'Continuar');
  check(`${tag}: protocolo de referencia cargado`, await waitText(page, 'Protocolo de referencia cargado'));
  const pt = await text(page);
  check(`${tag}: biblioteca de protocolos + medio fijado`, pt.includes('Protocolos disponibles') &&
    pt.includes('fijado por el protocolo') && pt.includes('Temple en agua (voestalpine)'));
  check(`${tag}: secuencia térmica y fuentes`, pt.includes('Secuencia térmica') && pt.includes('Ficha científica del protocolo'));

  // 1) Temperatura extrema: debe bloquearse con motivo.
  await fill(page, 'Temperatura', 1600);
  await fill(page, 'Tiempo', 30);
  await click(page, 'Revisar configuración');
  check(`${tag}: 1600 °C bloqueado`, await waitText(page, 'No se puede ejecutar'));
  await page.screenshot({ path: `${OUT}${tag}-05-bloqueo-1600.png` });
  await click(page, 'Editar');

  // 2) Caso válido estructuralmente.
  await fill(page, 'Temperatura', 850);
  await page.screenshot({ path: `${OUT}${tag}-06-parametros.png` });
  await click(page, 'Revisar configuración');
  check(`${tag}: revisión honesta`, await waitText(page, 'ESTIMACIONES de modelos publicados'));
  await page.screenshot({ path: `${OUT}${tag}-07-revision.png` });
  await click(page, 'Iniciar laboratorio');
  check(`${tag}: horno con disclaimer`, await waitText(page, 'El color de la pieza es ilustrativo'));
  await page.waitForTimeout(3500);
  await page.screenshot({ path: `${OUT}${tag}-08-horno.png` });
  check(`${tag}: curva térmica física (modelo)`, !(await text(page)).includes('no a escala'));
  await click(page, 'Saltar al final');
  await click(page, 'Ver resultados');
  check(`${tag}: resultados`, await waitText(page, 'Esto podemos concluir'));
  const rt = await text(page);
  check(`${tag}: dureza estimada con HV, HRC y banda`, /\d+\s*HV/.test(rt) && /HRC/.test(rt) && rt.includes('Banda de incertidumbre') && !/\b0\s*HRC/.test(rt));
  check(`${tag}: cifras etiquetadas como estimación de modelo, sin avisos de revisión`,
    rt.includes('Estimación acotada') && rt.includes('Modelado') && rt.includes('Martensita')
    && !rt.includes('no revisada por un especialista') && !rt.includes('pendiente de revisión por un especialista'));
  check(`${tag}: microestructura generada + diagramas`, rt.includes('Microestructura generada') && rt.includes('Diagramas TTT y CCT'));
  check(`${tag}: tamaño de grano ASTM y propiedades mecánicas calculadas`,
    /G ASTM \d/.test(rt) && rt.includes('Grano austenítico previo') && rt.includes('Resistencia a tracción') && /\d+\s*MPa/.test(rt));
  check(`${tag}: micrografía real citada`, rt.includes('Micrografía real con licencia') && rt.includes('Wikimedia Commons'));
  await page.screenshot({ path: `${OUT}${tag}-09-resultados.png`, fullPage: true });
  await click(page, '¿Por qué ocurrió esto?');
  check(`${tag}: tutor en modo editorial (IA apagada)`, await waitText(page, 'Explicación editorial (sin IA)'));
  await page.screenshot({ path: `${OUT}${tag}-10-tutor.png` });
  check(`${tag}: sin errores JS`, errors.length === 0, errors.join(' | '));
  await browser.close();
}

await flow({ width: 1280, height: 860 }, 'desktop');
await flow({ width: 390, height: 844 }, 'movil');
const failed = results.filter((r) => !r.ok);
console.log(`\n${results.length - failed.length}/${results.length} comprobaciones superadas`);
process.exit(failed.length ? 1 : 0);
