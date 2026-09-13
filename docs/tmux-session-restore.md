# Restore tmux and AI conversations after a restart

Home Manager configures tmux-resurrect to save windows, pane layouts, working
directories, and terminal contents. Continuum saves every 15 minutes and restores
when a new tmux server starts. Vigil attaches native conversation IDs to those
snapshots so supported AI conversations can reopen in their original panes.

## Everyday use

- Before a planned restart, press **Ctrl+B**, release, then **Ctrl+S** to save now.
- After restarting, open a terminal and run `tmux`. Allow automatic restoration
  to finish before creating your usual windows.
- To restore manually, press **Ctrl+B**, release, then **Ctrl+R**.

The three hooks in `nixpkgs/home-manager/modules/tmux.nix` run
`vigil restore save`, `vigil restore prepare`, and `vigil restore apply`.
Conversation metadata is stored in a `.vigil.json` sidecar next to its saved
layout in the tmux-resurrect directory (normally `~/.tmux/resurrect`). Keep the
sidecar with its layout when backing up or choosing an older snapshot.

Claude Code, Codex, and OpenCode use their exact native conversation IDs supplied
to Vigil by agent hooks. This does not use “continue latest” and does not require
changes to the `c` launcher. Agy is not covered because Vigil does not yet have its
conversation identity adapter. Conversations missing a reliable live mapping are
skipped. Older snapshots made before this integration have no conversation map.

Restoration only launches into newly recreated shell panes. Existing or busy
panes are skipped. A reboot still interrupts running work; resuming a conversation
does not checkpoint or recover an in-flight tool process. Agent permissions use
the native CLI defaults; the restore integration does not add bypass flags.

## Development

Implementation and isolated integration tests live in
`~/projects/rust/vigil`. Follow that repository's `AGENTS.md` and
`skills/vigil-dev-loop/SKILL.md`. Never test restoration against the live server.
Build/install Vigil before activating these Home Manager hooks.
