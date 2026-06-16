{
  lib,
  ...
}:

{
  # Global agent instruction files (AGENTS.md / CLAUDE.md), managed from the
  # private dotfiles repo so the content stays out of this public file.
  #
  # Source of truth (edit these, then `just agents` — or `rr nix switch`):
  #   private/extras/agents/shared.md  -> shared instructions for every agent
  #   private/extras/agents/claude.md  -> Claude-only preamble
  #   private/extras/agents/codex.md   -> Codex-only preamble
  #
  # AGENTS.md  = codex preamble  + shared
  # CLAUDE.md  = claude preamble + shared
  #
  # The generation logic lives in bin/sync-agents so it can run instantly via
  # `just agents` without a full flake eval. Activation just calls that script.
  home.activation.agentInstructions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x "$HOME/dotfiles/bin/sync-agents" ]; then
      "$HOME/dotfiles/bin/sync-agents"
    fi
  '';
}
