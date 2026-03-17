#!/bin/bash
# tmux status bar widget — reads state files and outputs a compact status string.
# Called by tmux on every status-interval refresh.

STATE_DIR="$HOME/.cache/tmux-agent-monitor"

if [ ! -d "$STATE_DIR" ]; then
  exit 0
fi

working=0
idle=0
needs_input=0
total=0

now=$(date +%s)

for f in "$STATE_DIR"/pid-*.json; do
  [ -f "$f" ] || continue

  # Read status and pid from the state file
  status=$(grep -o '"status":"[^"]*"' "$f" | head -1 | sed 's/"status":"//' | sed 's/"//')
  pid=$(grep -o '"pid":[0-9]*' "$f" | head -1 | sed 's/"pid"://')
  ts=$(grep -o '"timestamp":[0-9]*' "$f" | head -1 | sed 's/"timestamp"://')

  # Skip if pid is dead
  if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$f"
    continue
  fi

  # Skip stale entries (older than 1 hour)
  if [ -n "$ts" ] && [ $((now - ts)) -gt 3600 ]; then
    rm -f "$f"
    continue
  fi

  total=$((total + 1))

  case "$status" in
    working)      working=$((working + 1)) ;;
    idle)         idle=$((idle + 1)) ;;
    needs_input)  needs_input=$((needs_input + 1)) ;;
  esac
done

# Output nothing if no Claude sessions
[ "$total" -eq 0 ] && exit 0

# Build status string matching the user's theme
# Colors: working=yellow, needs_input=red+bold, idle=green
parts=""

if [ "$needs_input" -gt 0 ]; then
  parts="#[fg=red,bold]${needs_input}❓#[fg=#c6c8d1,nobold]"
fi

if [ "$working" -gt 0 ]; then
  [ -n "$parts" ] && parts="${parts} "
  parts="${parts}#[fg=yellow]${working}⚡#[fg=#c6c8d1]"
fi

if [ "$idle" -gt 0 ]; then
  [ -n "$parts" ] && parts="${parts} "
  parts="${parts}#[fg=green]${idle}💤#[fg=#c6c8d1]"
fi

echo "#[fg=#c6c8d1,bg=#0f1117] 🤖[${parts}#[fg=#c6c8d1,bg=#0f1117]] "
