# zmx spike report

Date: 2026-10-29. Host: macOS arm64 (Darwin 25.6). Nothing installed, no dotfiles edited, user tmux untouched, no AI agents run.

## Version

- Tested: **zmx 0.8.1** (ghostty_vt `ghostty-1.3.2-dev`), from `nixpkgs-unstable` @ e62746b (store path built via `nix build github:NixOS/nixpkgs/nixpkgs-unstable#zmx`).
- **The dotfiles flake pins do not have zmx.** `flake.lock` `nixpkgs` = rev fef9403 (26.05pre942631) -> no `zmx` attribute. `nixpkgsUnstable` pin (567a49d, nixpkgs-weekly) -> also no `zmx`. Also `nix shell nixpkgs#zmx` resolves via the system registry to a local path flake that lacks it, so use the explicit `github:NixOS/nixpkgs/nixpkgs-unstable#zmx`. To adopt: bump `nixpkgsUnstable` (zmx 0.8.1 exists in current unstable) or add a package from upstream.

## Setup

`ZMX_DIR=/tmp/spike/zmx`, `ZMX_SESSION_PREFIX=spike.`, `SHELL=/bin/bash` for most runs (the user's zsh/p10k-style prompt garbles captured output, see surprises). Headless client = python `pty.fork()` running `zmx attach`, killed with SIGKILL to simulate closing a Ghostty window. Scripts in `/tmp/spike/` (throwaway). All spike sessions killed at end; no daemons left.

## Results

| # | Test | Result | Notes / timings |
|---|------|--------|-----------------|
| 1 | attach creates session; client kill leaves it alive; reattach restores | PASS | `ls` shows `clients=0` after SIGKILL of client. Reattach replays full screen state (VT sequences, prompt, cursor) immediately. |
| 2a | `run` blocking: `true`/`false`/subshell exit | PASS | rc propagated (0/1/3/5/6/4). ~0.03-0.04s round trip. |
| 2b | `run` 5s command | PASS | blocks ~5s, returns rc. |
| 2c | `run` 10k lines (2 MB) | PASS | all lines streamed, 0.04s. |
| 2d | `run -d` + `wait` | PASS | `run -d` returns in ~10ms ("command sent!"); `wait` blocks to completion, rc = task exit code, prints last 20 lines of history on failure. |
| 2e | `run` while session busy | **QUEUES** | Second `run` blocked 4.0s behind a `sleep 4`; its output also included the *previous* task's marker line (cross-talk). Commands are literally typed into the shell, so they queue in the tty buffer. |
| 2f | `run exit 3` | **DESTROYS SESSION SHELL** | Command runs *in* the live shell; `exit` kills it (prints `logout`), rc lies (0). Session disappears from `ls` (or is recreated by next `run`). Use `sh -c '...; exit 3'` or a subshell. |
| 2g | `run` with multi-word string | GOTCHA | `zmx run s 'a; b'` (one arg) is shell-quoted -> "command not found". Compound commands need `zmx run s sh -c '...'` or stdin: `printf 'a; b' \| zmx run s`. Several args are joined with quoting (`;` becomes literal). |
| 2h | `run cat` (interactive stdin) | HANG | Docs say stdin is /dev/null; in practice `cat` blocked on the PTY forever. Needed `zmx send s ^C`. |
| 2i | ctrl-C of a `run` task | **WEDGES `wait`/`run`** | `cmd; echo MARKER:$?` is one line, so ^C aborts the marker too; the task never completes, `wait` hangs. Next successful `run` clears it. |
| 3 | `send` raw | PASS | No newline added. Enter = `\r` (also bare `\n` works in bash). Ctrl-C = `$(printf '\x03')`. Multi-line via `printf 'a\rb\r' \| zmx send s`, heredocs work. No session -> error rc=1 (does not create). |
| 4a | `history` plain / `--vt` / `--html` | PASS | ~3-10ms each. plain 60 KB, `--vt` 70 KB (SGR/OSC kept), `--html` 68 KB (`<style>` palette header + spans). |
| 4b | `history --screen` | NOT A FLAG in 0.8.1 | Help lists only `--vt\|--html`; `--screen` accepted silently and returns the same as plain (scrollback + screen). |
| 4c | scrollback depth | ~**10,000 lines** | 50k lines generated; kept 39992..50000 (10,009 lines). No env/flag to change (none found in binary). Plain output is rendered text with `\r\n`. |
| 5a | `tail` | PASS | Follows new output only (no history replay); exits 0 when session killed or its shell exits. |
| 5b | `wait` semantics | see notes | Only tracks `run` tasks (marker-based). Idle session with no task: returns immediately with *last* result. Jobs started via `send`: not tracked (returns stale last result). `wait nosuch`: rc=2 after 2s retry. Multiple sessions: rc=1 if any failed, prints failing task + last 20 history lines. Polls ~2s granularity? (`wait` after a 2s `sleep` returned at 2.0s.) |
| 6a | labels set/get/clear | PASS | Values/keys limited to `[a-zA-Z0-9-_.]`: no spaces, no `=`, no unicode (error, rc=1). 3000-char value accepted. `set k=` removes. `set` with a space-containing arg silently keeps only the part before the space. In-memory, lost with session. |
| 6b | labels in `ls` | PASS | Appended as tab-separated `k=v` after `cwd=`, sorted alphabetically. |
| 6c | `ls` format | | `  name=<prefix+name>\tpid=<shell pid>\tclients=<n>\tcreated=<epoch>\tcwd=<file://host/path>[\tended=<epoch>\texit_code=<n>][\tcmd=<command>][\t<labels>]`. Two leading spaces. `--short` = names only (prefix included). `ended`/`exit_code` present after the last `run` task finished (absent while a task is in flight or before any). `pid` is the shell pid, not the daemon. |
| 6d | `attach --labels "a=b c=d"` | PASS | Atomic at creation. |
| 7 | `ZMX_SESSION` | PASS | Set to the full name **including prefix** (`spike.w3`). `ZMX_SESSION_PREFIX`, `ZMX_DIR` also exported into the session. `.` resolves to current session (error outside one). |
| 8 | python http.server in session | PASS | Served 200 before/after client kill. `zmx kill` -> port refused, process tree gone. |
| 8b | kill of HUP-ignoring tree | **PARTIAL** | `kill` = SIGHUP to the shell; `--force` = SIGKILL to the shell only. `nohup sleep &` and `trap '' HUP TERM` children **survive and reparent to PID 1**, even with `--force`. |
| 9 | nvim 0.12.4 in session | PASS w/ caveat | Started via `send`, quit via `send ':q!\r'`; reattach output clean (266 B, no alt-screen/mouse modes left on). **Ctrl-\ detaches the client even inside nvim** (steals nvim's `<C-\><C-n>`); `ZMX_NO_DETACH_KEY=1` passes it through. Reattach during nvim restores alt-screen + mouse/focus/paste modes (1049, 1002, 1004, 1006, 2004). nvim logged `E1568: terminal did not respond to DSR background` under my fake terminal: unverified in real Ghostty. |
| 10 | 60 sessions (`run -d sleep 3000`) | PASS | Create: 0.94s total. **zmx daemon RSS ~3.9 MB each, 233 MB for 60** (shells extra). `ls` 5ms, `history` 3ms, `set` 3ms with 60 live. |
| 11 | logs | | `$ZMX_DIR/logs/<prefix+name>.log` per session + shared `zmx.log`. These are **daemon diagnostics only** (connect/disconnect lines, errors), not terminal output. 80 files / 512 KB after the whole spike (zmx.log 68 KB, grows with every client connect and every `ls`/`run`). Per-session logs persist after the session dies; no rotation seen. Log dir follows `ZMX_DIR` except `zmx version` itself created an empty `~/.local/state/zmx/logs/zmx.log` before ZMX_DIR was honored (removed). |
| 12 | session started with a command | | `attach s sh -c '...; exit 3'`: `ls` shows `cmd=...`; when the command exits the session **vanishes with no recoverable exit code or history**. |

## Surprises

1. **`run` is typed input into an interactive shell**, not process spawn. Consequences: queues behind a busy session; types into whatever has the foreground (e.g. a running `claude`/nvim); `exit` kills the shell; ^C wedges the marker; user's partial prompt text mangles it.
2. **`run` auto-creates sessions with bash**, not `$SHELL` (bash 3.2/5.3 prompt appeared). Only `attach` honors `$SHELL`. A tab that should be zsh must be created by `attach`.
3. With the user's zsh (fancy prompt + ZLE highlighting) `run` stdout is garbled with backspaces/echo duplicates of the command and redraw bytes; **exit code stays correct** but only if nothing is pending. After a timeout left a half-typed line, a following `false` returned rc 0 (wrong marker association). Do not parse `run` stdout.
4. `run` stdout includes the echoed command and the `ZMX_TASK_COMPLETED:<id>:<rc>` marker line, `\r\n` line endings, and occasionally a truncated first line.
5. `ZMX_SESSION` and `ls` names include the prefix; any wrapper must add/strip it consistently, and the prefix env leaks into children (nested `zmx` calls inside get prefixed again).
6. `kill` does not guarantee tree death (HUP only, shell-only SIGKILL for --force).
7. `--screen` documented in the task but not in 0.8.1.
8. Daemon processes appear in `ps` as `zmx attach <name>` / `zmx run <name> ...` (the creating command line), ppid 1.
9. `wait` has no timeout flag and hangs forever on a wedged task; use `timeout`.

## Verdict

**Viable as the process layer for detached/reattachable agent tabs; not viable as an exec/RPC layer without wrapping.** Detach/reattach restore, send, history (vt/html), tail, labels in `ls`, 60-session scale (~4 MB/daemon, 5 ms ls) all work well and quickly. Weak spots are all in `run`/`wait`/`kill` semantics. Also not in the user's flake pins yet.

## Recommendations for `rr term tab`

- **Naming:** keep a fixed prefix via `ZMX_SESSION_PREFIX` (e.g. `rr.`) only in the rr wrapper, plus slugged `<project>-<n>` names (`[a-z0-9._-]`). Store everything else (title, project, agent, worktree) in labels, restricted to `[A-Za-z0-9._-]` (no spaces/`=`); encode titles (e.g. slug or base64url) and keep a human title elsewhere. Create with `attach --labels ...` (atomic). Always strip the prefix when listing; `ls --short` for scripts, parse tab-separated `ls` for fields.
- **Creating the tab:** must be `zmx attach` (in the Ghostty window) to get `$SHELL`; do not create via `run`.
- **`exec` (finished + exit code):** do not use `zmx run` against a tab hosting an agent. Instead, for tabs that are plain shells, `zmx run <s> sh -c '<cmd>'` (stdin form for compound), take the **process exit code of `zmx run`** (works in blocking mode) and ignore its stdout; for detached use `run -d` then `timeout N zmx wait <s>` (rc = task rc). Alternatively read `ended=` and `exit_code=` from `zmx ls` (absent while in flight; stable after). For long/robust jobs prefer wrapping yourself: `sh -c 'cmd >log 2>&1; echo $? > $f.rc'` and poll the file; this avoids marker/ZLE/queue issues. Guard: check `ls` first, refuse if the foreground is an agent (label `role=agent`), and always use `timeout` around `wait`/`run`.
- **Reading logs/output:** zmx logs are not terminal output. Use `zmx history <s>` (plain; `| tr -d '\r' | tail -N`), `--vt` for colour, `--html` for reports; scrollback caps ~10k lines, so for long output tee to a file in the command. `zmx tail` for live follow (exits when session ends).
- **Sending input:** `printf '...\r' | zmx send <s>`; Enter `\r`, Ctrl-C `\x03`, Esc `\x1b`. For agent prompts send text then a separate `\r`.
- **Killing a tab:** `zmx kill <s>`, then sweep orphans: get `pid=` from `ls` (shell pid) before killing, then after 1s `pkill -TERM -g <pgid>`/`kill -KILL` leftovers (HUP-ignoring `nohup`/trap children survive). Optionally delete `$ZMX_DIR/logs/<name>.log`; add periodic cleanup/rotation of `zmx.log`.
- **Detach key:** set `ZMX_NO_DETACH_KEY=1` in tab environments running nvim/claude if Ctrl-\ matters; otherwise bind detach elsewhere (`zmx detach`).
- **Packaging:** bump `nixpkgsUnstable` or pin zmx explicitly (0.8.1); `nix eval` shows neither current pin carries it.
- **Not tested:** real Ghostty client (terminal queries like nvim's background-colour DSR, resize propagation, clipboard/OSC), multiple simultaneous attached clients, behavior over very long uptimes, claude/codex TUIs.
