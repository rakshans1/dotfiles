{ config, pkgs, ... }:

{
  # Helper function script for Claude Code status line
  home.file.".claude/statusline.sh" = {
    text = ''
      #!/bin/bash
      
      # Read JSON input from stdin
      input=$(cat)
      
      # Extract values from JSON
      current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
      model_name=$(echo "$input" | jq -r '.model.display_name')
      cost=$(echo "$input" | jq -r '.cost.total_cost_usd // "0.00"')
      lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
      lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
      
      # Replace home directory path with ~
      home_dir="$HOME"
      if [[ "$current_dir" == "$home_dir"* ]]; then
        current_dir="~''${current_dir#$home_dir}"
      fi
      
      # Format lines with colors and +/- symbols
      lines_display=""
      if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
        if [ "$lines_added" -gt 0 ]; then
          lines_display+="\033[32m+$lines_added\033[0m"
        fi
        if [ "$lines_removed" -gt 0 ]; then
          if [ -n "$lines_display" ]; then
            lines_display+=" "
          fi
          lines_display+="\033[31m-$lines_removed\033[0m"
        fi
      else
        lines_display="0"
      fi
      
      # Format the output as a single line with separators
      printf "\033[2m%s ◊ %s | %s $%s\033[0m" "$current_dir" "$model_name" "$lines_display" "$cost"
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
