#!/bin/bash
# tmux-agent-monitor — plugin entry point (for non-Nix installs)
# If using Nix/home-manager, the keybinding and status-right are set in tmux.nix

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

# Keybinding: prefix + a to open the agent session switcher
tmux bind-key a display-popup -E -w 80% -h 60% "$SCRIPTS_DIR/switcher.sh"

# Prepend Claude status widget to status-right
current_status_right=$(tmux show-option -gqv status-right)
tmux set-option -g status-right "#($SCRIPTS_DIR/status.sh)${current_status_right}"

# Ensure status-interval is reasonable for live updates
current_interval=$(tmux show-option -gqv status-interval)
if [ "${current_interval:-15}" -gt 10 ]; then
  tmux set-option -g status-interval 5
fi
