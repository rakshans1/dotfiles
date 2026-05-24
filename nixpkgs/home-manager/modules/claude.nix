{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Claude Code configuration managed by Nix

  # Generate Claude Code settings.json dynamically (writable)
  home.activation.claudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.claude
        chmod 755 $HOME/.claude

        # Generate settings.json
        cat > $HOME/.claude/settings.json <<'EOF'
    {
      "permissions": {
        "allow": [
          "Read(~/.zshrc)"
        ],
        "deny": [
        ]
      },
      "includeCoAuthoredBy": false,
      "tui": "fullscreen",
      "env": {
        "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1",
        "CLAUDE_CODE_ENABLE_TELEMETRY": "0",
        "DISABLE_AUTOUPDATER": "1",
        "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
      },
      "hooks": {
        "UserPromptSubmit": [
          {
            "matcher": "",
            "hooks": [{"type": "command", "command": "$HOME/dotfiles/config/tmux-agent-monitor/scripts/hook.sh"}]
          }
        ],
        "Stop": [
          {
            "matcher": "",
            "hooks": [{"type": "command", "command": "$HOME/dotfiles/config/tmux-agent-monitor/scripts/hook.sh"}]
          }
        ],
        "Notification": [
          {
            "matcher": "",
            "hooks": [{"type": "command", "command": "$HOME/dotfiles/config/tmux-agent-monitor/scripts/hook.sh"}]
          }
        ],
        "PermissionRequest": [
          {
            "matcher": "",
            "hooks": [{"type": "command", "command": "$HOME/dotfiles/config/tmux-agent-monitor/scripts/hook.sh"}]
          }
        ],
        "SubagentStop": [
          {
            "matcher": "",
            "hooks": [{"type": "command", "command": "$HOME/dotfiles/config/tmux-agent-monitor/scripts/hook.sh"}]
          }
        ]
      },
      "enabledPlugins": {
        "code@personal": true,
        "cc@personal": true,
        "git@personal": true,
        "rr@personal": true
      },
      "extraKnownMarketplaces": {
        "personal": {
          "source": {
            "source": "directory",
            "path": "$HOME/projects/ai/cc"
          }
        }
      },
      "skipDangerousModePermissionPrompt": true
    }
    EOF

        # Merge in optional private overlay (org-specific marketplaces + plugins).
        # The overlay file is kept in the private dotfiles repo; if absent, nothing
        # happens. Keeps any org-private URLs out of this public file.
        OVERLAY=$HOME/dotfiles/private/extras/claude-overlay.json
        if [ -r "$OVERLAY" ]; then
          ${pkgs.jq}/bin/jq -s '.[0] * .[1]' \
            $HOME/.claude/settings.json "$OVERLAY" \
            > $HOME/.claude/settings.json.merged
          mv $HOME/.claude/settings.json.merged $HOME/.claude/settings.json
        fi

        chmod 644 $HOME/.claude/settings.json
        echo "Successfully generated Claude Code configuration"
  '';
}
