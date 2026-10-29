# Plan: tmux → Ghostty + zmx (+ own libghostty app)

Status: draft · 2026-10-29

## 1. Goal

Leave tmux completely. Keep everything tmux gives today (persistent sessions,
scripting, agent orchestration, restore), and gain what tmux blocks: native
Ghostty scrollback/search/selection, kitty graphics, notifications, titles,
and a custom UI built for agents.

## 2. Target architecture

```
┌──────────────────────────────────────────────────────────────┐
│ UI      Ghostty now  →  own macOS app later (Swift + GhosttyKit)│
│         windows = workspaces (work/projects/personal)          │
│         tabs = project windows, splits = panes                 │
│         every split runs:  zmx attach <workspace>.<name>       │
├──────────────────────────────────────────────────────────────┤
│ Process zmx — one tiny daemon per session, owns the pty,       │
│         survives UI quit, libghostty-vt state restore,         │
│         scriptable: run / send / history / tail / wait / labels│
├──────────────────────────────────────────────────────────────┤
│ Agents  vigil — registry keyed by agent session id + name,     │
│         locator = zmx session (was tmux pane id), messaging,   │
│         status, notifications, resume after reboot             │
└──────────────────────────────────────────────────────────────┘
```

Responsibilities:

| Concern | Today (tmux) | Target |
|---|---|---|
| Keep processes alive, detach/attach | tmux server | zmx |
| Windows / tabs / splits | tmux | Ghostty → own app |
| Scrollback, search, copy | tmux copy-mode | Ghostty native |
| Scripting: send, capture, background jobs | send-keys / capture-pane / new-session -d | `zmx send` / `zmx history` / `zmx run -d` |
| Agent identity & messaging | tmux pane ids (`%123`) | vigil: name / session id → zmx session |
| Restore after reboot | resurrect + continuum + vigil hooks | app/registry layout + vigil resume |
| Status bar (vigil usage) | tmux status-right | Vigil.app menu bar / own app chrome |

### Entry point: `rr`

Humans, Karabiner, and agent instructions only ever call `rr`. Backends
(tmux → zmx, Ghostty → own app, vigil internals) change underneath without
touching muscle memory, keybinds, or skills.

| Namespace | Commands | Backed by |
|---|---|---|
| `rr agent` (exists: `mcp`, `skill`) | add `ls`, `name`, `msg`, `ask` | thin wrapper over `vigil agent …` |
| `rr term` (new, replaces `rr tmux`; alias `rr t`) | three sub-areas below | zmx + Ghostty now → own app later |
| `rr term tab` | `run`, `exec`, `logs`, `send`, `ls`, `close`, `pick` (task tabs for agent-run commands, see below) | zmx + labels; shown in own app sidebar |
| `rr term ws` | `switch <workspace>`, `pick` (all tabs), `layout <name>` (replaces `.tmux` launchers / `rr tmux personal|work|projects`) | Ghostty AppleScript now → own app IPC later |
| `rr term session` | `ls`, `attach`, `kill`, `history`, `tail`, `label`, `use`/`unuse` (default target) — raw zmx escape hatch | zmx |
| `rr tmux` | unchanged until P7, then removed | tmux |

Scaffold new namespaces with `private/rr/bin/rr-new-namespace` and document
them in `private/rr/docs/namespaces/` + `docs/rr-cli.md`.

### Task tabs: agents running servers/commands

Today agents create one tmux window per task (`timeline-lab-srv`,
`computer-lab-srv`, `edit-branch-*-srv`, … via `tmux.sh server --task`),
which piles up into dozens of windows in `work`.

Model (browser-like, see Chrome vertical tabs + tab groups):

```
Workspace  work
└─ Group   timeline-lab            (feature / agent; collapsible, like a Chrome tab group)
   ├─ Tab  timeline-lab-srv        (one tab = related commands)
   │   ├─ Pane api    → zmx work.timeline-lab-srv.api   (just server)
   │   └─ Pane web    → zmx work.timeline-lab-srv.web   (just web)
   └─ Tab  claude                  (the agent itself)
```

- **Processes, not windows.** Every pane is a headless zmx session. Nothing is
  rendered until you select the tab, the way background browser tabs aren't
  shown, so 100 running commands don't mean 100 visible panes.
- **Agent API (one call each, no pane ids):**
  ```sh
  rr term tab run  timeline-lab-srv/api -- just server   # start in background; creates tab/pane if missing
  rr term tab exec timeline-lab-srv/sh  -- just test     # blocking, streams output, returns exit code (zmx run)
  rr term tab logs timeline-lab-srv/api [-f] [-n 200] [--grep ERR]   # zmx history / tail
  rr term tab send timeline-lab-srv/api "r"              # raw input (zmx send)
  rr term tab ls [--mine] [--json]                       # tabs, panes, cmd, running/exited(code), owner
  rr term tab close timeline-lab-srv                     # kill all its panes' processes, remove tab
  ```
  Panes record labels: owner agent (name + session id from vigil), group,
  command, start time, exit code. Group defaults to the calling agent's
  name; `rr term tab ls --mine` shows what an agent started.
- **Human side (own app):** vertical sidebar with workspaces → collapsible
  groups → tabs, status dots (running / exited ok / failed / agent waiting);
  selecting a tab attaches its panes as splits; **Cmd+W / ✕ closes the tab
  and kills its processes** (unlike plain zmx, where closing the window only
  detaches). Closing a group closes all its tabs. vigil can offer "close tabs
  of finished agents".
- **Before the app exists:** `rr term tab pick` (fzf with `zmx history` preview)
  attaches a tab into a Ghostty split on demand; everything else works
  headless already.
- Replaces: `tmux.sh server`, `.just/tmux.just`, `bin/run`, the `/ship` windows.

## 3. Why (background)

- Multiplexers are a terminal inside a terminal: TERM/colour bugs, own
  scrollback, selections crossing splits, lost features (kitty graphics,
  notifications). Mitchell Hashimoto and kovid make the same argument.
  → https://bower.sh/you-might-not-need-tmux
- zmx does only session persistence, uses libghostty-vt for restore, one
  daemon per session, multiple clients. → https://zmx.sh,
  https://github.com/neurosnap/zmx
- zmx `run` gives output + exit code, so agents stop polling capture-pane.
  → https://erock.prose.sh/zmx-ai-portal
- libghostty is real and backed (JetBrains, cmux, …), but the official
  library today is **libghostty-vt only** (state, render state, snapshot,
  formatter, search, encoders); no renderer/surface. The full embeddable
  terminal view (GhosttyKit, `ghostty_surface_new`) is still unofficial.
  → https://libghostty.tip.ghostty.org
- Reference app: perch (https://github.com/jawadsh123/perch). Swift +
  GhosttyKit (prebuilt from cmux's fork, pinned) + Rust daemon + SQLite.
  **Perch keeps tmux** (`tmux attach` per window); we swap that for
  `zmx attach`. Reuse its `GhosttyRuntime.swift` / `GhosttySurfaceView.swift`
  and read its `docs/DECISIONS.md` for the bugs it already hit.

## 4. Known facts and constraints

### Ghostty 1.3.1 (AppleScript dictionary, verified via `sdef`)
- Model: windows → tabs → terminals. Terminal: `id`, `name`, `working directory`.
- **Not exposed:** split tree/geometry, tty, pid, running process, screen text.
- Commands: new window/tab, split (dir + surface config: cwd, command,
  initial input, env vars), focus, activate window, select tab, close,
  input text, send key, perform action (any keybind action), quit.
- Window title can't be set independently (follows focused split).
- `window-save-state = always` restores windows/tabs/splits/cwds as fresh shells.
- No popups, status bar, focus hooks, or tab move between windows by script.
- Tabs: native macOS tabs. `macos-titlebar-style = hidden` (current) hides
  the tab bar; `tabs` puts them in the titlebar. 46 tabs in one window is
  unreadable → needs a picker / sidebar.

### zmx (0.8.x)
- Commands: `attach` (upsert), `run [-d]`, `send`, `print` (display only),
  `write`, `detach`, `ls`, `get/set/clear` labels, `print-env`, `kill`,
  `history [--vt|--html]`, `wait`, `tail`.
- `$ZMX_SESSION` is set inside a session → hooks know their location for free.
- `ZMX_SESSION_PREFIX` namespaces sessions (`work.`, `personal.` …).
- `zmx list` reports `start_dir` per session.
- Pitfalls:
  1. **Nested attach:** inside a session `zmx attach other` switches the
     *human's* terminal. Agents must use `run/send/history` or
     `env -u ZMX_SESSION zmx attach`.
  2. **Upgrades that change IPC kill all sessions.** Pin the version in
     home-manager; upgrade deliberately.
  3. Detach key `ctrl+\` not configurable → set `ZMX_NO_DETACH_KEY`, detach
     by closing the split.
  4. Kitty keyboard re-enable on reattach echoes junk in some apps (psql).
  5. Client env (`SSH_AUTH_SOCK` …) goes stale → zsh `precmd` with
     `eval "$(zmx print-env -s .)"`.
  6. Per-session logs always on (`~/.local/state/zmx/logs`) → watch disk.
  7. zmx → ssh → zmx nesting unsupported.

## 5. Current tmux footprint (what has to move)

### Dotfiles (interactive)
| Item | Where | Destination |
|---|---|---|
| tmux module, keybinds, plugins (resurrect, continuum, open, copycat, yank, prefix-highlight) | `nixpkgs/home-manager/modules/tmux.nix`, imported by `mac.nix:14` | Ghostty keybinds; plugins become native features or drop |
| Split/select/resize/zoom/swap-window/rename/reload | `tmux.nix:33-131` | `new_split`, `goto_split`, `resize_split`, `toggle_split_zoom`, `move_tab`, `prompt_tab_title`, `reload_config` |
| vim-aware `C-hjkl` nav | `tmux.nix:88-93`, rvim `navigator-nvim` | Separate keys (lost seamless nav until own app) |
| Swap pane | `tmux.nix:127-128`, `rules.ts:480-523` | No equivalent; own app later |
| Copy mode | `tmux.nix:42-47` | Ghostty native scrollback/search/selection |
| Status bar + `vigil status`, `prefix a` vigil popup | `tmux.nix:136-186` | Vigil.app menu bar; quick terminal / app |
| Window auto-name | `zsh.nix:231-246` | OSC 2 title from chpwd hook, drop `$TMUX` gate |
| Session launchers `t()`, `.tmux` files, `dotfiles()`, `iv-pro()` | `shell/shell_functions:3-153`, `.tmux`, `private/*_tmux`, `private/private_functions:49-51` | `ws`/`zt` layout scripts → own app workspaces |
| chafa tmux passthrough | `shell_functions:248-250` | Delete |
| `pam-reattach` | `nixpkgs/darwin/mbp/configuration.nix:116-136` | Drop |
| Ghostty `cmd+…` → control-code remaps "for tmux" | `ghostty.nix:39-53` | Remove `cmd+b`; re-decide `cmd+w/n/d` |
| `macos-titlebar-style = hidden` | `ghostty.nix:57` | `tabs` |
| Karabiner tmux bindings (~15 rules) | `config/karabiner/rules.ts:15-317, 424-565, 870-957` | Ghostty actions / `ws` / vigil |
| Shortcut docs | `bin/gen-shortcuts`, `docs/shortcuts/*`, `docs/tmux-session-restore.md` | Regenerate / rewrite |

### Automation
| Item | Where | Destination |
|---|---|---|
| `rr tmux` (≈1000 lines: pane get/use/capture/send/split/move/run/autoarm, layouts, popup, sessions) | `private/rr/namespaces/tmux.sh`, `private/rr/lib/common.sh`, `private/private_functions:3-47` (pane options `@rr_*`) | `rr term` / app control; pane options → zmx labels |
| iv-pro dev-loop `tmux.sh` / `ghostty.sh` | `~/workspace/iv-pro/skills/iv-pro-dev-loop/scripts/` | zmx-based helper (names, `run`, `history`, `tail`) |
| `bin/run` (detached multi-pane stack) | `iv-pro/bin/run:157-192` | `zmx run -d` per service (or process-compose) |
| `.just/tmux.just` (tmux-server-start/kill/restart/send, get/search-server-logs) | iv-pro-api, export-worker, media-router, copilot-v45 | `zmx run -d`, `zmx kill`, `zmx send`, `zmx history` / `tail` |
| `/ship` orchestrator (new-session -d, send-keys, capture-pane -S -1000) | `.claude/commands/code/ship.md` (web, media-router, copilot-v45, playground-web) | `zmx run` (exit codes!) / `history` |
| media-router docs `tmux new-session -d -s media-router 'just server'` | `iv-pro-media-router/README.md:29`, `CONTRIBUTORS.md:92` | `zmx run -d media-router just server` |
| Misc scripts / docs | `copilot-v45/skills/timeline-bench/scripts/{sweep,ledger_status}.sh`, `iv-pro-engine/trace/cost/run_arc1.sh`, `docs/tmux-guide.md`, `test-tmux-server-window.sh` | Port or delete |
| Agent instructions | `private/extras/agents/shared.md:21-22`, `private/skills/nvim-tmux-control/SKILL.md`, iv-pro skill docs, `iv-pro/.claude/skills/feature/SKILL.md` | Rewrite for `vigil agent` + zmx |

### vigil (tmux-coupled, ~40k lines)
- Identity is already `session_id` (PK); `pane_id` is only a locator →
  migration is about locators, not the data model.
- Pane-keyed today: reap, ack/snooze/park, `jump_back` (pane NOT NULL),
  permission requests → re-key by session id.
- Portable: jump/back, actuation (answering prompts), feature jump.
- Redesign: identity capture (now trivial via `$ZMX_SESSION`), ack-on-focus,
  restore, ui grouping.
- Drop or keep tmux-only: stash/swap-in-place, sidebar parking, Commander,
  status segment, poke hooks.
- Plans to align with: `thoughts/plans/20260720_native_vigil_app_plan.md`,
  `thoughts/plans/20260908_tmux_conversation_restore_plan.md`.

## 6. Phases

Each phase is useful on its own; tmux keeps working until P7.

### P0 — Agent messaging by name / session id (in progress)
Worktree: `~/projects/rust/vigil/.worktrees/agent-msg` (uncommitted).
- Agent names (auto from repo + kind, `VIGIL_AGENT_NAME`, `vigil agent name`),
  unique among live agents, follow id rotation on `/clear` `/resume` compaction.
- `vigil agent ls | name | msg | ask`; targets = name, session-id prefix,
  legacy pane id. Header `[from <name> | <sid8>]`. Refuse non-agent targets,
  never send Escape, note when target busy. `ask` waits on a reply file.
- Delivery behind a backend boundary: tmux now, zmx later (`zmx send` + Enter;
  **never `zmx run`** to an agent).
- Exit: `just check` green, E2E on `-L vigil-test`.
- Follow-up: hook records `$ZMX_SESSION` when present; add
  `rr agent ls|name|msg|ask` wrapping `vigil agent …`; agent instructions
  (`shared.md`) switch from pane ids to `rr agent …`.

### P1 — zmx spike (≈1 day, isolated)
- Add zmx via nix (pinned), run splits as `zmx attach` in current Ghostty.
- Verify: survive Ghostty quit/relaunch; nvim + Claude + Codex inside;
  `history --vt`, `send`, `run` exit codes, `tail`, `wait`, labels,
  `ZMX_SESSION_PREFIX`; reattach screen fidelity; memory with ~50 sessions.
- Exit: written verdict + list of breakages.

### P2 — zmx in dotfiles (≈1 day)
- home-manager: zmx package (pinned rev), `ZMX_NO_DETACH_KEY=1`,
  zsh `precmd` print-env hook, prompt segment showing `$ZMX_SESSION`,
  completions.
- `rr term` namespace (scaffold via `rr-new-namespace`, alias `rr t`).
- `rr term session pick` / `zt` wrapper (Ghostty `command`): pick/attach session by name; on restore
  match by `start_dir` (one → attach, many → fzf picker with `history`
  preview, none → new). Based on zmx-select / zmx-picker.
- Rule in agent instructions: never bare `zmx attach` from inside a session.

### P3 — Automation off tmux (few days, mostly iv-pro)
- Build `rr term tab` (task tabs, see §2) on zmx; agents switch from
  `tmux.sh server`/`send`/`capture` to `rr term tab run|exec|logs|send|close`.
- iv-pro dev-loop skill rewritten around `rr term tab`.
- Port `.just/tmux.just` → `.just/zmx.just` in the four repos; `bin/run`;
  `/ship`; media-router docs; bench scripts.
- `rr tmux` features → `rr term` (pane options `@rr_*` → zmx labels;
  `RR_TMUX_PANE` → `rr term session use`; autoarm/run on zmx `run`); layouts and
  session launchers → `rr term ws`. Update `private/private_functions` precmd sync.
- Optional: dev servers under process-compose instead of shells.

### P4 — vigil on zmx (≈8–11 days total, can interleave)
- Schema: re-key ack/snooze/park/jump_back/permissions by session id; store
  zmx session (from `$ZMX_SESSION`) + tty.
- Small `Mux` trait (list, locate, current, focus, send_text, send_key,
  spawn, liveness, caps) with tmux and zmx(+Ghostty/app) impls.
- Liveness from pid + `zmx ls`; capture via `zmx history`; labels for state.
- Restore v2: slots (session id, agent, model, effort, cwd, zmx name, layout
  position); after reboot the UI recreates layout, a shell-side claim
  (`vigil restore claim`) prefills `c --effort {e} {model} resume <id>`.
- `zmx print` for visible, non-input notices.

### P5 — Interactive Ghostty (interim, 1–2 days)
- `ghostty.nix`: titlebar `tabs`, split/tab keybinds replacing tmux prefix
  flows, drop `cmd+b`, resolve `cmd+w/n/d`, `confirm-close-surface`.
- Karabiner: tmux rules → Ghostty actions; Hyper+1/2/3 → `rr term ws switch`.
- `rr term ws`: workspace registry (window ↔ name, re-bound
  after restart by tab titles/cwds), `switch`, `pick` (all tabs, fzf /
  `choose` / Raycast), `tab`, layouts replacing `.tmux` launchers.
- Fix `ghostty.sh` bugs found in review (tty_map clobbers non-Ghostty
  titles; server collision guard missing; `split --command` without PATH;
  agent detection misses trailing `/claude`; clipboard capture).
- Validate: does `window-save-state` restore window/tab/split order + cwds
  reliably? (decides interim restore matching).

### P6 — Own app (weeks)
- Swift + GhosttyKit (pin like perch; swap to official package when it
  ships). Reuse perch's runtime/surface view; heed its DECISIONS.md.
- Registry (SQLite, or vigil's) owns workspace → window → tab → split tree
  → zmx session. Exact restore; quit = detach.
- Chrome-style vertical sidebar: workspaces → groups → tabs (task tabs from
  `rr term tab`, agent tabs, shells) with status dots; lazy rendering; Cmd+W kills
  the tab's processes. Live vigil agent status, command palette,
  canvas of live surfaces, jump-to-agent via direct IPC (no AppleScript).
- Probably merges with the native Vigil.app plan.

#### term M2: agent-first sidebar (reference: rex screenshots, 2026-10-29)
- Rows are agents, not tabs: kind icon (✳ Claude, Codex, `>_` shell/server),
  title from the conversation, selected row as a pill, blue attention dot,
  `•••` row menu (message via `rr agent msg`, rename, close).
- Sections per project/worktree; a Servers section for `rr term tab` task tabs.
- Lead → workers: hover popover listing child agents (status, cwd, current
  activity); expanded mode (👁 toggle) shows a two-line row (status line +
  last activity) with relative time, and nests a lead's workers in a
  rounded card.
- Title-bar row: sidebar toggle, 👁 detail toggle, ⌘ palette, + new.
- Needs from vigil: per-agent title, current activity (from tool hooks),
  status timestamps, parent session id (recorded by `rr agent new` when an
  agent launches another; `rr term tab` panes already record their owner).
  term subscribes to vigil (stream or poll) plus `rr term tab ls`.
- Look: dark, Chrome-vertical-tabs style sidebar (decided 2026-10-29); splits
  as rounded pane cards separated by a dark gutter, no bright divider line.
- Karabiner (after M1): Hyper+s tap-alone (`rules.ts:930`) → if Term is
  frontmost `term ctl sidebar.toggle`, else `vigil sidebar toggle` (today's
  behaviour). Extend all Ghostty-only rules (Right Option + key, Hyper
  `,` `.` `1/2/3` …) to Term's bundle id `dev.rakshan.term`.

### P7 — Retire tmux
- Remove `tmux.nix` import, resurrect/continuum hooks, pam-reattach, tmux
  bits in zsh/shell functions/Karabiner, `docs/tmux-session-restore.md`,
  tmux-only vigil features (or keep behind a capability flag).

### P8 — Optional: own process layer
- Replace N zmx daemons with one Rust service on libghostty-vt Rust bindings
  (snapshot, formatter, search), possibly inside vigil. Only if zmx limits bite.

## 7. Risks

| Risk | Mitigation |
|---|---|
| zmx upgrade kills sessions | Pin version; upgrade only with restore ready |
| zmx young (0.8) | P1 spike; keep tmux until P7; P8 fallback |
| GhosttyKit unofficial / pinned fork | Follow perch's pin; isolate embedding code; watch for official Swift package |
| Own terminal app long tail (keyboard, IME, focus, zombie surfaces) | Reuse perch code; ship interim Ghostty + `ws` first |
| Agents attaching from inside zmx hijack the terminal | Instructions + vigil never call bare attach |
| Reboot still kills processes | vigil resume (same as resurrect today) |
| Lost: vim-aware split nav, swap pane, status bar | Own app; Vigil.app menu bar |
| 46+ tabs per workspace | Picker / sidebar; vigil reaping of dead agent tabs |

## 8. Decisions and open questions

Decided:
- 2026-10-29 — rr namespace for the terminal layer is `rr term` (alias
  `rr t`) with `tab`, `ws`, `session`; agent messaging is `rr agent
  ls|name|msg|ask` (wraps `vigil agent`). Agent instructions: "message with
  `rr agent`, run commands with `rr term tab`".
- 2026-10-29 — P0 built: vigil `agent` messaging (worktree
  `.worktrees/agent-msg`, uncommitted) + `rr agent` wrappers (uncommitted).

- 2026-10-29 — Gradual cutover: Hyper+1/2/3 and Hyper+t keep targeting
  Ghostty/tmux from other apps; they act on Term only while Term is
  frontmost. Flip them to Term everywhere once sessions have moved over.

- 2026-10-29 — vigil stays Rust-only (hooks, DB, usage, CLI). Vigil.app
  (Swift, notch) is retired — uninstalled to Trash; not ported for now.
  term's left panel shows agent status + usage (tmux status-right segment
  equivalent, expandable usage-stats panel) from `vigil usage --json`,
  `vigil watch`, `vigil query --json`.

Open:
- Dev servers: zmx sessions or process-compose? (leaning zmx via `rr term tab`)
- Own app: separate project or the native Vigil.app?
- Workspace naming scheme for zmx sessions (`work.iv-pro-api.2`?) and how
  names are chosen on split creation.
- Agent naming defaults (repo + kind? branch?) and whether `c` passes
  `VIGIL_AGENT_NAME`.
- Remote/ssh use: adopt zmx's `RemoteCommand zmx attach %k` pattern?

## 9. References

- zmx: https://zmx.sh · https://github.com/neurosnap/zmx
- https://bower.sh/you-might-not-need-tmux
- https://erock.prose.sh/zmx-ai-portal
- libghostty: https://libghostty.tip.ghostty.org
- perch: https://github.com/jawadsh123/perch
- cmux (GhosttyKit fork source): https://github.com/manaflow-ai/ghostty
- Ghostty AppleScript: `sdef /Applications/Ghostty.app`
