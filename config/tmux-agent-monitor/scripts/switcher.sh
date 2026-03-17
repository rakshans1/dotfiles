#!/bin/bash
# fzf popup switcher — lists all Claude Code sessions with status, allows switching.
# Handles both standalone tmux panes and Claude running inside nvim toggleterm.

STATE_DIR="$HOME/.cache/tmux-agent-monitor"

if [ ! -d "$STATE_DIR" ]; then
  echo "No Claude sessions found."
  echo ""
  echo "Hooks haven't fired yet. Start or interact with a Claude Code session first."
  read -r -n 1 -s -p "Press any key to close..."
  exit 0
fi

now=$(date +%s)

# Collect all live sessions into fzf lines
entries=()
# Parallel array to map fzf index → pane/nvim/pid for switching
pane_ids=()
nvim_sockets=()
pids=()

for f in "$STATE_DIR"/pid-*.json; do
  [ -f "$f" ] || continue

  status=$(grep -o '"status":"[^"]*"' "$f" | head -1 | sed 's/"status":"//' | sed 's/"//')
  pid=$(grep -o '"pid":[0-9]*' "$f" | head -1 | sed 's/"pid"://')
  pane=$(grep -o '"pane":"[^"]*"' "$f" | head -1 | sed 's/"pane":"//' | sed 's/"//')
  nvim_socket=$(grep -o '"nvim_socket":"[^"]*"' "$f" | head -1 | sed 's/"nvim_socket":"//' | sed 's/"//')
  cwd=$(grep -o '"cwd":"[^"]*"' "$f" | head -1 | sed 's/"cwd":"//' | sed 's/"//')
  ts=$(grep -o '"timestamp":[0-9]*' "$f" | head -1 | sed 's/"timestamp"://')
  title=$(grep -o '"title":"[^"]*"' "$f" | head -1 | sed 's/"title":"//' | sed 's/"//')
  project=$(grep -o '"project":"[^"]*"' "$f" | head -1 | sed 's/"project":"//' | sed 's/"//')

  # Skip dead processes
  if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$f"
    continue
  fi

  # Skip stale (1 hour)
  if [ -n "$ts" ] && [ $((now - ts)) -gt 3600 ]; then
    rm -f "$f"
    continue
  fi

  # Verify pane still exists
  if [ -n "$pane" ] && ! tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qx "$pane"; then
    rm -f "$f"
    continue
  fi

  # Get session:window.pane target from pane_id
  pane_target=$(tmux list-panes -a -F '#{pane_id} #{session_name}:#{window_index}.#{pane_index}' 2>/dev/null | grep "^${pane} " | awk '{print $2}')
  [ -z "$pane_target" ] && continue

  # Shorten cwd for display
  short_cwd="${cwd/#$HOME/~}"
  display_path=$(echo "$short_cwd" | awk -F/ '{if(NF>2) print $(NF-1)"/"$NF; else print $0}')

  # Time since last update
  if [ -n "$ts" ]; then
    age=$((now - ts))
    if [ "$age" -lt 60 ]; then
      age_str="${age}s"
    elif [ "$age" -lt 3600 ]; then
      age_str="$((age / 60))m"
    else
      age_str="$((age / 3600))h"
    fi
  else
    age_str="?"
  fi

  # Status indicator (sorted: ? < ~ < = so needs_input sorts first)
  case "$status" in
    needs_input)  indicator="\033[31;1m? INPUT  \033[0m"; sort_key="0" ;;
    working)      indicator="\033[33m~ working\033[0m"; sort_key="1" ;;
    idle)         indicator="\033[32m= idle   \033[0m"; sort_key="2" ;;
    *)            indicator="  $status"; sort_key="3" ;;
  esac

  # nvim label
  nvim_label=""
  if [ -n "$nvim_socket" ] && [ "$nvim_socket" != "" ]; then
    nvim_label=" [nvim]"
  fi

  # Project name (git repo or directory)
  display_project="${project:-${display_path}}"

  # Display title if available
  display_title=""
  if [ -n "$title" ]; then
    display_title="  \033[90m${title}\033[0m"
  fi

  # Store the pane ID as the first field so fzf preview can extract it
  line="${pane}\t${sort_key}\t$(printf '%b' "$indicator")  \033[1m${display_project}\033[0m${nvim_label}${display_title}  \033[90m${pane_target}  ${age_str} ago\033[0m"
  entries+=("$line")

  # Track metadata in parallel arrays by pane
  pane_ids+=("$pane")
  nvim_sockets+=("$nvim_socket")
  pids+=("$pid")
done

if [ ${#entries[@]} -eq 0 ]; then
  echo "No active Claude sessions."
  echo ""
  echo "Hooks haven't fired yet. Start or interact with a Claude Code session first."
  read -r -n 1 -s -p "Press any key to close..."
  exit 0
fi

# Sort by sort_key (field 2), then display fields 3+ to user
# Preview uses field 1 (pane_id) for capture-pane
selected=$(printf '%b\n' "${entries[@]}" | sort -t$'\t' -k2,2 | \
  fzf --ansi \
      --delimiter=$'\t' \
      --with-nth=3.. \
      --header="Agent Sessions  ? = needs input  ~ = working  = = idle" \
      --preview='tmux capture-pane -e -t $(echo {} | cut -f1) -p -S -30 2>/dev/null | tail -25' \
      --preview-window=right:50%:wrap \
      --no-sort \
      --reverse) || exit 0

# Extract the pane ID (first tab-delimited field)
selected_pane=$(echo "$selected" | cut -f1)

# Find the matching metadata
target_nvim_socket=""
target_pid=""
for i in "${!pane_ids[@]}"; do
  if [ "${pane_ids[$i]}" = "$selected_pane" ]; then
    target_nvim_socket="${nvim_sockets[$i]}"
    target_pid="${pids[$i]}"
    break
  fi
done

# Get the session:window.pane target for select-window + select-pane
target_info=$(tmux list-panes -a -F '#{pane_id} #{session_name} #{session_name}:#{window_index} #{session_name}:#{window_index}.#{pane_index}' 2>/dev/null | grep "^${selected_pane} ")
target_session=$(echo "$target_info" | awk '{print $2}')
target_window=$(echo "$target_info" | awk '{print $3}')
target_full=$(echo "$target_info" | awk '{print $4}')

# Write a temp switch script to run after the popup closes
switch_script=$(mktemp /tmp/agent-switch-XXXXXX.sh)
cat > "$switch_script" <<SCRIPT
#!/bin/bash
tmux select-window -t '$target_window'
tmux select-pane -t '$target_full'
SCRIPT

if [ -n "$target_nvim_socket" ] && [ -S "$target_nvim_socket" ]; then
  # Single nvim call: check buftype, find toggleterm, and open it — all in one Lua expression
  cat >> "$switch_script" <<NVIMCMD
nvim --headless --server '$target_nvim_socket' --remote-expr 'luaeval("(function() if vim.bo.buftype == [[terminal]] then return [[already]] end; local tid = 0; local ok, terms = pcall(function() return require([[toggleterm.terminal]]).get_all() end); if ok then for _, t in pairs(terms) do if t.job_id and vim.fn.jobpid(t.job_id) ~= 0 then local pid = vim.fn.jobpid(t.job_id); local check = vim.fn.system([[pgrep -P ]] .. pid .. [[ -a 2>/dev/null]]); if check:find([[${target_pid}]]) or pid == ${target_pid} then tid = t.id; break end end end end; vim.schedule(function() vim.cmd([[stopinsert]]); if tid > 0 then vim.cmd(tid .. [[ToggleTerm direction=tab]]) else vim.cmd([[ToggleTerm direction=tab]]) end end); return [[ok]] end)()")' > /dev/null 2>&1
NVIMCMD
fi

echo "rm -f '$switch_script'" >> "$switch_script"
chmod +x "$switch_script"

# Switch session first, then run the script in background after popup closes
tmux switch-client -t "$target_session" 2>/dev/null || true
tmux run-shell -b "$switch_script"
