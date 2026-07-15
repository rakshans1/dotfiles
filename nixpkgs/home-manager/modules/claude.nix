{
  config,
  lib,
  pkgs,
  ...
}:

let
  # vigil is the single hook consumer for all agent state (see
  # ~/projects/rust/vigil). Nix re-applies these on every switch, so a tool
  # that rewrites settings.json is healed by the next rr nix switch.
  #
  # M5.15: hooks reference the committed late-binding wrapper `bin/vigil-hook`
  # (NOT a concrete binary path) — it re-resolves the vigil binary on every fire
  # across candidate locations and exits 0 silently if none is found, so a
  # rebuild / move / mid-rebuild never breaks or blocks the agent. The wrapper
  # itself runs `vigil signal "$@"`, so the command is just the wrapper path
  # (plus any extra flags, which are forwarded).
  vigilHook = [
    {
      matcher = "";
      hooks = [
        {
          type = "command";
          command = "$HOME/projects/rust/vigil/bin/vigil-hook";
        }
      ];
    }
  ];

  # M5.5 permission actuation (opt-in, enabled 2026-07-14): PermissionRequest
  # blocks on --actuate until y/n from the vigil panel (or `vigil permission
  # allow/deny`); on timeout it emits nothing and Claude falls back to its own
  # prompt. The hook timeout must exceed vigil's internal wait (doctor checks).
  # M5.15: via the wrapper — `--actuate` is forwarded to `vigil signal`.
  vigilPermissionHook = [
    {
      matcher = "";
      hooks = [
        {
          type = "command";
          command = "$HOME/projects/rust/vigil/bin/vigil-hook --actuate";
          timeout = 86400;
        }
      ];
    }
  ];

  # Static keys managed by Nix. Claude's runtime-written settings are left
  # untouched by the deep merge below unless they overlap with these keys.
  managed = {
    permissions = {
      allow = [
        "Read(~/.zshrc)"
      ];
      deny = [ ];
    };
    includeCoAuthoredBy = false;
    tui = "fullscreen";
    # M8d: vigil owns the (previously empty) statusline slot — it captures per-session
    # context% + live cost for the popup/sidebar chip and prints back a statusline
    # (model · ctx NN% · $X.XX). Routed through the late-binding wrapper so a
    # missing/rebuilding binary can't break Claude's TUI. Needs `rr nix switch`.
    statusLine = {
      type = "command";
      command = "$HOME/projects/rust/vigil/bin/vigil-hook-statusline";
      padding = 0;
    };
    env = {
      CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1";
      CLAUDE_CODE_ENABLE_TELEMETRY = "0";
      DISABLE_AUTOUPDATER = "1";
      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
    };
    hooks = {
      UserPromptSubmit = vigilHook;
      Stop = vigilHook;
      Notification = vigilHook;
      PermissionRequest = vigilPermissionHook;
      # M5.12: SubagentStart pairs with SubagentStop to drive exact, id-keyed
      # live-subagent tracking (the delegating overlay). Needs `rr nix switch`.
      SubagentStart = vigilHook;
      SubagentStop = vigilHook;
      # M5.14: new agent-state events. PermissionDenied (auto-mode denied a tool;
      # the turn continues → vigil records activity) and StopFailure (the turn
      # ended on an API error — rate_limit/overloaded/auth; vigil lands the row in
      # needs_input and shows the error_type as a dim chip). Needs `rr nix switch`.
      PermissionDenied = vigilHook;
      StopFailure = vigilHook;
      PostToolUse = vigilHook;
      SessionStart = vigilHook;
      SessionEnd = vigilHook;
      PreCompact = vigilHook;
    };
    enabledPlugins = {
      "code@personal" = true;
      "cc@personal" = true;
      "git@personal" = true;
      "rr@personal" = true;
    };
    extraKnownMarketplaces = {
      personal = {
        source = {
          source = "directory";
          path = "$HOME/projects/ai/cc";
        };
      };
    };
    skipDangerousModePermissionPrompt = true;
  };

  managedJson = builtins.toJSON managed;
in
{
  # Claude Code configuration managed by Nix

  # Apply managed Claude Code settings without replacing runtime-written keys.
  home.activation.claudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.claude
    chmod 755 $HOME/.claude

    SETTINGS=$HOME/.claude/settings.json
    [ -f "$SETTINGS" ] || printf '{}\n' > "$SETTINGS"

    ${pkgs.jq}/bin/jq --argjson managed '${managedJson}' '. * $managed' \
      "$SETTINGS" > "$SETTINGS.merged"
    mv "$SETTINGS.merged" "$SETTINGS"

    # Merge in optional private overlay (org-specific marketplaces + plugins).
    # The overlay file is kept in the private dotfiles repo; if absent, nothing
    # happens. Keeps any org-private URLs out of this public file.
    OVERLAY=$HOME/dotfiles/private/extras/claude.json
    if [ -r "$OVERLAY" ]; then
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' \
        "$SETTINGS" "$OVERLAY" \
        > "$SETTINGS.merged"
      mv "$SETTINGS.merged" "$SETTINGS"
    fi

    chmod 644 "$SETTINGS"
    echo "Successfully applied managed Claude Code configuration"
  '';
}
