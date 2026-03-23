#!/bin/bash
# Claude Code lifecycle hook — writes session state to cache files.
# Registered in ~/.claude/settings.json for events:
#   UserPromptSubmit, PreToolUse, Stop, Notification, PermissionRequest
#
# Each invocation reads JSON from stdin and writes a state file to
# ~/.cache/tmux-agent-monitor/pid-<PID>.json

set -o pipefail

STATE_DIR="$HOME/.cache/tmux-agent-monitor"
mkdir -p "$STATE_DIR"

# Read event JSON from stdin
input=$(cat)

# Extract event type — Claude hooks pass hook_event_name in the JSON
event_type=$(echo "$input" | grep -o '"hook_event_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"hook_event_name"[[:space:]]*:[[:space:]]*"//' | sed 's/"//')

# Determine status from event type
case "$event_type" in
  UserPromptSubmit|PreToolUse)
    status="working"
    ;;
  Stop|Notification|SubagentStop)
    status="idle"
    ;;
  PermissionRequest)
    status="needs_input"
    ;;
  *)
    exit 0
    ;;
esac

# Gather context
pid="$$"
claude_pid="${PPID:-$$}"
pane_id="${TMUX_PANE:-}"
nvim_socket="${NVIM:-}"
cwd="$(pwd)"
timestamp="$(date +%s)"

# Get project name: git repo name if available, otherwise directory basename
project=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null) || project=$(basename "$cwd")

# Extract session_id from the hook input
session_id=$(echo "$input" | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"session_id"[[:space:]]*:[[:space:]]*"//' | sed 's/"//')

# Extract title from the first user prompt if this is a UserPromptSubmit
title=""
if [ "$event_type" = "UserPromptSubmit" ]; then
  title=$(echo "$input" | grep -o '"prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"prompt"[[:space:]]*:[[:space:]]*"//' | sed 's/"//')
  # Sanitize: strip control chars, newlines, quotes, backslashes; truncate
  title=$(printf '%s' "$title" | tr -d '\n\r\\"' | tr -cd '[:print:]' | cut -c1-60)
fi

# Try to get the actual claude process PID (our parent)
# Walk up to find the claude process
_find_claude_pid() {
  local p="$claude_pid"
  local max=5
  while [ "$max" -gt 0 ]; do
    local cmd
    cmd=$(ps -p "$p" -o comm= 2>/dev/null) || break
    if echo "$cmd" | grep -qi "claude"; then
      echo "$p"
      return
    fi
    p=$(ps -p "$p" -o ppid= 2>/dev/null | tr -d ' ') || break
    [ -z "$p" ] || [ "$p" = "1" ] && break
    max=$((max - 1))
  done
  echo "$claude_pid"
}

claude_pid=$(_find_claude_pid)

# Write state file keyed by the claude process PID
state_file="$STATE_DIR/pid-${claude_pid}.json"

# Preserve existing title if we don't have a new one
if [ -z "$title" ] && [ -f "$state_file" ]; then
  title=$(grep -o '"title":"[^"]*"' "$state_file" 2>/dev/null | head -1 | sed 's/"title":"//' | sed 's/"//' || true)
  title=$(printf '%s' "$title" | tr -d '\n\r\\"' | tr -cd '[:print:]' | cut -c1-60 || true)
fi

# Build JSON manually (no jq dependency)
cat > "${state_file}.tmp" <<EOF
{"status":"${status}","pid":${claude_pid},"pane":"${pane_id}","nvim_socket":"${nvim_socket}","cwd":"${cwd}","project":"${project}","session_id":"${session_id}","title":"${title}","timestamp":${timestamp}}
EOF

mv "${state_file}.tmp" "$state_file"

# Force tmux status bar refresh
tmux refresh-client -S 2>/dev/null || true
