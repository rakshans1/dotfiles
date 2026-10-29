# term keybinding audit (Ghostty + tmux -> term)

Read-only audit, 2026-10-29. Audited against **term HEAD `d90a74f`**, plus the dotfiles working tree (`rules.ts` / `karabiner.json` with today's `Term:` rules).

Status key: ✅ works by design · ⚠️ likely broken or behaves differently (the reason comes from the code) · ❌ missing · 🚫 intentionally dropped (or not applicable without tmux)

## 0. Read this first

1. **The installed app is stale.** `~/Applications/Term.app/Contents/MacOS/Term` was built at 19:03, and the running instance (pid 32273) started at 19:10. Two later commits are not in it:
   - `ec62988` (19:1x) fixes the cursor so only the focused split shows a focused cursor. Before it, every split drew a filled, blinking cursor, so a pane move was hard to see.
   - `d90a74f` (19:20) adds `TerminalWindow.performKeyEquivalent/sendEvent` so the router gets first refusal on every chord (`Sources/Term/TerminalWindow.swift:46-55`). It also adds `term-ctl explain-key` and records `state.lastKey`.

   Run `just app-install` in `~/projects/swift/term` before re-testing anything below.
2. **What is actually wrong with Cmd+h/j/k/l.** The suspicion was that Ghostty's `cmd+h=text:\x08` consumes the key first. The code does not support that. The app-wide `NSEvent` local key monitor (`TermController.swift:74`) runs before AppKit's key-equivalent pass, and `d90a74f` adds a second, earlier hook in the window. So the router always sees `cmd+h` before Ghostty does.

   The Ghostty binding only fires when the router hands the key back. `KeyDecider.resolve` (`Sources/TermCore/Keymap.swift:441-444`) hands it back when vim/nvim/fzf is in the foreground, which is correct. It also hands it back when there is no split in that direction, which is the problem. That second check is `canPerform` → `layout.neighbor` (`TermController.swift:354-361`).

   `term-ctl state` shows 27 of 28 tabs are single-pane, so the key almost always comes back. Ghostty then turns it into ^H/^J/^K/^L, and zsh runs `backward-kill-word`, `end-of-line`, `kill-line` or `clear-screen` (`zsh.nix:190-193`). On an empty prompt the first three change nothing visible, which is the "does nothing" symptom.

   tmux behaved differently: its root `C-h` binding always consumed the key. `select-pane -L` wraps around at the edge and does nothing in a single pane. **Fix:** when no vim is in the foreground, the vim-aware layer should consume the key (and wrap like tmux) instead of passing it through.

## 1. Prefix keys (C-b / Cmd+B, then a key)

Router: `KeyRouter.handle` (`Sources/TermCore/Keymap.swift:381`). Keys after the prefix that are not bound are swallowed, as in tmux (`Keymap.swift:388-390`). Commands run through `TermController.perform` (`Sources/Term/TermController.swift:440`).

| Source | Key | Ghostty+tmux did | term does (handler) | Status | Fix |
|---|---|---|---|---|---|
| tmux default | `C-b` (prefix) | enter prefix | `keymap.json:6` direct `prefix` | ✅ | — |
| Ghostty cmd→ctrl | `Cmd+B` (prefix) | ^B → tmux prefix | `keymap.json:7` direct `prefix`; the router consumes it before Ghostty's `cmd+b=text:\x02` | ✅ | — |
| tmux behaviour | prefix wait time | unlimited (tmux has no prefix timeout) | `prefixTimeoutMs: 1000` (`keymap.json:3`, `Keymap.swift` `isPrefixActive`). If you pause more than 1 s, the next key goes to the shell | ⚠️ | Raise to ~3000, or treat 0 as "no timeout" |
| tmux default | prefix `C-b` | send literal ^B | `keymap.json:43` `send-prefix` → `sendLiteralCtrlB` `TermController.swift:429` | ✅ | — |
| Ghostty+tmux | prefix `Cmd+B` | ^B^B → literal ^B | `keymap.json:44` `send-prefix` | ✅ | — |
| tmux user | prefix `r` | reload tmux.conf | `keymap.json:77` `reload-config` (Ghostty config + keymap) → `TermController.swift:764` | ✅ | — |
| tmux user | prefix `x` | kill-pane, no prompt | `keymap.json:55` → `closePane` `TermController.swift:881`. Asks for confirmation only if an agent runs in the pane; on the last pane it closes the tab | ✅ | — |
| tmux user | prefix `X` | kill-window, no prompt | `keymap.json:56` `close-tab` → `TermController.swift:825` | ✅ | — |
| tmux user | prefix `P` | paste-buffer | `keymap.json:79` `paste` (system clipboard, not a tmux buffer) → `TermController.swift:473` | ✅ | — |
| tmux user | prefix `R` | rename-window prompt | `keymap.json:70` `rename-tab` → sheet `TermController.swift:718` | ✅ | — |
| tmux user | prefix `v` | split-window -h, keeps cwd | `keymap.json:45` `split right` → `TermController.swift:605` | ✅ | — |
| tmux user | prefix `V` | split-window -v, keeps cwd | `keymap.json:46` `split down` | ✅ | — |
| tmux user | prefix `H` (-r) | resize -L 5 | `keymap.json:51` `resize left 5`, repeatable → `TermController.swift:647` | ✅ | — |
| tmux user | prefix `J` (-r) | resize -D 5 | `keymap.json:52` | ✅ | — |
| tmux user | prefix `K` (-r) | resize -U 5 | `keymap.json:53` | ✅ | — |
| tmux user | prefix `L` (-r) | resize -R 5 (overrides default `L` = last session) | `keymap.json:54` | ✅ | — |
| tmux user | prefix `h` | select-pane -L (wraps) | `keymap.json:47` `focus left` → `TermController.swift:632`. No wrap: at the edge nothing happens (the key is consumed) | ✅ | Optional: wrap like tmux |
| tmux user | prefix `j` | select-pane -D | `keymap.json:48` | ✅ | (same) |
| tmux user | prefix `k` | select-pane -U | `keymap.json:49` | ✅ | (same) |
| tmux user | prefix `l` | select-pane -R (overrides default `l` = last-window) | `keymap.json:50` | ✅ | (same) |
| tmux user | prefix `Tab` (-r) | next pane | `keymap.json:71` `next-pane`, repeatable → `TermController.swift:640` | ✅ | — |
| tmux user | prefix `,` | swap-pane -D (overrides default rename) | `keymap.json:72` `swap-pane next` → `TermController.swift:667` | ✅ | — |
| tmux user | prefix `.` | swap-pane -U (overrides default move-window) | `keymap.json:73` `swap-pane prev` | ✅ | — |
| tmux user | prefix `>` | swap-window +1 | `keymap.json:74` `move-tab right` → `TermController.swift:704` | ✅ | — |
| tmux user | prefix `<` | swap-window -1 | `keymap.json:75` `move-tab left` | ✅ | — |
| tmux user | prefix `a` | `vigil ui` popup (80%×60%) | none: the key is swallowed after the prefix | ❌ | Add a term action that runs a command in a popup or new tab (`popup CMD`), then bind `a` |
| tmux default | prefix `c` | new-window | `keymap.json:57` `new-tab` → `TermController.swift:574` | ✅ | — |
| tmux default | prefix `n` | next-window | `keymap.json:68` `next-tab` → `TermController.swift:696` | ✅ | — |
| tmux default | prefix `p` | previous-window | `keymap.json:69` `prev-tab` | ✅ | — |
| tmux default | prefix `1`–`9` | select-window N (base-index 1) | `keymap.json:58-66` `select-tab N` → `TermController.swift:688` | ✅ | — |
| tmux default | prefix `0` | window 0 (does not exist with base-index 1, so a no-op) | `keymap.json:67` → 10th tab | ✅ | — |
| tmux default | prefix `d` | detach client | `keymap.json:83` `detach` → `NSApp.hide` `TermController.swift:492` | ✅ | — |
| tmux default | prefix `z` | zoom pane | `keymap.json:76` `zoom` → `TermController.swift:659` | ✅ | — |
| tmux default | prefix `[` | vi copy-mode | `keymap.json:78` `search` → the Ghostty find bar (`TermController.swift:468`). No vi motions, selection or yank | ⚠️ | See §7 |
| tmux default | prefix `]` | paste-buffer | `keymap.json:80` `paste` (clipboard) | ✅ | — |
| tmux default | prefix `s` | choose-tree (sessions) | `keymap.json:81` `picker` → `TermController.swift:779` | ✅ | — |
| tmux default | prefix `w` | choose-tree (windows) | `keymap.json:82` `picker` | ✅ | — |
| tmux default | prefix `f` | find-window | none (swallowed) | ❌ | Alias `f` → `picker` |
| tmux default | prefix `o` | select next pane | none | ❌ | Alias `o` → `next-pane` |
| tmux default | prefix `;` | last (previously active) pane | none | ❌ | Needs a pane MRU list; add `last-pane` |
| tmux default | prefix `%` | split -h | none (the user uses `v`) | ❌ | Alias `%` → `split right` |
| tmux default | prefix `"` | split -v | none (the user uses `V`) | ❌ | Alias `"` → `split down` |
| tmux default | prefix `&` | kill-window (with confirm) | none (the user uses `X`) | ❌ | Alias `&` → `close-tab` |
| tmux default | prefix `{` / `}` | swap-pane -U / -D | none (the user uses `.` / `,`) | ❌ | Alias to `swap-pane prev/next` |
| tmux default | prefix `q` | display-panes (numbered overlay) | none | ❌ | Low priority |
| tmux default | prefix `!` | break-pane into a new window | none | ❌ | Add `break-pane` (pane → new tab) |
| tmux default | prefix `(` / `)` | previous/next session | none | ❌ | Add `workspace prev/next` |
| tmux default | prefix `'` | select-window by index prompt | none | ❌ | Low priority |
| tmux default | prefix `?` | list-keys | none | ❌ | Show the keymap or open the cheat sheet |
| tmux default | prefix `←↑→↓` (-r) | select-pane | none: `keymap.json` has no prefix arrows | ❌ | Add prefix `left/right/up/down` → `focus` |
| tmux default | prefix `C-←↑→↓` / `M-←↑→↓` (-r) | resize 1 / 5 | none in the prefix layer; direct `ctrl+cmd+arrows` exist (`keymap.json:28-31`) | ❌ | Add prefix `ctrl+arrow` → `resize DIR 1` (repeatable) |
| tmux default | prefix `PageUp` | copy-mode and scroll up | none | ❌ | Bind to `scroll_page_up`, or leave unbound since the wheel and Cmd+PgUp already scroll |
| tmux default | prefix `:` | command prompt | none; `term-ctl` is the command line | 🚫 | — |
| tmux default | prefix `$` | rename-session | none; the workspaces are a fixed set | 🚫 | — |
| tmux default | prefix `#` `=` `-` | list/choose/delete paste buffers | none; term has no buffers, only the clipboard | 🚫 | — |
| tmux default | prefix `Space`, `M-1..5`, `E`, `C-o`, `M-o` | layout cycling, presets, rotate | none | 🚫 | — |
| tmux default | prefix `i` `t` `~` `D` `C-z` `m` `M` `M-n` `M-p` | info, clock, messages, clients, suspend, marks, alert-window nav | none | 🚫 | — |
| tmux-resurrect | prefix `C-s` | save layout | none; zmx sessions plus the term registry persist on their own | 🚫 | — |
| tmux-resurrect | prefix `C-r` | restore layout | none; term reattaches to zmx on launch | 🚫 | — |
| tmux-continuum | (auto save/restore) | 15-minute auto save, restore on start | zmx + `RegistryStore` | 🚫 | — |
| tmux-copycat | prefix `/` | regex search of scrollback | none (swallowed) | ❌ | Alias `/` → `search` (plain text, not regex) |
| tmux-copycat | prefix `C-f` `C-g` `M-h` `C-u` `C-d` `M-i` | file / git-file / SHA / URL / number / IP search | none; the Ghostty find bar has no regex presets | ❌ | Low priority; could pre-fill search |
| tmux-yank | prefix `y` / prefix `Y` | copy command line / copy pane cwd to clipboard | none | ❌ | `Y` → a new `copy-pane-cwd` action |
| tmux-prefix-highlight | (status indicator) | shows when the prefix is active | header indicator `updatePrefixIndicator` (`TermController.swift` near `route`) | ✅ | — |

## 2. Root (no-prefix) keys and term direct-layer keys

| Source | Key | Ghostty+tmux did | term does (handler) | Status | Fix |
|---|---|---|---|---|---|
| tmux user (`bind -n`) | `M-Space` (Opt+Space, option-as-alt) | copy-mode | `keymap.json:22` direct `search` → find bar | ⚠️ | Search works, but it is not a copy mode (see §7) |
| tmux user (`bind -n`) | `C-h/j/k/l` | is_vim nav | see §4 | — | — |
| Ghostty default | `Cmd+T` | new Ghostty tab (unused under tmux) | `keymap.json:8` `new-tab` | ✅ | — |
| Ghostty default | `Cmd+1`–`8`, `Cmd+9` | goto_tab / last_tab (Ghostty tabs) | `keymap.json:9-17` `select-tab N` | ✅ | — |
| Ghostty default | `Ctrl+Tab` / `Ctrl+Shift+Tab` | next/previous Ghostty tab | `keymap.json:18-19` | ✅ | — |
| Ghostty default | `Cmd+Shift+]` / `Cmd+Shift+[` | next/previous Ghostty tab | `keymap.json:20-21` (the router normalizes to `cmd+}` / `cmd+{`) | ✅ | — |
| Ghostty default | `Cmd+Opt+←→↑↓` | goto_split (no Ghostty splits, so a no-op) | `keymap.json:24-27` `focus` | ✅ | — |
| Ghostty default | `Ctrl+Cmd+←→↑↓` | resize_split 10 | `keymap.json:28-31` `resize DIR 5` | ✅ | — |
| Ghostty default | `Cmd+Shift+Enter` | toggle_split_zoom | `keymap.json:32` `zoom` | ✅ | — |
| term only | `Ctrl+Cmd+S` | — | `keymap.json:23` `sidebar` | ✅ | — |
| term only | prefix `b` | — | `keymap.json:84` `sidebar` | ✅ | — |

## 3. Cmd-letter passthrough (Ghostty `keybind =` lines, plus Ghostty macOS defaults that libghostty still applies inside term)

Path for chords the router does not claim: `TerminalWindow.performKeyEquivalent` (`TerminalWindow.swift:48`) → `TerminalSurfaceView.performKeyEquivalent` (`Sources/GhosttyTerminal/TerminalSurfaceView.swift:536`) → `ghostty_surface_key_is_binding` → `keyDown` (`:471`) → libghostty.

libghostty sends app-level actions to `GhosttyRuntime.action`. Its `default:` case (`GhosttyRuntime.swift:394`) returns false for anything unhandled, such as new_split, goto_split, toggle_fullscreen, close_tab and the command palette. Because those bindings are not `performable`, the key is still **consumed silently** (vendored `Surface.zig:2987-3000`).

| Source | Key | Ghostty+tmux did | term does (handler) | Status | Fix |
|---|---|---|---|---|---|
| ghostty.nix:40 | `Cmd+S` | ^S | Ghostty binding passthrough → ^S | ✅ | — |
| ghostty.nix:41 | `Cmd+H` | ^H → tmux C-h pane left | vim-aware router (§4) | — | see §4 |
| ghostty.nix:42 | `Cmd+J` | ^J → tmux C-j pane down | vim-aware router (§4) | — | see §4 |
| ghostty.nix:43 | `Cmd+K` | ^K → tmux C-k pane up (overrides default clear_screen) | vim-aware router (§4) | — | see §4 |
| ghostty.nix:44 | `Cmd+L` | ^L → tmux C-l pane right | vim-aware router (§4) | — | see §4 |
| ghostty.nix:45 | `Cmd+W` | ^W delete word (overrides close_surface) | Ghostty passthrough. The menu deliberately has no Cmd+W (`MainMenu.swift:4-8`) | ✅ | — |
| ghostty.nix:46 | `Cmd+X` | ^X (zsh ^X prefix) | Ghostty passthrough | ✅ | — |
| ghostty.nix:47 | `Cmd+B` | ^B → tmux prefix | `keymap.json:7` router prefix | ✅ | — |
| ghostty.nix:48 | `Cmd+P` | ^P (zsh up-line-or-search) | Ghostty passthrough | ✅ | — |
| ghostty.nix:49 | `Cmd+/` | ^_ (undo) | Ghostty passthrough | ✅ | — |
| ghostty.nix:50 | `Cmd+\` | ^\ | Ghostty passthrough | ✅ | — |
| ghostty.nix:51 | `Cmd+N` | ^N (overrides new_window) | Ghostty passthrough | ✅ | — |
| ghostty.nix:52 | `Cmd+D` | ^D (overrides new_split) | Ghostty passthrough | ✅ | — |
| ghostty.nix:53 | `Cmd+U` | ^U | Ghostty passthrough | ✅ | — |
| ghostty.nix:37 | `Opt+\`` (global) | toggle Ghostty quick terminal | term implements neither global keybinds nor the quick terminal. Ghostty.app keeps this key while it runs | 🚫 | — |
| Ghostty default | `Cmd+C` / `Cmd+V` / `Cmd+A` | copy / paste / select all | Ghostty binding, plus Edit menu (`MainMenu.swift:54-56`) → `TerminalSurfaceView.swift:644-647` | ✅ | — |
| Ghostty default | `Cmd+=` `Cmd++` `Cmd+-` `Cmd+0` | font size up / down / reset | libghostty core; cell size returns via `GHOSTTY_ACTION_CELL_SIZE` (`GhosttyRuntime.swift:379`). Applies per surface | ✅ | — |
| Ghostty default | `Cmd+F` / `Cmd+E` | start_search / search_selection | `GHOSTTY_ACTION_START_SEARCH` (`GhosttyRuntime.swift:389`) → term search bar | ✅ | — |
| Ghostty default | `Cmd+G` / `Cmd+Shift+G` | next / previous match | Unreachable while the search field has focus: the field is the first responder, not the surface, and the router steps aside (`TermController.swift:328`). Use Enter / Shift+Enter (`SearchBar.swift:88`) | ⚠️ | Handle Cmd+G / Cmd+Shift+G in `SearchBar` `doCommand` |
| Ghostty default | `Esc` / `Cmd+Shift+F` | end_search | `performable`, so Esc reaches the shell or vim when no search is open (vendored `Config.zig:6744`) | ✅ | — |
| Ghostty default | `Cmd+Home/End/PgUp/PgDn` | scroll top / bottom / page | libghostty core | ✅ | — |
| Ghostty default | `Cmd+↑/↓`, `Cmd+Shift+↑/↓` | jump_to_prompt | libghostty core. Needs OSC 133 marks: inside zmx, Ghostty's automatic shell-integration injection does not run (the surface command is `zmx attach`), so this is probably a no-op. The same was true under tmux | ⚠️ | Source Ghostty's zsh integration from zsh.nix |
| Ghostty default | `Cmd+←/→`, `Cmd+Backspace`, `Opt+←/→` | ^A / ^E / ^U / ESC b / ESC f | Ghostty text bindings | ✅ | — |
| Ghostty default | `Cmd+Shift+,` | reload_config | `GHOSTTY_ACTION_RELOAD_CONFIG` (`GhosttyRuntime.swift:387`) | ✅ | — |
| Ghostty default | `Cmd+,` | open_config | unhandled, consumed | ❌ | Handle `OPEN_CONFIG` (open `~/.config/ghostty/config`) |
| Ghostty default | `Cmd+Q` | quit | menu `MainMenu.swift:34` / `QUIT` → terminate; zmx sessions keep running | ✅ | — |
| Ghostty default | `Cmd+M` | minimize | menu `MainMenu.swift:77` | ✅ | — |
| Ghostty default | `Cmd+Shift+W` | close_window | `AppDelegate.swift:84` hides term (detach) | ✅ | — |
| Ghostty default | `Cmd+Opt+W` / `Cmd+Opt+Shift+W` | close_tab / close_all_windows | unhandled, consumed | ❌ | Map `CLOSE_TAB` → `close-tab` |
| Ghostty default | `Cmd+Shift+D` | new_split:down | unhandled, consumed | ❌ | Add `cmd+shift+d` → `split down` (and Cmd+D stays ^D) |
| Ghostty default | `Cmd+[` / `Cmd+]` | goto_split previous / next | unhandled, consumed | ❌ | Map to `next-pane` / a new `prev-pane` |
| Ghostty default | `Cmd+Ctrl+=` | equalize_splits | unhandled, consumed | ❌ | Add `equalize` |
| Ghostty default | `Cmd+Enter` / `Cmd+Ctrl+F` | toggle_fullscreen | unhandled, consumed | ❌ | Handle `TOGGLE_FULLSCREEN` → `window.toggleFullScreen` |
| Ghostty default | `Cmd+Shift+P` | command palette | unhandled, consumed (Hyper+v+p lands here too) | ❌ | Low priority |
| Ghostty default | `Cmd+Z` / `Cmd+Shift+Z` / `Cmd+Shift+T` | undo / redo of close | unhandled | 🚫 | — |
| Ghostty default | `Cmd+Opt+I` | inspector | unhandled | 🚫 | — |
| Ghostty default | `Cmd+Shift+V` | paste_from_selection | core; selection pasteboard is `NSPasteboard.terminalSelection` (`GhosttyRuntime.swift`) | ✅ | — |
| Ghostty default | `Cmd+Shift+J` (and the Ctrl/Opt variants) | write_screen_file paste / copy / open | core; `open` goes through `OPEN_URL` (`GhosttyRuntime.swift:381`) | ✅ | — |
| Ghostty default | `Shift+←→↑↓/PgUp/PgDn/Home/End` | adjust_selection | core (only once a selection exists) | ✅ | — |

## 4. Vim-aware navigation (tmux `is_vim` root bindings, plus Ghostty's Cmd→Ctrl)

term path: monitor `TermController.swift:74` (and, from `d90a74f`, `TerminalWindow.swift:48-55`) → `handleKey` `:314` → `route` `:325` → `KeyRouter` vim-aware lookup (`Keymap.swift`, `route` `lookup(.vimAware…)`) → `KeyDecider.resolve` `Keymap.swift:441`.

Vim detection: `ProcessInspector.isVimRunning` (`ProcessInspector.swift:60`, same regex as tmux.nix:87) on the pane's shell pid from `zmx ls`. I confirmed the pid is the zsh on the session's pty, so detection is sound.

| Source | Key | Ghostty+tmux did | term does (handler) | Status | Fix |
|---|---|---|---|---|---|
| tmux.nix:90 | `Ctrl+H` | vim → C-h to vim; otherwise select-pane -L (wraps; a no-op in one pane). The shell never received ^H | `keymap.json:34`. Moves focus if a split exists to the left. **Edge or single pane → ^H to zsh = `backward-kill-word`** | ⚠️ | `KeyDecider`: when no vim and `!canPerform`, return `.consumed`, or wrap |
| tmux.nix:91 | `Ctrl+J` | same, down | `keymap.json:35`. Edge or single pane → ^J = zsh `end-of-line` | ⚠️ | (same) |
| tmux.nix:92 | `Ctrl+K` | same, up | `keymap.json:36`. Edge or single pane → ^K = **kill to end of line** | ⚠️ | (same) |
| tmux.nix:93 | `Ctrl+L` | same, right | `keymap.json:37`. Edge or single pane → ^L = clear screen | ⚠️ | (same) |
| ghostty.nix:41 + tmux | `Cmd+H` | ^H → as `Ctrl+H` above | `keymap.json:38`. The router claims it first. In the installed 19:03 build, and at HEAD in single-pane tabs or at an edge, it passes through → Ghostty `text:\x08` → word delete. On an empty prompt that looks like **"Cmd+h does nothing"** | ⚠️ | Rebuild (`just app-install`) **and** apply the KeyDecider fix |
| ghostty.nix:42 + tmux | `Cmd+J` | ^J → pane down | `keymap.json:39`; same failure mode (^J end-of-line, invisible) | ⚠️ | (same) |
| ghostty.nix:43 + tmux | `Cmd+K` | ^K → pane up | `keymap.json:40`; same failure mode (^K kill-line, invisible on an empty prompt) | ⚠️ | (same) |
| ghostty.nix:44 + tmux | `Cmd+L` | ^L → pane right | `keymap.json:41`; same failure mode (^L clears the screen) | ⚠️ | (same) |
| tmux.nix:95 (commented out) | `Ctrl+\` | (disabled) | Ghostty passthrough ^\ | ✅ | — |
| tmux behaviour | in nvim/vim/fzf | key forwarded to vim | `vimInForeground` → `.toTerminal` (`TermController.swift:348`); for Cmd variants Ghostty converts to ^H…, the same bytes tmux delivered. No vim-tmux-navigator in the config, so this matches | ✅ | — |

## 5. Right Option (Karabiner)

Term rules: `rules.ts:327-367` (`termRopt`, `termRightOptionManipulators`), wired at `rules.ts:943`. All 30 `Term:` manipulators are present in `karabiner.json`, which matches `~/.config/karabiner/karabiner.json`, and the bundle id `dev.rakshan.term` matches Term.app. Ghostty rules: `rules.ts:49-318`.

| Source | Key | Ghostty+tmux did | term does (handler) | Status | Fix |
|---|---|---|---|---|---|
| Karabiner | `ROpt+1`–`9` | ^B N → tmux window N | `Term:` rule ^B N → `keymap.json:58-66` | ✅ | — |
| Karabiner | `ROpt+0` | ^B 0 (no-op with base-index 1) | ^B 0 → 10th tab | ✅ | — |
| Karabiner | `ROpt+\` | ^B v → split right | ^B v → `keymap.json:45` | ✅ | — |
| Karabiner | `ROpt+-` | ^B V → split down | ^B Shift+V → `keymap.json:46` | ✅ | — |
| Karabiner | `ROpt+N` | ^B c → new window | ^B c → `keymap.json:57` | ✅ | — |
| Karabiner | `ROpt+X` | ^B x → kill pane | ^B x → `keymap.json:55` | ✅ | — |
| Karabiner | `ROpt+Z` | `tmux resize-pane -Z` | `term-ctl zoom` | ✅ | — |
| Karabiner | `ROpt+[` | `tmux copy-mode` | `term-ctl search` (find bar, not copy-mode) | ⚠️ | See §7 |
| Karabiner | `ROpt+]` | `tmux paste-buffer` | `term-ctl paste` (clipboard) | ✅ | — |
| Karabiner | `ROpt+,` | tmux swap-window -1 | `term-ctl move-tab left` | ✅ | — |
| Karabiner | `ROpt+.` | tmux swap-window +1 | `term-ctl move-tab right` | ✅ | — |
| Karabiner | `ROpt+I` | copy tmux `#{pane_id}` (`%N`) | `term-ctl copy-pane-id` → zmx session name (`ws.tab.pane`, `TermController.swift:477`) | ✅ | Different format: anything that pastes `%N` into `tmux -t` breaks |
| Karabiner | `ROpt+A` | vigil sidebar toggle | `term-ctl sidebar` (term's own sidebar) | ✅ | — |
| Karabiner | `ROpt+;` | `vigil swap --prev` | **no Term rule** → Option+; with option-as-alt → `ESC ;` typed into the pane | ❌ | Add a `termRopt` (e.g. `workspace` prev or `prev-tab`), or `vk_none` |
| Karabiner | `ROpt+'` | `vigil swap --next` | **no Term rule** → `ESC '` typed into the pane | ❌ | (same) |

## 6. Hyper (Right Cmd) (Karabiner)

| Source | Key | Ghostty+tmux did | term does (handler) | Status | Fix |
|---|---|---|---|---|---|
| rules.ts:515-517 | `Hyper+1/2/3`, **Term frontmost** | (n/a) | `term-ctl workspace work/projects/personal` | ✅ | — |
| rules.ts:518-555 | `Hyper+1/2/3` from **any other app** | open Ghostty + `tmux switch-client` | The Term rule needs Term frontmost, so the Ghostty rule fires and **brings Ghostty forward, not term** | ⚠️ | Drop the `frontmost_application_if` from these three `termHyper` calls. `term-ctl workspace` already activates or launches term |
| rules.ts:1039-1043 | `Hyper+T` (tap) | Ghostty frontmost: tmx popup; otherwise focus Ghostty | Never checks for term: from term **or anywhere else** it opens Ghostty.app | ⚠️ | Term frontmost → `term-ctl picker`; otherwise `open -a Term` |
| rules.ts:495-509 | `Hyper+A` | `tmux display-popup vigil ui` + `open -a Ghostty` | Same command runs: **switches to Ghostty**; the popup appears there | ⚠️ | Term branch: run `vigil ui` in a term tab or popup (needs the new action) |
| rules.ts:610-611 | `Hyper+,` / `Hyper+.` | tmux previous/next window | `term-ctl prev-tab` / `next-tab` | ✅ | — |
| rules.ts:560-561 | `Hyper+Shift+,` / `.` | `tmux swap-pane -s {left-of}` / `{right-of}` (spatial) | `term-ctl swap-pane prev/next` (pane order, not direction) | ✅ | Optional: spatial swap |
| rules.ts:955-956 | `Hyper+S` then `H` / `L` | tmux swap-window ∓1 | `term-ctl move-tab left/right` | ✅ | — |
| rules.ts:1017 | `Hyper+S` (tap) | vigil sidebar toggle | Term frontmost → `term-ctl sidebar.toggle` | ✅ | — |
| rules.ts:1029-1037 | `Hyper+D` then `H/J/K/L` | Cmd+Opt+arrows (Ghostty goto_split, a no-op) | `keymap.json:24-27` `focus` | ✅ | — |
| rules.ts:1029-1032 | `Hyper+D` then `A/C/V` | Cmd+A / C / V | Ghostty select_all / copy / paste | ✅ | — |
| rules.ts:437-480 | `Cmd+Opt+H/J/K/L` | Cmd+Opt+arrows (no-op) | `keymap.json:24-27` `focus` | ✅ | — |
| rules.ts:1004-1007 | `Hyper+H/J/K/L` | arrow keys | arrow keys to the pane | ✅ | — |
| rules.ts:1008-1009 | `Hyper+U` / `Hyper+I` | PageDown / PageUp | sent to the pane (no Ghostty binding) | ✅ | — |

## 7. Copy-mode, search and paste

| Source | Key | Ghostty+tmux did | term does (handler) | Status | Fix |
|---|---|---|---|---|---|
| tmux.nix:44 | copy-mode `v` | begin selection | no keyboard copy mode (libghostty has none) | ❌ | Option: a minimal vi-mode overlay that uses `adjust_selection` and `copy_to_clipboard` |
| tmux.nix:45 | copy-mode `y` | copy selection (OSC 52 → clipboard) | none; use a mouse selection plus Cmd+C | ❌ | (same) |
| tmux.nix:46 | copy-mode `r` | rectangle toggle | none on the keyboard; Ghostty Opt+drag does a rectangle selection | ❌ | (same) |
| tmux.nix:47 | copy-mode `Enter` | copy-pipe to `xclip`, which does not exist on macOS, so it was already broken | none | 🚫 | Remove from tmux.nix |
| tmux.nix:97-101 | copy-mode `C-h/j/k/l`, `C-\` | select-pane from copy mode | n/a (no copy mode) | 🚫 | — |
| tmux default (vi) | copy-mode motions `h j k l w b e 0 $ g G C-u C-d C-b C-f V q Esc` | keyboard scrollback navigation and selection | none; the wheel, Cmd+PgUp/PgDn and Cmd+Home/End scroll | ❌ | (same overlay) |
| tmux default (vi) | copy-mode `/` `?` `n` `N` | search forward/back, next/prev | find bar: type, Enter next, Shift+Enter previous, Esc close (`SearchBar.swift:88-92`) | ✅ | — |
| tmux-open | copy-mode `o` / `C-o` / `S` | open selection / open in $EDITOR / web search | none; Ghostty Cmd+click opens URLs (`OPEN_URL`) | ❌ | Low priority |
| tmux-yank | copy-mode `Y` / `M-y` | put selection on the command line / copy and paste | none | ❌ | Low priority |
| tmux mouse + yank | mouse drag release | copied the selection to the system clipboard | Ghostty `copy-on-select` defaults to `true` (vendored `Config.zig:2400`), which copies only to the *selection* pasteboard (a private `dev.rakshan.term.selection`). **Cmd+V pastes the old clipboard** | ⚠️ | Add `copy-on-select = clipboard` to `ghostty.nix` |
| tmux user | prefix `P` / prefix `]` / `ROpt+]` / `Cmd+V` | paste | `paste` → `paste_from_clipboard` (`TermController.swift:473`) | ✅ | — |

## 8. Mouse

| Source | Key | Ghostty+tmux did | term does (handler) | Status | Fix |
|---|---|---|---|---|---|
| tmux default (mouse on) | click a pane | select pane | `PaneView.onFocus` (`SplitViews.swift:69`) | ✅ | — |
| tmux default | drag a border | resize pane | `SplitContainerView` divider drag (`onRatio`) | ✅ | — |
| tmux default | wheel up/down | enter copy-mode and scroll | Ghostty native scrollback. History only covers what the surface has received since it attached | ✅ | Check how much zmx replays on reattach |
| tmux default | double / triple click | select word / line and copy | Ghostty selects; the copy goes to the selection pasteboard only (see §7) | ⚠️ | `copy-on-select = clipboard` |
| tmux default | right-click on a pane | tmux context menu | Ghostty right-click (passed to the program when it captures the mouse); no menu | 🚫 | — |
| tmux default | click / wheel on the status-bar window list | select / cycle window | sidebar rows (`Sidebar.swift`) | ✅ | — |
| tmux.nix:186 | click status-right | `vigil ui --usage` popup | none; term has no usage segment | ❌ | Add a vigil usage segment or click-target to the sidebar header |
| Ghostty default | Cmd+click a URL | open link | `OPEN_URL` → `NSWorkspace.open` (`GhosttyRuntime.swift:381`) | ✅ | — |
| apps | mouse reporting (vim, htop, …) | passed through by tmux | libghostty | ✅ | — |

## 9. zsh line editor (zsh.nix:184-193, vi-mode plugin)

| Source | Key | Ghostty+tmux did | term does (handler) | Status | Fix |
|---|---|---|---|---|---|
| zsh.nix:190 | `^P` (Ctrl+P or Cmd+P) | up-line-or-search | router passthrough → pty | ✅ | — |
| zsh.nix:191 | `^N` (Ctrl+N or Cmd+N) | down-line-or-search | passthrough | ✅ | — |
| zsh.nix:192 | `^H` backward-kill-word | **never reached zsh**: tmux took C-h. Backspace sends ^? | reaches zsh whenever Ctrl/Cmd+H finds no split (single pane or edge), so you **delete a word when you meant to change pane** | ⚠️ | Fix §4 (consume at the edge) |
| zsh.nix:193 | `^J` end-of-line | never reached zsh (tmux took C-j) | reaches zsh at an edge or in a single pane | ⚠️ | Fix §4 |
| zsh default | `^K` kill-line / `^L` clear-screen | unreachable via C-k / C-l under tmux | reachable at an edge or in a single pane (see §4) | ⚠️ | Fix §4 |
| zsh.nix:132,184 | `Esc` (vi-mode, KEYTIMEOUT=1) | to zsh | Ghostty `escape=end_search` is performable, so Esc passes through when no search is open | ✅ | — |
| zsh / option-as-alt | `Opt+<key>` (M-b, M-f, M-., …) | ESC-prefixed to zsh | Ghostty `macos-option-as-alt` passthrough, except `Opt+Space` (search, as in tmux) | ✅ | — |
| zsh default | `^R` `^A` `^E` `^W` `^U` `^X…` `^S`/`^Q` | to zsh | passthrough | ✅ | — |
| zsh default | `^B` backward-char | lost to the tmux prefix | lost to the term prefix (`keymap.json:6`); prefix twice sends it | ✅ | — |

## Status counts

| Status | Rows |
|---|---|
| ✅ works by design | 105 |
| ⚠️ likely broken or behaves differently | 22 |
| ❌ missing | 35 |
| 🚫 intentionally dropped / n.a. | 14 |

(Counted per table row. The rows that only point to §4, marked "—", are not counted.)

## Prioritized fix list

### P0: daily muscle memory broken

1. **Reinstall term.** Run `just app-install` in `~/projects/swift/term`. The running binary (19:03) is missing `d90a74f`, which lets the router refuse chords before Ghostty and menus in `TerminalWindow`, and `ec62988`, which fixes the cursor so a pane move is visible.
2. **Vim-aware keys must not fall through to the shell when no vim is running.**
   - Affects: `Ctrl/Cmd+H/J/K/L` in single-pane tabs (27 of 28 tabs) and at split edges.
   - Today they send ^H/^J/^K/^L to zsh. That deletes a word, kills to the end of the line, or clears the screen, and on an empty prompt it looks like "Cmd+h does nothing".
   - Fix: in `KeyDecider.resolve` (`Sources/TermCore/Keymap.swift:441-444`), turn the `!canPerform` case into `.consumed`. Optionally wrap around like tmux's `select-pane`.
   - Update the README line ("…or at an edge") and the KeyResolution tests to match.
3. **Global summon goes to Ghostty, not term.**
   - `Hyper+1/2/3` from another app opens Ghostty plus tmux, because `termHyper` requires Term to be frontmost.
   - `Hyper+T` always opens Ghostty.app.
   - Fix: make the three `termHyper` workspace rules unconditional (`rules.ts:515-517`; `term-ctl workspace` launches/activates term). Rewrite `Hyper+T`'s `alone` (`rules.ts:1043`) to use Term.
4. **Drag-select no longer reaches the clipboard.** Add `copy-on-select = clipboard` to `ghostty.nix`. term loads this config, so the change applies inside term; it also changes Ghostty.app's own behaviour.

### P1: used regularly, with a workaround

5. `Hyper+A` and prefix `a` (vigil popup): add a term action that runs a command in a popup or new tab. Branch `Hyper+A` on Term frontmost (`rules.ts:495-509`).
6. Keyboard copy-mode (`M-Space`, prefix `[`, `ROpt+[`, `v`/`y`/`r`, vi motions): today these open only a find bar. Either build a small vi selection mode on libghostty's `adjust_selection` and `copy_to_clipboard`, or re-learn the mouse plus `Cmd+C`.
7. `ROpt+;` and `ROpt+'` type `ESC ;` / `ESC '` into the pane: add `Term:` rules or `vk_none`.
8. Prefix timeout of 1 s (`keymap.json:3`): tmux has none. Raise it, or support "no timeout".
9. Prefix `/` (copycat search) and prefix arrow keys (select-pane): one-line `keymap.json` additions.

### P2: completeness

10. tmux default aliases: `o`, `;`, `%`, `"`, `&`, `{`, `}`, `f`, `q`, `!`, `(`, `)`, `?`, prefix `C-arrows`.
11. Ghostty default actions that are swallowed by `GhosttyRuntime.swift:394`:
    - `Cmd+Shift+D` (split down)
    - `Cmd+[` / `Cmd+]` (pane cycle)
    - `Cmd+Ctrl+=` (equalize)
    - `Cmd+Enter` / `Cmd+Ctrl+F` (fullscreen)
    - `Cmd+Opt+W` (close tab)
    - `Cmd+,` (open config)
    - `Cmd+Shift+P` (palette)

    Handle them or map them to term commands.
12. `Cmd+G` / `Cmd+Shift+G` inside the search field (`SearchBar.swift`).
13. Status-right click → vigil usage; prefix `y` / `Y` (yank cmdline/cwd); Hyper+Shift+`,`/`.` spatial swap; `copy-pane-id` format (`%N` vs session name) for any scripts that expect tmux ids.
14. Clean up tmux.nix: the copy-mode `Enter` → `xclip` binding was already dead on macOS.
