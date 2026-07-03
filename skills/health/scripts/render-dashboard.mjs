#!/usr/bin/env node
// Render a self-contained HTML dashboard from a /health history file.
// Usage: render-dashboard.mjs <repo-name> [output.html]
// Reads ~/.cache/agent-health/<repo-name>.jsonl (one JSON object per run).
// Entry schema: {ts, branch, score, categories: {name: score | {score, detail}}, issues?: [string]}
import { readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const repo = process.argv[2];
if (!repo) { console.error("usage: render-dashboard.mjs <repo-name> [output.html]"); process.exit(2); }
const src = join(homedir(), ".cache/agent-health", `${repo}.jsonl`);
const out = process.argv[3] ?? join(homedir(), ".cache/agent-health", `${repo}.html`);

const runs = readFileSync(src, "utf8").split("\n").filter(Boolean).map((l) => JSON.parse(l));
if (!runs.length) { console.error(`no runs in ${src}`); process.exit(1); }
const last = runs.at(-1);
const prev = runs.at(-2);

const catScore = (c) => (typeof c === "number" ? c : c.score);
const catDetail = (c) => (typeof c === "number" ? "" : (c.detail ?? ""));
const esc = (s) => String(s).replace(/[&<>"]/g, (m) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[m]));
const scoreColor = (s) => (s >= 7 ? "#7fb069" : s >= 4 ? "#e2a655" : "#d4645c");

// Composite trend as an SVG line chart.
const W = 640, H = 140, PAD = 18;
const xs = runs.map((_, i) => (runs.length === 1 ? W / 2 : PAD + (i * (W - 2 * PAD)) / (runs.length - 1)));
const ys = runs.map((r) => H - PAD - (r.score / 10) * (H - 2 * PAD));
const path = xs.map((x, i) => `${i ? "L" : "M"}${x.toFixed(1)},${ys[i].toFixed(1)}`).join(" ");
const dots = xs.map((x, i) =>
  `<circle cx="${x.toFixed(1)}" cy="${ys[i].toFixed(1)}" r="${i === runs.length - 1 ? 5 : 3}"
     fill="${i === runs.length - 1 ? "#e2a655" : "#5a6475"}"><title>${esc(runs[i].ts)} — ${runs[i].score}/10</title></circle>`).join("");
const grid = [0, 2.5, 5, 7.5, 10].map((v) => {
  const y = H - PAD - (v / 10) * (H - 2 * PAD);
  return `<line x1="${PAD}" y1="${y}" x2="${W - PAD}" y2="${y}" stroke="#252d3a" stroke-width="1"/>
          <text x="4" y="${y + 3}" fill="#5a6475" font-size="9">${v}</text>`;
}).join("");

const catRows = Object.entries(last.categories).map(([name, c]) => {
  const s = catScore(c);
  const d = prev?.categories?.[name] !== undefined ? s - catScore(prev.categories[name]) : null;
  const delta = d === null ? "" : d > 0 ? `<span class="up">▲ +${d}</span>` : d < 0 ? `<span class="down">▼ ${d}</span>` : `<span class="eq">=</span>`;
  return `<div class="cat">
    <code>${esc(name)}</code>
    <div class="bar"><i style="width:${s * 10}%;background:${scoreColor(s)}"></i></div>
    <b style="color:${scoreColor(s)}">${s}/10</b>
    <span class="detail">${esc(catDetail(c))}</span>
    ${delta}
  </div>`;
}).join("\n");

const issues = (last.issues ?? []).map((i, n) => `<li><b>${n + 1}.</b> ${esc(i)}</li>`).join("\n");
const compDelta = prev ? (last.score - prev.score).toFixed(1) : null;

const html = `<title>Health — ${esc(repo)}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="dark">
<style>
  :root { --bg:#12161e; --panel:#1a2130; --line:#2a3342; --ink:#e9e5d8; --mut:#939dae; --acc:#e2a655;
          --mono:ui-monospace,"Cascadia Code","SF Mono",Menlo,Consolas,monospace; }
  html,body { background:var(--bg) !important; }
  body { font-family:system-ui,sans-serif; color:var(--ink); margin:0; line-height:1.5; }
  .wrap { max-width:44rem; margin:0 auto; padding:2.5rem 1.25rem 4rem; }
  h1 { font:600 1.3rem var(--mono); margin:0; }
  h1 span { color:var(--acc); }
  .meta { color:var(--mut); font:.78rem var(--mono); margin:.4rem 0 0; }
  .score { display:flex; align-items:baseline; gap:.8rem; margin:1.6rem 0 .4rem; }
  .score b { font:700 3rem var(--mono); font-variant-numeric:tabular-nums; }
  .score .d { font:.85rem var(--mono); color:var(--mut); }
  .score .d.up { color:#7fb069; } .score .d.down { color:#d4645c; }
  svg { display:block; width:100%; height:auto; background:var(--panel); border:1px solid var(--line); border-radius:8px; }
  h2 { font:700 .78rem var(--mono); text-transform:uppercase; letter-spacing:.1em; color:var(--acc); margin:2rem 0 .8rem; }
  .cat { display:grid; grid-template-columns:9rem 1fr 3.2rem minmax(8rem,1.2fr) 3.5rem; gap:.9rem; align-items:center;
         padding:.5rem 0; border-top:1px solid var(--line); font-size:.85rem; }
  .cat code { font:.84rem var(--mono); }
  .bar { height:8px; background:#232b39; border-radius:4px; overflow:hidden; }
  .bar i { display:block; height:100%; border-radius:4px; }
  .cat b { font:600 .82rem var(--mono); text-align:right; }
  .detail { color:var(--mut); font-size:.78rem; }
  .up { color:#7fb069; font:.75rem var(--mono); } .down { color:#d4645c; font:.75rem var(--mono); }
  .eq { color:var(--mut); font:.75rem var(--mono); }
  ol,ul { margin:.6rem 0 0; padding:0; list-style:none; }
  li { padding:.45rem 0; border-top:1px solid var(--line); color:var(--mut); font-size:.87rem; }
  li b { color:var(--acc); font-family:var(--mono); margin-right:.4rem; }
</style>
<div class="wrap">
  <h1><span>${esc(repo)}</span> · code health</h1>
  <p class="meta">${runs.length} run(s) · branche ${esc(last.branch)} · dernier : ${esc(last.ts)}</p>
  <div class="score">
    <b style="color:${scoreColor(last.score)}">${last.score}<small style="font-size:1.1rem;color:var(--mut)">/10</small></b>
    ${compDelta !== null ? `<span class="d ${+compDelta > 0 ? "up" : +compDelta < 0 ? "down" : ""}">${+compDelta > 0 ? "▲ +" : +compDelta < 0 ? "▼ " : "= "}${Math.abs(+compDelta) ? compDelta : "stable"} vs run précédent</span>` : `<span class="d">baseline</span>`}
  </div>
  <svg viewBox="0 0 ${W} ${H}" role="img" aria-label="Évolution du score">${grid}
    <path d="${path}" fill="none" stroke="#e2a655" stroke-width="2"/>${dots}</svg>
  <h2>Catégories</h2>
  ${catRows}
  ${issues ? `<h2>À corriger en premier</h2><ol>${issues}</ol>` : ""}
</div>
`;
writeFileSync(out, html);
console.log(out);
