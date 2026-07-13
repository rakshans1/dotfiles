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
  vigilHook = [
    {
      matcher = "";
      hooks = [
        {
          type = "command";
          command = "$HOME/projects/rust/vigil/.nix-cargo/bin/vigil signal";
        }
      ];
    }
  ];

  # M5.5 permission actuation (opt-in, enabled 2026-07-14): PermissionRequest
  # blocks on --actuate until y/n from the vigil panel (or `vigil permission
  # allow/deny`); on timeout it emits nothing and Claude falls back to its own
  # prompt. The hook timeout must exceed vigil's internal wait (doctor checks).
  vigilPermissionHook = [
    {
      matcher = "";
      hooks = [
        {
          type = "command";
          command = "$HOME/projects/rust/vigil/.nix-cargo/bin/vigil signal --actuate";
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
      SubagentStop = vigilHook;
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
