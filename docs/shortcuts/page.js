/* Shortcut cheatsheet: renders data.json (written by ~/dotfiles/bin/gen-shortcuts)
   into sections before the runtime builds the TOC, then wires the live filter.
   Classic script; runs at the end of <body>, before DOMContentLoaded. */
(function () {
  "use strict";
  const data = JSON.parse(document.getElementById("data").textContent);
  const mk = (tag, cls, text) => { const n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; return n; };
  const keyString = (keys) => keys.map((s) => s.join(" + ")).join(" → ");

  // Words people type for the symbols, so "cmd shift u" finds ⇧ + ⌘ + U.
  const SYN = { "⌘": "cmd command", "⌥": "opt option alt", "⌃": "ctrl control", "⇧": "shift", "↵": "enter return", "⌫": "backspace delete", "Right ⌘": "hyper rcmd", "Right ⌥": "ropt", "Esc": "escape" };
  const synonyms = (keys) => keys.flat().map((k) => SYN[k] || "").join(" ");

  function renderKeys(keys, alias) {
    const box = mk("div", "sc-keys");
    const one = (seq) => seq.forEach((step, i) => {
      if (i) box.append(mk("span", "op", "→"));
      step.forEach((k, j) => { if (j) box.append(mk("span", "op", "+")); box.append(mk("kbd", null, k)); });
    });
    if (!keys.length) box.append(mk("span", "none", "type it in Raycast"));
    else one(keys);
    (alias || []).forEach((a) => { box.append(mk("span", "or", "or")); one(a); });
    return box;
  }

  function renderAction(r) {
    const d = mk("div", "sc-act", r.action);
    if (r.clash) { d.append(" "); d.append(mk("span", "tag warn", "same key twice")); }
    if (r.manual) { d.append(" "); d.append(mk("span", "tag", "hand-copied")); }
    if (r.detail) d.append(mk("small", null, r.detail));
    return d;
  }

  // ---------- numbers for the TL;DR and meta (all computed from data.json) ----------
  const secs = data.sections;
  const all = secs.flatMap((s) => s.rows.map((r) => ({ r, s })));
  const total = all.length;
  const manualRows = all.filter(({ r }) => r.manual).length;
  const byId = Object.fromEntries(secs.map((s) => [s.id, s]));
  const layerGroups = new Set((byId["k-layers"]?.rows || []).map((r) => r.group));
  const appSecs = secs.filter((s) => s.id.startsWith("k-app-"));
  const files = new Set(secs.map((s) => s.source)).size;

  const gen = new Date(data.generated);
  const genText = gen.toISOString().slice(0, 16).replace("T", " ") + " UTC";
  const meta = document.getElementById("meta");
  [`${total} shortcuts`, `${secs.length} sections`, `${data.sources.length} sources`, `generated ${genText}`].forEach((t) => meta.append(mk("span", null, t)));
  document.getElementById("gen").textContent = genText + (data.warnings.length ? ` · ${data.warnings.length} generator warning(s)` : "");

  const tldr = document.getElementById("tldr");
  const li = (html) => { const n = mk("li"); n.innerHTML = html; tldr.append(n); };
  li(`<strong>${total} shortcuts</strong> in ${secs.length} sections, read from ${files} config files. ${total - manualRows} are extracted automatically; ${manualRows} (the Crux palette's in-palette keys) are hand-copied into <code>manual.json</code>.`);
  li(`<strong>Right ⌘ is Hyper.</strong> It carries ${byId["k-global"]?.rows.length || 0} one-key actions in every app and ${layerGroups.size} sublayers holding ${byId["k-layers"]?.rows.length || 0} more.`);
  li(`<strong>${appSecs.length} apps rebind keys when frontmost:</strong> ${appSecs.map((s) => `${s.id.replace("k-app-", "").replace(/^./, (c) => c.toUpperCase())} ${s.rows.length}`).join(", ")}.`);

  // ---------- most used ----------
  const topList = document.getElementById("topList");
  document.getElementById("topHead").textContent = `${data.mostUsed.length} keys do most of the daily work.`;
  data.mostUsed.forEach((t) => {
    const s = byId[t.section];
    const c = mk("a", "card");
    c.href = "#" + t.section;
    c.style.textDecoration = "none";
    c.style.color = "inherit";
    c.append(renderKeys(t.keys));
    c.append(mk("div", null, t.action));
    c.append(mk("div", "where", s ? s.family + " · " + s.id.replace(/^k-app-/, "").replace(/^k-/, "") : t.section));
    c.dataset.hay = (keyString(t.keys) + " " + synonyms(t.keys) + " " + t.action).toLowerCase();
    topList.append(c);
  });

  // ---------- sections ----------
  const foot = document.querySelector("footer.foot");
  const rowsEls = [];
  secs.forEach((s) => {
    const sec = mk("section");
    sec.id = s.id;
    const eb = mk("div", "eyebrow");
    eb.append(mk("span", "id", String(s.rows.length)), mk("span", null, s.family));
    const h2 = mk("h2", null, s.title);
    sec.append(eb, h2);
    if (s.lede) sec.append(mk("p", "section-lede", s.lede));
    const list = mk("div", "sc-list wide");
    let group = null, groupEl = null;
    s.rows.forEach((r) => {
      if (r.group && r.group !== group) {
        group = r.group;
        groupEl = mk("div", "sc-group label", group);
        list.append(groupEl);
      }
      const row = mk("div", "sc-row");
      row.append(renderKeys(r.keys, r.alias), renderAction(r));
      const keysAll = [r.keys, ...(r.alias || [])];
      row.dataset.hay = [keysAll.map(keyString).join(" | "), keysAll.map(synonyms).join(" "), r.action, r.detail || "", r.group || "", s.title, s.family].join(" ").toLowerCase();
      row.dataset.keys = keysAll.map(keyString).join(" | ").toLowerCase();
      row.dataset.id = r.id;
      list.append(row);
      rowsEls.push({ row, sec, groupEl });
    });
    sec.append(list);
    const src = mk("p", "sc-src");
    src.append("Source: ");
    src.append(mk("code", null, s.source));
    src.append(` · ${s.mode === "auto" ? "auto-extracted" : s.mode === "mixed" ? "partly auto-extracted, partly manual.json" : "hand-maintained"}`);
    sec.append(src);
    foot.before(sec);
  });

  // ---------- live filter ----------
  const q = document.getElementById("q");
  const count = document.getElementById("count");
  const topSec = document.getElementById("top");
  const norm = (v) => v.toLowerCase().replace(/\s+/g, " ").trim();
  function apply() {
    const query = norm(q.value);
    let shown = 0;
    if (!query) {
      rowsEls.forEach(({ row }) => row.classList.remove("sc-hide"));
      document.querySelectorAll(".sc-group, .page > section").forEach((n) => n.classList.remove("sc-hide"));
      count.textContent = `${total} shortcuts · press / to search`;
      return;
    }
    // A query that reads as a key ("right ⌘ + o") matches whole key strings first;
    // otherwise every word must appear somewhere in the row.
    const phrase = rowsEls.some(({ row }) => row.dataset.keys.includes(query));
    const words = query.split(" ").filter((w) => w && w !== "+" && w !== "→");
    const hit = (hay, keys) => (phrase ? keys.includes(query) : words.every((w) => hay.includes(w)));
    const groupsOn = new Set(), secsOn = new Set();
    rowsEls.forEach(({ row, sec, groupEl }) => {
      const on = hit(row.dataset.hay, row.dataset.keys);
      row.classList.toggle("sc-hide", !on);
      if (on) { shown++; secsOn.add(sec); if (groupEl) groupsOn.add(groupEl); }
    });
    rowsEls.forEach(({ sec, groupEl }) => {
      sec.classList.toggle("sc-hide", !secsOn.has(sec));
      if (groupEl) groupEl.classList.toggle("sc-hide", !groupsOn.has(groupEl));
    });
    topSec.classList.add("sc-hide");
    count.textContent = `${shown} of ${total} shortcuts match`;
  }
  q.addEventListener("input", apply);
  q.addEventListener("keydown", (e) => { if (e.key === "Escape") { q.value = ""; apply(); q.blur(); } });
  document.addEventListener("keydown", (e) => {
    if (e.key === "/" && document.activeElement !== q && !e.metaKey && !e.ctrlKey) { e.preventDefault(); q.focus(); q.select(); }
  });
  apply();

  /* ======================= interactive keyboard ======================= */
  const rowById = {};
  secs.forEach((sec) => sec.rows.forEach((r) => (rowById[r.id] = { r, sec })));
  const layers = data.layers || [];
  const layerById = Object.fromEntries(layers.map((l) => [l.id, l]));
  const CAT = {
    app: ["var(--s2)", "Open app"], web: ["var(--s6)", "Open URL / profile"], raycast: ["var(--s3)", "Raycast"], crux: ["var(--s4)", "Crux"],
    nav: ["var(--s1)", "Navigation"], term: ["var(--s5)", "Terminal / tmux"], other: ["var(--ink-3)", "Other"], door: ["var(--accent)", "Sublayer door"],
  };
  // Physical Mac US ANSI layout. w is in quarter-units (a 1u key spans 4 of 58 columns).
  const K = (code, lg, w = 4) => ({ code, lg, w });
  const letters = (s) => s.split("").map((c) => K(/[A-Z]/.test(c) ? "Key" + c : c, c));
  const sym = { "`": "Backquote", "-": "Minus", "=": "Equal", "[": "BracketLeft", "]": "BracketRight", "\\": "Backslash", ";": "Semicolon", "'": "Quote", ",": "Comma", ".": "Period", "/": "Slash" };
  const S = (c) => K(sym[c], c);
  const ROWS = [
    { fn: true, keys: [K("Escape", "esc", 6), ...Array.from({ length: 12 }, (_, i) => K("F" + (i + 1), "F" + (i + 1))), K("", "⏻", 4)] },
    { keys: [S("`"), ...Array.from({ length: 9 }, (_, i) => K("Digit" + (i + 1), String(i + 1))), K("Digit0", "0"), S("-"), S("="), K("Backspace", "⌫ delete", 6)] },
    { keys: [K("Tab", "⇥ tab", 6), ...letters("QWERTYUIOP"), S("["), S("]"), S("\\")] },
    { keys: [K("CapsLock", "⇪ caps", 7), ...letters("ASDFGHJKL"), S(";"), S("'"), K("Enter", "⏎ return", 7)] },
    { keys: [K("ShiftLeft", "⇧ shift", 9), ...letters("ZXCVBNM"), S(","), S("."), S("/"), K("ShiftRight", "⇧ shift", 9)] },
    { keys: [K("Fn", "fn"), K("ControlLeft", "⌃ control"), K("AltLeft", "⌥ option"), K("MetaLeft", "⌘ command", 5), K("Space", "", 20),
             K("MetaRight", "⌘ right", 5), K("AltRight", "⌥ option"), { arrows: true, w: 12 }] },
  ];
  const ARROWS = [["ArrowUp", "▲", "2 / 2"], ["ArrowLeft", "◀", "2 / 1"], ["ArrowDown", "▼", "2 / 2"], ["ArrowRight", "▶", "2 / 3"]];
  const LEG = {}; // code -> legend, for the panel
  ROWS.forEach((r) => r.keys.forEach((k) => k.code && (LEG[k.code] = k.lg)));
  ARROWS.forEach(([c, l]) => (LEG[c] = l));
  LEG.Space = "space";

  let cur = "hyper", shiftOn = false, shiftLatch = false, selCode = null, hoverCode = null, prevLayer = null, rightCmd = false;
  const keyEls = {};
  const panel = mk("div", "kb-panel");
  const chips = mk("div", "kb-chips");
  const legend = mk("div", "kb-legend");

  function entriesFor(L, code, shift) { return L.entries.filter((e) => e.code === code && !!e.shift === shift); }
  function entryAction(e) { return e.action || (e.row && rowById[e.row] ? rowById[e.row].r.action : e.door ? layerById[e.door].label : ""); }

  function buildKeyboard() {
    const kb = mk("div", "kb");
    kb.setAttribute("role", "group");
    kb.setAttribute("aria-label", "Keyboard");
    ROWS.forEach((row) => {
      const r = mk("div", "kb-row" + (row.fn ? " fn" : ""));
      row.keys.forEach((k) => {
        if (k.arrows) {
          const box = mk("div", "kb-arrows");
          box.style.setProperty("--w", k.w);
          ARROWS.forEach(([code, lg, area], i) => {
            const b = keyButton(code, lg);
            b.style.gridRow = i === 0 ? "1" : "2";
            b.style.gridColumn = area.split(" / ")[1];
            box.append(b);
          });
          r.append(box);
          return;
        }
        const b = keyButton(k.code, k.lg);
        b.style.setProperty("--w", k.w);
        r.append(b);
      });
      kb.append(r);
    });
    const scroll = mk("div", "kb-scroll");
    scroll.append(kb);
    return scroll;
  }
  function keyButton(code, lg) {
    const b = mk("button", "key");
    b.type = "button";
    b.append(mk("span", "lg", lg), mk("span", "sh", ""));
    if (code === "MetaRight") b.classList.add("hyper");
    if (code) {
      keyEls[code] = b;
      b.dataset.code = code;
      b.addEventListener("mouseenter", () => { hoverCode = code; paintPanel(); });
      b.addEventListener("mouseleave", () => { hoverCode = null; paintPanel(); });
      b.addEventListener("focus", () => { hoverCode = code; paintPanel(); });
      b.addEventListener("blur", () => { hoverCode = null; paintPanel(); });
      b.addEventListener("click", () => clickKey(code));
    }
    return b;
  }

  function buildChips() {
    chips.replaceChildren();
    const group = (label) => { const g = mk("div", "kb-cg"); g.append(mk("span", "kb-gl", label)); chips.append(g); return g; };
    const seg = (g) => { const b = mk("span", "kb-seg"); g.append(b); return b; };
    const chip = (L, text) => {
      const c = mk("button", "kb-chip", text || L.label);
      c.type = "button";
      c.dataset.layer = L.id;
      c.title = `${L.holdLabel} · ${new Set(L.entries.map((e) => e.code + e.shift)).size} keys`;
      c.addEventListener("click", () => setLayer(L.id));
      return c;
    };
    const g1 = seg(group("Global"));
    layers.filter((l) => l.group === "Global").forEach((L) => g1.append(chip(L)));
    const g2 = group("Apps");
    const apps = [...new Set(layers.filter((l) => l.group === "Apps").map((l) => l.app))];
    apps.forEach((app) => {
      const box = seg(g2);
      layers.filter((l) => l.app === app).sort((a, b) => a.id.length - b.id.length)
        .forEach((L) => box.append(chip(L, L.id === "app-" + app.toLowerCase() ? app : L.label.replace(app + " ", ""))));
    });
    const g3 = seg(group("Sublayers"));
    layers.filter((l) => l.group === "Sublayers").forEach((L) => g3.append(chip(L, L.label.replace("→ ", ""))));
    const g4g = group("Other");
    const g4 = seg(g4g);
    layers.filter((l) => l.group === "Other").forEach((L) => g4.append(chip(L)));
    const sh = mk("button", "kb-chip solo", "⇧ Shift");
    sh.type = "button";
    sh.id = "kbShift";
    sh.title = "Show Shift variants (or hold Shift)";
    sh.setAttribute("aria-pressed", "false");
    sh.addEventListener("click", () => { shiftLatch = !shiftLatch; shiftOn = shiftLatch; paint(); });
    g4g.append(sh);
  }

  function setLayer(id) {
    if (!layerById[id]) return;
    cur = id;
    selCode = null;
    paint();
  }

  function paint() {
    const L = layerById[cur];
    chips.querySelectorAll(".kb-chip[data-layer]").forEach((c) => c.classList.toggle("on", c.dataset.layer === cur));
    const sh = document.getElementById("kbShift");
    if (sh) { sh.classList.toggle("on", shiftOn); sh.setAttribute("aria-pressed", String(shiftOn)); }
    for (const [code, b] of Object.entries(keyEls)) {
      const list = entriesFor(L, code, shiftOn);
      const e = list[0];
      b.classList.toggle("on", !!e);
      b.classList.toggle("door", !!e?.door);
      b.classList.toggle("held", L.hold.includes(code) || (shiftOn && /^Shift/.test(code)));
      b.classList.toggle("sel", code === selCode);
      b.querySelector(".more")?.remove();
      b.querySelector(".dot")?.remove();
      const sh2 = b.querySelector(".sh");
      sh2.textContent = e ? e.short : code === "MetaRight" ? "Hyper" : "";
      if (list.length > 1) b.append(mk("span", "more", "+" + (list.length - 1)));
      else if (e && !e.door) b.append(mk("span", "dot"));
      b.style.setProperty("--c", e ? (CAT[e.cat] || CAT.other)[0] : "");
      b.tabIndex = e ? 0 : -1;
      const lg = LEG[code] || code;
      b.setAttribute("aria-label", e ? `${lg}: ${entryAction(e)}${e.door ? " (opens layer)" : ""}` : code === "MetaRight" ? "Right command: Hyper" : `${lg}: not bound in this layer`);
    }
    const used = new Set(L.entries.filter((e) => !!e.shift === shiftOn).map((e) => e.cat));
    legend.replaceChildren(...Object.entries(CAT).filter(([k]) => used.has(k)).map(([k, [tok, label]]) => {
      const s = mk("span", k === "door" ? "door" : null, label);
      s.style.setProperty("--c", tok);
      return s;
    }));
    paintPanel();
  }

  function kbdChain(keys) {
    const box = mk("div", "sc-keys");
    keys.forEach((step, i) => {
      if (i) box.append(mk("span", "op", "→"));
      step.forEach((k, j) => { if (j) box.append(mk("span", "op", "+")); box.append(mk("kbd", null, k)); });
    });
    return box;
  }
  function describe(e, L, first) {
    const wrap = mk("div", first ? null : "alt");
    const hit = e.row && rowById[e.row];
    if (hit) wrap.append(kbdChain(hit.r.keys));
    wrap.append(mk("h3", null, entryAction(e)));
    const dl = mk("dl");
    const add = (k, v, cls) => { if (!v) return; dl.append(mk("dt", null, k)); dl.append(mk("dd", cls || null, v)); };
    const kind = mk("span", "kpill", (CAT[e.cat] || CAT.other)[1]);
    kind.style.setProperty("--c", (CAT[e.cat] || CAT.other)[0]);
    dl.append(mk("dt", null, "Kind")); const kd = mk("dd"); kd.append(kind); dl.append(kd);
    add("Scope", e.scope ? `${e.scope} only` : L.app ? "All apps (global Hyper)" : L.group === "Sublayers" || L.id === "hyper" ? "All apps" : L.label);
    if (e.door) add("Opens", `${layerById[e.door].label.replace("→ ", "Layer ")}: ${layerById[e.door].entries.length} keys`);
    if (hit?.r.detail) add("Note", hit.r.detail);
    if (e.overridden) add("Conflict", `Replaced in ${e.overridden} by “${entryAction(L.entries.find((x) => x.code === e.code && !!x.shift === !!e.shift && x.scope === e.overridden) || {})}”`, "warnline");
    if (e.overrides && rowById[e.overrides]) add("Overrides", `Global: ${rowById[e.overrides].r.action}`, "warnline");
    if (hit?.r.clash) add("Conflict", "Same key bound twice in this command", "warnline");
    if (hit) add("Source", hit.sec.source);
    wrap.append(dl);
    return wrap;
  }
  function paintPanel() {
    const L = layerById[cur];
    const code = hoverCode || selCode;
    panel.replaceChildren();
    const list = code ? entriesFor(L, code, shiftOn) : [];
    if (code && list.length) {
      panel.append(mk("div", "crumb", `${L.label} / ${LEG[code] || code}${shiftOn ? " / ⇧" : ""}`));
      list.forEach((e, i) => panel.append(describe(e, L, i === 0)));
      return;
    }
    const n = new Set(L.entries.filter((e) => !!e.shift === shiftOn).map((e) => e.code)).size;
    const ns = new Set(L.entries.filter((e) => e.shift).map((e) => e.code)).size;
    panel.append(mk("h3", null, L.label === "Hyper" ? "Hyper (Right ⌘)" : L.label));
    panel.append(mk("div", "muted2", L.holdLabel));
    panel.append(mk("p", null, `${n} key${n === 1 ? "" : "s"} lit${shiftOn ? " with ⇧" : ""}.${ns && !shiftOn ? ` ${ns} more with ⇧ held.` : ""}${L.tap && rowById[L.tap] ? ` Tapping the layer key alone: ${rowById[L.tap].r.action}.` : ""}`));
    if (code) panel.append(mk("p", "muted2", `${LEG[code] || code}: nothing bound in this layer.`));
    else panel.append(mk("p", "muted2", "Hover or focus a key for its action, scope, source and conflicts. Click to filter the list below."));
  }

  function clickKey(code) {
    const L = layerById[cur];
    const list = entriesFor(L, code, shiftOn);
    if (!list.length) return;
    if (list[0].door) { setLayer(list[0].door); return; }
    selCode = selCode === code ? null : code;
    document.querySelectorAll(".sc-row.sc-sel").forEach((n) => n.classList.remove("sc-sel"));
    const hit = selCode && list[0].row && rowById[list[0].row];
    q.value = hit ? keyString(hit.r.keys) : "";
    apply();
    if (selCode) list.forEach((e) => document.querySelector(`.sc-row[data-id="${e.row}"]`)?.classList.add("sc-sel"));
    paint();
  }

  // ---------- physical keyboard ----------
  const MODS = new Set(["MetaLeft", "MetaRight", "ShiftLeft", "ShiftRight", "AltLeft", "AltRight", "ControlLeft", "ControlRight", "CapsLock", "Fn"]);
  const isHyperFamily = (id) => layerById[id]?.hold.includes("MetaRight") && layerById[id].hold.length === 1;
  function down(code, on) {
    const b = keyEls[code];
    if (!b) return;
    b.classList.toggle("down", on);
    // macOS sends no keyup for keys released while ⌘ is held, so let those fade on their own
    if (on && rightCmd && !MODS.has(code)) setTimeout(() => b.classList.remove("down"), 220);
  }
  document.addEventListener("keydown", (ev) => {
    down(ev.code, true);
    if (ev.code === "MetaRight") {
      rightCmd = true;
      if (!isHyperFamily(cur)) { prevLayer = cur; setLayer("hyper"); }
      return;
    }
    if (ev.code === "AltRight") {
      const L = layerById[cur];
      const ropt = L?.app && layerById[`app-${L.app.toLowerCase()}-ropt`];
      if (ropt && cur !== ropt.id) { prevLayer = cur; setLayer(ropt.id); }
      return;
    }
    if (/^Shift/.test(ev.code)) { if (!shiftOn) { shiftOn = true; paint(); } return; }
    if (rightCmd && !ev.getModifierState("Control") && !MODS.has(ev.code)) {
      // Right ⌘ held: show the Hyper action instead of letting the browser run ⌘+key
      ev.preventDefault();
      hoverCode = ev.code;
      paintPanel();
    }
  });
  document.addEventListener("keyup", (ev) => {
    down(ev.code, false);
    if (ev.code === "MetaRight") {
      rightCmd = false;
      Object.values(keyEls).forEach((b) => b.classList.remove("down"));
      if (prevLayer) { const p = prevLayer; prevLayer = null; setLayer(p); }
    } else if (ev.code === "AltRight" && prevLayer) { const p = prevLayer; prevLayer = null; setLayer(p); }
    else if (/^Shift/.test(ev.code) && !shiftLatch) { shiftOn = false; paint(); }
  });
  addEventListener("blur", () => {
    rightCmd = false;
    Object.values(keyEls).forEach((b) => b.classList.remove("down"));
    if (!shiftLatch && shiftOn) { shiftOn = false; paint(); }
  });

  const mountKeyboard = (body) => {
    if (!layers.length) throw new Error("data.json has no layers; rerun gen-shortcuts");
    buildChips();
    const main = mk("div", "kb-main");
    main.append(buildKeyboard(), panel);
    body.append(chips, main, legend);
    const want = new URLSearchParams(location.search).get("layer") || (location.hash.match(/layer=([\w-]+)/) || [])[1];
    setLayer(want && layerById[want] ? want : "hyper");
    const key = new URLSearchParams(location.search).get("key");
    if (key && keyEls[key]) { selCode = key; paint(); }
  };
  mountKeyboard(document.getElementById("kb-body"));
})();
