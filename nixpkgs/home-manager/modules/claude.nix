{
  config,
  lib,
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
      "env": {
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
        "PreToolUse": [
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
      }
    }
    EOF

        chmod 644 $HOME/.claude/settings.json
        echo "Successfully generated Claude Code configuration"
  '';
}
