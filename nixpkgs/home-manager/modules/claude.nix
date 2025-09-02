{ config, pkgs, ... }:

{
  # Helper function script for Claude Code status line
  home.file.".claude/statusline.sh" = {
    text = ''
      #!/bin/bash

      # Read JSON input from stdin
      input=$(cat)

      # Extract values from JSON
      model_name=$(echo "$input" | jq -r '.model.display_name')
      cost=$(echo "$input" | jq -r '.cost.total_cost_usd // "0.00"')
      lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
      lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

      # Format lines with colors and +/- symbols
      lines_display=""
      if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
        if [ "$lines_added" -gt 0 ]; then
          lines_display+="\e[32m+$lines_added\e[0m"
        fi
        if [ "$lines_removed" -gt 0 ]; then
          if [ -n "$lines_display" ]; then
            lines_display+=" "
          fi
          lines_display+="\e[31m-$lines_removed\e[0m"
        fi
      else
        lines_display="0"
      fi

      # Format the output as a single line with separators
      echo -e "\e[2m$model_name | $lines_display \$$cost\e[0m"
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
