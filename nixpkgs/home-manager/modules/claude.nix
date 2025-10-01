{ ... }:
{
  # Helper function script for Claude Code status line
  home.file.".claude/statusline.sh" = {
    text = ''
      input=$(cat)
      echo "$input" | ccusage statusline
    '';
    executable = true;
  };

  home.file.".claude/settings.json".text = ''
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
        "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
        "DISABLE_AUTOUPDATER": "1"
      },
      "statusLine": {
        "type": "command",
        "command": "~/.claude/statusline.sh"
      }
    }
  '';
}
