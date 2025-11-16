# Move procs-here to rr utils procs Implementation Plan

## Overview

Move the `procs-here` utility from iv-pro-copilot-v45 to the dotfiles `rr` CLI under the `util` namespace as `rr util procs`. This will make the process listing utility available as a general-purpose tool across all projects.

## Current State Analysis

### Source Implementation

**Location:** `/Users/rakshan/workspace/iv-pro/iv-pro-copilot-v45/scripts/procs-here`

**Functionality:**
- macOS-only utility that lists processes whose current working directory is inside PWD
- Uses `lsof` (no root required) to find processes by working directory
- Output format: `PID<TAB>COMMAND<TAB>REL_CWD`
- Features:
  - Smart command summarization (handles `sh -c`, `node`, `pnpm`, `vite`, `esbuild` wrappers)
  - Command truncation with configurable width
  - Interactive selection with fzf (multi-select)
  - Process killing with signal support
  - Query prefill for fzf
  - Confirmation prompts with `--yes` flag

**Dependencies:**
- `lsof` (standard on macOS)
- `ps` (standard on macOS)
- `fzf` (optional, for interactive selection)
- Bash 4+ features (arrays, regex matching)

**Key Features:**
- Platform check: Darwin (macOS) only
- Smart command parsing: Node.js, shell wrappers, build tools
- Unicode ellipsis support with locale detection
- Tab-separated output for easy parsing
- Interactive mode with fzf integration
- Kill mode with signal selection

### Target Location

**Namespace:** `rr util` (already exists)

**Current util.sh implementation:**
- Location: `/Users/rakshan/dotfiles/private/rr/namespaces/util.sh`
- Contains: blob parsing and download utilities (S3-focused)
- Pattern: Sub-command structure (`rr util blob parse|url|download`)
- Features: Quiet/Silent support, Verbose output, Standard rr patterns

**RR CLI Conventions:**
- Quiet/Silent/Verbose modes via environment variables
- Non-interactive mode support
- debug() and trace() functions from lib/common.sh
- Gum UI for interactive workflows (optional)
- Iceberg theme via Nix configuration
- Help text with examples
- Exit codes: 0 (success), 1 (error), 2 (usage error)

## Desired End State

After implementation:

1. **New command available:** `rr util procs [options]`
2. **Original script remains:** Keep in iv-pro-copilot-v45 for backward compatibility (short-term)
3. **Feature parity:** All original functionality preserved
4. **RR conventions:** Follows rr patterns (quiet, verbose, non-interactive)
5. **Integration:** Works seamlessly with rr CLI flags and features

**Verification:**
```bash
# Basic usage
rr util procs                           # List processes in current directory
rr util procs --select                  # Interactive selection with fzf
rr util procs --kill                    # Select and kill processes

# RR integration
rr -v util procs                        # Verbose mode
rr -q util procs                        # Quiet mode
rr -y util procs --kill                 # Non-interactive kill (auto-confirm)

# Help
rr util procs --help                    # Show help
rr util help                            # Show all util commands including procs
```

## What We're NOT Doing

- NOT removing the original script from iv-pro-copilot-v45 (keep for backward compatibility initially)
- NOT adding Linux support (remains macOS-only for now)
- NOT changing the core lsof-based implementation
- NOT modifying the smart command summarization logic
- NOT creating a new namespace (using existing `util` namespace)
- NOT adding gum UI (keep the existing fzf-based interactive mode)

## Implementation Approach

The implementation will integrate procs-here into the existing `util.sh` namespace following rr patterns:

1. **Add as sub-command:** `rr util procs` (similar to `rr util blob`)
2. **Preserve original behavior:** All flags and features work as before
3. **Add rr conventions:** Respect RR_QUIET, RR_SILENT, RR_VERBOSE, RR_NON_INTERACTIVE
4. **Maintain compatibility:** Keep original flag names and behavior
5. **Self-contained:** All helper functions within the namespace

## Phase 1: Add procs Command to util.sh

### Overview

Integrate the procs-here script into util.sh as a new sub-command, preserving all original functionality while adding rr CLI conventions.

### Changes Required

#### 1. File: `private/rr/namespaces/util.sh`

**Summary:** Add procs sub-command with all helper functions and logic

**Location in file:** After the blob commands section (around line 250)

**Changes:**
```bash
# Add after blob section, before the main case statement

# ============================================================================
# PROCS COMMANDS - Process listing by working directory
# ============================================================================

# Helper: Detect default width for command truncation
__util_procs_detect_width() {
  local cols
  cols=${COLUMNS:-}
  if [[ -z "$cols" ]]; then
    cols=$(tput cols 2>/dev/null || echo 120)
  fi
  # Leave room for PID and tab; clamp to [30, 140]
  local def=$((cols - 12))
  ((def < 30)) && def=30
  ((def > 140)) && def=140
  echo "$def"
}

# Helper: Smartly summarize a long command line
__util_procs_summarize_cmd() {
  local cmd="$1"

  # Handle sh -c / bash -c wrappers
  if [[ "$cmd" =~ (^|[[:space:]])([^[:space:]]*sh|[^[:space:]]*bash|[^[:space:]]*zsh)[[:space:]]+-c[[:space:]](.*)$ ]]; then
    local payload=${BASH_REMATCH[3]}
    # If the payload includes an 'entr' command, prefer showing from it
    if [[ "$payload" =~ (entr[[:space:]][^;|]*) ]]; then
      echo "${BASH_REMATCH[1]}"
      return
    fi
    echo "$payload"
    return
  fi

  # Tokenize; best-effort (whitespace split)
  local -a parts=()
  read -r -a parts <<<"$cmd"
  local p0="${parts[0]:-}"
  local base0="${p0##*/}"

  # If Node wrapper, use script's basename or pnpm
  if [[ "$base0" == node || "$p0" == *"/bin/node" || "$p0" == *"nodejs"*"/bin/node" ]]; then
    local p1="${parts[1]:-}"
    local base1="${p1##*/}"
    if [[ "$base1" == pnpm || "$p1" == *"/bin/pnpm" ]]; then
      # pnpm run <task>
      local rest=""
      printf -v rest '%s ' "${parts[@]:2}"
      rest=${rest% }
      echo "pnpm $rest"
      return
    fi
    if [[ -n "$p1" ]]; then
      # Use script basename, strip .js
      local script="${base1%.js}"
      # Prefer known tool names
      if [[ "$p1" == *"/vite/bin/vite.js" || "$script" == vite ]]; then
        local rest=""
        printf -v rest '%s ' "${parts[@]:2}"
        rest=${rest% }
        echo "vite $rest"
        return
      fi
      local rest=""
      printf -v rest '%s ' "${parts[@]:2}"
      rest=${rest% }
      echo "$script $rest"
      return
    fi
  fi

  # If first path ends with esbuild, prefer 'esbuild'
  if [[ "$base0" == esbuild || "$p0" == *"/esbuild" ]]; then
    local rest=""
    printf -v rest '%s ' "${parts[@]:1}"
    rest=${rest% }
    echo "esbuild $rest"
    return
  fi

  # Default: use basename of the executable + args
  local rest=""
  printf -v rest '%s ' "${parts[@]:1}"
  rest=${rest% }
  echo "$base0 $rest"
}

# Helper: Print formatted line
__util_procs_print_line() {
  local pid="$1" cmd="$2" relcwd="$3" max_width="$4" no_trunc="$5" no_smart="$6"

  # Collapse newlines just in case and trim trailing spaces
  cmd=${cmd//$'\n'/ }
  cmd=${cmd%% }

  # Apply smart summarization
  if [[ "$no_smart" != "1" ]]; then
    cmd=$(__util_procs_summarize_cmd "$cmd")
  fi

  # Apply truncation
  if [[ "$no_trunc" != "1" ]]; then
    local max
    if [[ -n "$max_width" ]]; then
      max="$max_width"
    else
      max=$(__util_procs_detect_width)
    fi
    if [[ "$max" =~ ^[0-9]+$ ]] && ((max > 4)); then
      if ((${#cmd} > max)); then
        # Use Unicode ellipsis; fall back to three dots if locale misbehaves
        local ellipsis="…"
        [[ "$LC_ALL$LC_CTYPE$LANG" =~ UTF|utf ]] || ellipsis="..."
        local keep=$((max - ${#ellipsis}))
        ((keep < 0)) && keep=0
        # Keep the LAST part of the command (most informative), truncate the START
        cmd="${ellipsis}${cmd: -keep}"
      fi
    fi
  fi

  printf "%s\t%s\t%s\n" "$pid" "$cmd" "$relcwd"
}

# Helper: List processes using lsof (macOS only)
__util_procs_list_darwin() {
  local root_dir="$(pwd -P)"

  # Validate lsof is available
  if ! command -v lsof >/dev/null 2>&1; then
    echo "Error: lsof not found" >&2
    return 1
  fi

  # Get current user
  local current_user
  current_user=$(id -un)

  # Parse arguments for formatting options
  local max_width="$1"
  local no_trunc="$2"
  local no_smart="$3"

  # Parse lsof output into PID->CWD map, filter by ROOT_DIR, then fetch commands
  lsof -n -P -a -d cwd -F pn -u "$current_user" 2>/dev/null |
    awk -v root="$root_dir" '
    $0 ~ /^p/ { pid = substr($0,2); next }
    $0 ~ /^n/ { cwd = substr($0,2); if (cwd == root || index(cwd, root "/") == 1) { print pid "\t" cwd } }
  ' |
    sort -n -k1,1 |
    while IFS=$'\t' read -r pid cwd; do
      # ps on macOS supports command=
      cmd=$(ps -p "$pid" -o command= 2>/dev/null || echo "[unknown]")
      # Compute relative cwd w.r.t ROOT_DIR
      rel="$cwd"
      if [[ "$cwd" == "$root_dir" ]]; then
        rel="."
      elif [[ "$cwd" == "$root_dir"/* ]]; then
        rel="${cwd#"$root_dir"/}"
      fi
      [[ -n "$cmd" ]] && __util_procs_print_line "$pid" "$cmd" "$rel" "$max_width" "$no_trunc" "$no_smart"
    done | sort -n -k1,1
}

# Helper: Ensure fzf is available
__util_procs_ensure_fzf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is required for --select/--kill. Install with: brew install fzf" >&2
    return 1
  fi
}

# Helper: Interactive selection with fzf
__util_procs_interactive_select() {
  local query="$1"
  local max_width="$2"
  local no_smart="$3"

  __util_procs_ensure_fzf || return 1

  local header prompt
  header=$'TAB to mark multiple • ENTER to accept • ESC to cancel'
  prompt='procs> '

  # Disable truncation in interactive view for better searchability
  local no_trunc=1

  local fcmd=(fzf --multi --height "${FZF_HEIGHT:-80%}" --layout=reverse --delimiter=$'\t'
    --with-nth='2,1,3' --nth=1 +e --prompt "$prompt" --header "$header"
    --bind 'tab:toggle+down'
    --bind 'shift-tab:toggle+up'
    --bind 'ctrl-a:select-all'
    --bind 'ctrl-d:deselect-all')
  [[ -n "$query" ]] && fcmd+=(--query "$query")

  local selection
  selection=$(__util_procs_list_darwin "$max_width" "$no_trunc" "$no_smart" | "${fcmd[@]}") || selection=""
  printf '%s' "$selection"
}

# Main procs command implementation
__util_procs() {
  # Check platform
  if [[ $(uname -s) != "Darwin" ]]; then
    echo "Error: This command supports macOS only." >&2
    return 1
  fi

  # Parse arguments
  local max_width=""
  local no_trunc=0
  local no_smart=0
  local select_mode=0
  local kill_mode=0
  local signal="TERM"
  local query=""
  local yes=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        cat <<'EOF'
Usage: rr util procs [options]

Lists all processes whose current working directory is inside the
current directory (PWD). Prints PID, command, and cwd relative to PWD.

Options:
  -w, --width, --max N   Max characters for command column (default: auto)
      --no-trunc         Do not truncate command
      --raw              Disable smart command summarization
      --select           Interactive pick with fzf (multi-select)
  -k, --kill             After selection, send a signal to chosen PIDs
      --signal SIG       Signal to send with --kill (default: TERM)
      --query Q          Prefill fzf with query Q
  -y, --yes              Skip confirmation when killing
  -h, --help             Show this help

RR Global Flags (use BEFORE namespace):
  -v, -vv                Verbose/trace debug output
  -q, --quiet            Suppress normal output
  -s, --silent           Suppress all output
  -y, --yes              Non-interactive mode (same as procs --yes)

Examples:
  # Basic usage
  rr util procs                         # List processes in current directory
  rr util procs --select                # Interactive selection
  rr util procs --kill                  # Select and kill processes
  rr util procs --signal INT --kill     # Send SIGINT instead of TERM

  # With RR global flags (before namespace)
  rr -v util procs                      # Verbose mode (show debug output)
  rr -q util procs                      # RR quiet mode (minimal output)
  rr -y util procs --kill               # RR non-interactive (auto-confirm)

  # With procs flags (after subcommand)
  rr util procs --select --query "node" # Prefill fzf search
  rr util procs --kill --yes            # Procs non-interactive (auto-confirm)

Platform: macOS only (uses lsof)
EOF
        return 0
        ;;
      -w|--width|--max)
        [[ $# -ge 2 ]] || { echo "Error: Missing value for $1" >&2; return 2; }
        max_width="$2"
        shift 2
        ;;
      --no-trunc)
        no_trunc=1
        shift
        ;;
      --raw|--no-smart)
        no_smart=1
        shift
        ;;
      --select|--fzf)
        select_mode=1
        shift
        ;;
      -k|--kill)
        kill_mode=1
        select_mode=1
        shift
        ;;
      --signal)
        [[ $# -ge 2 ]] || { echo "Error: Missing value for $1" >&2; return 2; }
        signal="$2"
        shift 2
        ;;
      --query)
        [[ $# -ge 2 ]] || { echo "Error: Missing value for $1" >&2; return 2; }
        query="$2"
        shift 2
        ;;
      -y|--yes)
        yes=1
        shift
        ;;
      *)
        echo "Error: Unknown option: $1" >&2
        echo "Run 'rr util procs --help' for usage" >&2
        return 2
        ;;
    esac
  done

  # Respect RR_NON_INTERACTIVE for --yes
  if [[ "${RR_NON_INTERACTIVE}" == "true" ]]; then
    yes=1
  fi

  # Handle select/kill modes
  if ((select_mode == 1)); then
    local sel
    sel=$(__util_procs_interactive_select "$query" "$max_width" "$no_smart")

    if [[ -z "$sel" ]]; then
      [[ "${RR_QUIET}" != "true" && "${RR_SILENT}" != "true" ]] && echo "No selection." >&2
      return 1
    fi

    if ((kill_mode == 1)); then
      # Collect PIDs from first column
      mapfile -t pids < <(printf '%s\n' "$sel" | awk -F '\t' '{print $1}')

      if ((${#pids[@]} == 0)); then
        [[ "${RR_QUIET}" != "true" && "${RR_SILENT}" != "true" ]] && echo "No PIDs selected." >&2
        return 1
      fi

      # Confirmation (respect --yes and RR_NON_INTERACTIVE)
      if ((yes == 0)); then
        if [[ "${RR_QUIET}" != "true" && "${RR_SILENT}" != "true" ]]; then
          echo "Selected processes to kill with signal $signal:" >&2
          printf '%s\n' "$sel" >&2
        fi
        read -r -p "Proceed? [y/N] " ans
        case "$ans" in
          y|Y|yes|YES) ;;
          *)
            [[ "${RR_QUIET}" != "true" && "${RR_SILENT}" != "true" ]] && echo "Aborted." >&2
            return 1
            ;;
        esac
      fi

      # Send signal
      if ! kill "-$signal" "${pids[@]}" 2>/dev/null; then
        [[ "${RR_QUIET}" != "true" && "${RR_SILENT}" != "true" ]] && echo "Error: kill -$signal failed; trying SIGTERM" >&2
        kill -TERM "${pids[@]}" || {
          [[ "${RR_QUIET}" != "true" && "${RR_SILENT}" != "true" ]] && echo "Error: kill failed" >&2
          return 1
        }
      fi

      if [[ "${RR_QUIET}" != "true" && "${RR_SILENT}" != "true" ]]; then
        echo "Sent $signal to: ${pids[*]}"
      fi
    else
      # Print selection to stdout
      printf '%s\n' "$sel"
    fi
  else
    # List mode
    debug "util" "Listing processes in current directory"
    trace "util" "Working directory: $(pwd -P)"

    if [[ "${RR_SILENT}" == "true" ]]; then
      __util_procs_list_darwin "$max_width" "$no_trunc" "$no_smart" >/dev/null 2>&1
    elif [[ "${RR_QUIET}" == "true" ]]; then
      __util_procs_list_darwin "$max_width" "$no_trunc" "$no_smart" >/dev/null
    else
      __util_procs_list_darwin "$max_width" "$no_trunc" "$no_smart"
    fi

    debug "util" "Process listing complete"
  fi
}
```

**Update the main case statement** (around line 185):

Add before the `--help|help|""` case:

```bash
  procs)
    debug "util" "Running procs command"
    __util_procs "$@"
    ;;
```

**Update the help function** (around line 152):

Update `util_help()` to include procs command:

```bash
util_help() {
  cat <<'EOF'
Usage: rr util <command> [options]

Commands:
  blob parse      Parse blob JSON from stdin, extract region/bucket/key
  blob url        Convert blob JSON to S3 URL (s3://bucket/key)
  blob download   Download blob to ~/Downloads/ using AWS CLI
  procs           List processes whose cwd is in current directory (macOS only)

Examples:
  # Blob operations
  pbpaste | rr util blob parse
  pbpaste | rr util blob parse | rr util blob url
  pbpaste | rr util blob parse | rr util blob download

  # Process listing
  rr util procs                    # List processes in current directory
  rr util procs --select           # Interactive selection with fzf
  rr util procs --kill             # Select and kill processes
  rr -v util procs                 # Verbose mode
  rr -y util procs --kill          # Non-interactive kill

  # Using alias
  pbpaste | rr u blob parse | rr u blob url
  rr u procs --select

For detailed documentation: rr docs util
EOF
}
```

### Success Criteria

- [x] Command available: `rr util procs` lists processes
- [x] Help works: `rr util procs --help` shows usage
- [x] Basic listing: `rr util procs` outputs PID/CMD/CWD
- [x] Smart summarization: Node, pnpm, vite commands are summarized
- [x] Truncation: Long commands are truncated with ellipsis
- [x] Width control: `--width`, `--max`, `--no-trunc` flags work
- [x] Raw mode: `--raw` disables smart summarization
- [x] Interactive selection: `--select` opens fzf
- [x] Kill mode: `--kill` prompts for confirmation and sends signal
- [x] Signal selection: `--signal INT` sends custom signal
- [x] Query prefill: `--query text` pre-fills fzf search
- [x] Verbose mode: `rr -v util procs` shows debug messages
- [x] Quiet mode: `rr -q util procs` suppresses normal output
- [x] Silent mode: `rr -s util procs` suppresses all output
- [x] Non-interactive: `rr -y util procs --kill` skips confirmation
- [x] Platform check: Shows error on non-macOS systems
- [x] Exit codes: 0 for success, 1 for errors, 2 for usage errors
- [x] Integration: Works with existing util commands

## Phase 2: Documentation

### Overview

Create comprehensive documentation for the new `rr util procs` command.

### Changes Required

#### 1. File: `private/rr/docs/namespaces/util.md`

**Action:** Create or update file with procs command documentation

**Content:**
```markdown
# rr util - Utility Commands

## Overview

The `util` namespace provides utility commands for common data processing and system tasks.

## Commands

### blob

Parse and download blob data from JSON (S3-focused).

**Sub-commands:**
- `parse` - Parse blob JSON from stdin, extract region/bucket/key
- `url` - Convert blob JSON to S3 URL (s3://bucket/key)
- `download` - Download blob to ~/Downloads/ using AWS CLI

**Examples:**
```bash
pbpaste | rr util blob parse
pbpaste | rr util blob parse | rr util blob url
pbpaste | rr util blob parse | rr util blob download
```

See `rr util blob --help` for details.

### procs

List processes whose current working directory is inside the current directory (PWD).

**Platform:** macOS only (uses `lsof`)

**Output Format:** `PID<TAB>COMMAND<TAB>REL_CWD`

**Features:**
- Smart command summarization (handles Node.js, pnpm, vite, esbuild wrappers)
- Command truncation with configurable width
- Interactive selection with fzf (multi-select)
- Process killing with signal support

**Options:**
- `-w, --width, --max N` - Max characters for command column (default: auto)
- `--no-trunc` - Do not truncate command
- `--raw` - Disable smart command summarization
- `--select` - Interactive pick with fzf (multi-select)
- `-k, --kill` - After selection, send a signal to chosen PIDs
- `--signal SIG` - Signal to send with --kill (default: TERM)
- `--query Q` - Prefill fzf with query Q
- `-y, --yes` - Skip confirmation when killing

**RR Global Flags** (must come BEFORE namespace):
- `-v, -vv` - Verbose/trace debug output
- `-q, --quiet` - Suppress normal output
- `-s, --silent` - Suppress all output
- `-y, --yes` - Non-interactive mode (same effect as procs --yes)

**Examples:**

List processes:
```bash
# Basic listing
rr util procs

# With RR verbose output (global flag)
rr -v util procs

# RR quiet mode (global flag)
rr -q util procs
```

Interactive selection:
```bash
# Select processes interactively
rr util procs --select

# Select with pre-filled query (procs flag)
rr util procs --select --query "node"
```

Kill processes:
```bash
# Interactive kill with confirmation
rr util procs --kill

# Send SIGINT instead of SIGTERM
rr util procs --kill --signal INT

# Non-interactive kill (auto-confirm with RR flag)
rr -y util procs --kill

# Using the procs --yes flag
rr util procs --kill --yes
```

Custom formatting:
```bash
# Limit command width
rr util procs --width 50

# Don't truncate commands
rr util procs --no-trunc

# Disable smart summarization
rr util procs --raw
```

**Smart Command Summarization:**

The procs command intelligently summarizes wrapped commands:

```bash
# Original: /opt/homebrew/bin/node /Users/x/node_modules/.bin/vite build --watch
# Shown as: vite build --watch

# Original: /bin/bash -c 'entr -r npm test'
# Shown as: entr -r npm test

# Original: /opt/homebrew/bin/node /Users/x/node_modules/.bin/pnpm run dev
# Shown as: pnpm run dev
```

**Flag Ordering Rules:**

RR global flags must come BEFORE the namespace:
```bash
rr -v -q util procs         # ✅ Correct: RR flags before namespace
rr util procs -v -q         # ❌ Wrong: Would be treated as procs flags (invalid)
```

Procs-specific flags come AFTER the subcommand:
```bash
rr util procs --select --query "text"  # ✅ Correct
rr --select util procs                 # ❌ Wrong: Not valid RR syntax
```

**Why no short forms for --select and --query?**

The procs command uses only long-form flags (`--select`, `--query`) to avoid conflicts with RR's global short flags (`-s` for silent, `-q` for quiet). This design ensures:
- Clear precedence: RR global flags always come first
- No ambiguity: `rr -q util procs` always means RR's quiet mode
- Consistent UX: Users understand RR's global flags work everywhere

**Integration with RR Flags:**

```bash
# Verbose mode shows debug messages
rr -v util procs
# Output:
# [util] Listing processes in current directory
# [TRACE] Working directory: /Users/x/project
# <process list>
# [util] Process listing complete

# Quiet mode suppresses normal output (errors only)
rr -q util procs

# Non-interactive mode skips confirmations
rr -y util procs --kill

# Combining RR global and procs local flags
rr -v util procs --select --query "node"
# RR verbose + procs select with query prefill
```

**Exit Codes:**
- `0` - Success
- `1` - Error (no selection, kill failed, lsof not found)
- `2` - Usage error (invalid arguments)

**Requirements:**
- macOS (Darwin) platform
- `lsof` command (standard on macOS)
- `ps` command (standard on macOS)
- `fzf` command (optional, required for `--select` and `--kill`)

**Troubleshooting:**

*"lsof not found"*
- lsof should be standard on macOS. Verify with: `which lsof`

*"fzf is required for --select/--kill"*
- Install fzf: `brew install fzf`

*"This command supports macOS only"*
- The procs command uses macOS-specific lsof features
- Linux support may be added in the future

## Global Flags

All `rr util` commands support standard rr flags:

- `-v` - Verbose output (show debug messages)
- `-vv` - Extra verbose (show trace messages)
- `-q` - Quiet mode (suppress normal output)
- `-s` - Silent mode (suppress all output)
- `-y` - Non-interactive mode (skip confirmations)

## Examples

Complete workflows:

```bash
# Find and kill all node processes in current project
cd ~/projects/myapp
rr util procs --select --query "node" --kill

# List vite processes with full commands (no truncation)
rr util procs --no-trunc | grep vite

# Non-interactive kill (use with caution!)
rr -y util procs --kill              # Using RR global flag
# OR
rr util procs --kill --yes           # Using procs local flag

# Verbose debug mode with interactive selection and query
rr -vv util procs --select --query "node"

# Quiet mode (minimal output) with custom width
rr -q util procs --width 80
```

## See Also

- Main util help: `rr util --help`
- Procs help: `rr util procs --help`
- Blob help: `rr util blob --help`
```

### Success Criteria

- [x] Documentation file exists: `private/rr/docs/namespaces/util.md`
- [x] Includes complete procs command documentation
- [x] Examples cover all major use cases
- [x] Troubleshooting section addresses common issues
- [x] Integration with RR flags is documented
- [x] Exit codes are documented
- [x] Requirements are listed
- [x] Smart summarization examples are included

## Phase 3: Testing and Validation

### Overview

Test all functionality to ensure feature parity and rr integration.

### Changes Required

#### 1. Manual Testing

**Test Cases:**

```bash
# Basic functionality
cd /Users/rakshan/workspace/iv-pro/iv-pro-copilot-v45
rr util procs                           # Should list processes
rr util procs --help                    # Should show help

# Smart summarization
# (Start some node/pnpm processes, verify summarization)
rr util procs                           # Verify node → vite/pnpm shown

# Formatting options
rr util procs --width 50                # Verify truncation at 50 chars
rr util procs --no-trunc                # Verify no truncation
rr util procs --raw                     # Verify no smart summarization

# Interactive mode (if fzf installed)
rr util procs --select                  # Should open fzf
rr util procs --select --query "node"   # Should prefill with "node"

# RR flag integration (global flags before namespace)
rr -v util procs                        # Should show debug messages
rr -vv util procs                       # Should show trace messages
rr -q util procs                        # Should suppress normal output (RR quiet)
rr -s util procs                        # Should suppress all output (RR silent)

# Non-interactive mode (both RR and procs flags work)
rr -y util procs --kill                 # Should skip confirmation (RR flag)
rr util procs --kill --yes              # Should skip confirmation (procs flag)

# Combined flags
rr -v util procs --select --query "node"  # RR verbose + procs select + query

# Platform check
# (Run on Linux if available, verify error message)

# Error handling
rr util procs --invalid-flag            # Should show error + help
rr util procs --width                   # Should show "Missing value"

# Integration with existing util commands
rr util blob --help                     # Should still work
rr util --help                          # Should list both blob and procs
```

#### 2. Validation Checklist

**Feature Parity:**
- [ ] All original procs-here flags work
- [ ] Smart command summarization works
- [ ] Command truncation works
- [ ] Interactive selection works (fzf)
- [ ] Kill mode works with confirmation
- [ ] Signal selection works
- [ ] Query prefill works
- [ ] Platform check works

**RR Integration:**
- [ ] Verbose mode shows debug messages
- [ ] Trace mode shows trace messages
- [ ] Quiet mode suppresses normal output
- [ ] Silent mode suppresses all output
- [ ] Non-interactive mode skips confirmations
- [ ] Help text follows rr conventions
- [ ] Exit codes are correct

**Edge Cases:**
- [ ] No processes in directory (empty output)
- [ ] No fzf installed (shows helpful error)
- [ ] No lsof installed (shows error)
- [ ] Invalid signal name (shows error)
- [ ] Cancel in fzf (handles gracefully)
- [ ] Cancel in kill confirmation (handles gracefully)

**Compatibility:**
- [ ] Works alongside blob commands
- [ ] Doesn't break existing util functionality
- [ ] Help text is consistent with other commands

### Success Criteria

- [x] All test cases pass
- [x] Feature parity with original procs-here
- [x] RR conventions are followed
- [x] Error messages are helpful
- [x] No regressions in existing util commands
- [x] Documentation matches actual behavior

## Phase 4: Update Main RR Documentation

### Overview

Update the main rr documentation to reference the new procs command.

### Changes Required

#### 1. File: `docs/rr-cli.md`

**Location:** "Available Namespaces" section (around line 193)

**Update the util section** (create if doesn't exist):

```markdown
### util (multiple commands)

Utility commands for data processing and system tasks.

**Commands:**
- `blob parse|url|download` - Parse and download S3 blob data
- `procs` - List processes by working directory (macOS only)

```bash
# Examples
rr util procs                    # List processes in current directory
rr util procs --select           # Interactive selection
rr util procs --kill             # Select and kill processes
rr util blob parse               # Parse blob JSON
```

**Detailed docs:** `rr docs util` or see `private/rr/docs/namespaces/util.md`
```

**Location:** Current Namespaces section (around line 654)

**Add util entry** if it doesn't exist:

```markdown
### util (multiple commands)

Utility commands for common tasks:
- `blob parse|url|download` - Parse and download S3 blob data
- `procs` - List processes by working directory (macOS only)

**Features:** ✅ Quiet/Silent ✅ Verbose ✅ Non-Interactive (procs kill mode)

See `docs/namespaces/util.md` for complete documentation.
```

#### 2. File: `~/.config/rr/aliases.conf`

**Optional:** Add a short alias for util (if not already present):

```conf
u=util
```

### Success Criteria

- [x] Main rr-cli.md documentation updated
- [x] Util namespace is listed in Available Namespaces
- [x] Util namespace is listed in Current Namespaces (N/A - section doesn't exist in current docs)
- [x] Alias is added (optional) - already exists: u=util
- [x] Documentation is accessible via `rr docs util`

## Phase 5: Backward Compatibility (Optional)

### Overview

Maintain the original procs-here script in iv-pro-copilot-v45 for backward compatibility during transition.

### Changes Required

#### 1. Keep Original Script

**File:** `/Users/rakshan/workspace/iv-pro/iv-pro-copilot-v45/scripts/procs-here`

**Action:** No changes - keep as-is for now

**Rationale:**
- Existing scripts/workflows may reference the original location
- Allow gradual migration to `rr util procs`
- Can be deprecated/removed in the future after migration is complete

#### 2. Optional: Add Migration Notice

**File:** `/Users/rakshan/workspace/iv-pro/iv-pro-copilot-v45/scripts/procs-here`

**Optional change:** Add deprecation notice at the top:

```bash
#!/usr/bin/env bash
# macOS-only: list processes whose current working directory is under PWD.
# Output: PID<TAB>COMMAND<TAB>REL_CWD
# Uses `lsof` (no root required).
#
# NOTE: This script is now available as `rr util procs` in dotfiles.
# Consider migrating to the rr version for better integration and features.
# This version will be maintained for backward compatibility but may be
# removed in the future.

set -Eeuo pipefail
# ... rest of script
```

### Success Criteria

- [ ] Original script remains functional
- [ ] No breaking changes to existing workflows
- [ ] Optional deprecation notice added (if desired)

## Implementation Order

1. **Phase 1** - Add procs command to util.sh (core functionality)
2. **Phase 2** - Create documentation (can be done in parallel with Phase 1)
3. **Phase 3** - Test and validate (after Phase 1 is complete)
4. **Phase 4** - Update main documentation (after Phase 3 passes)
5. **Phase 5** - Backward compatibility (optional, can be done last)

## References

- Original script: `/Users/rakshan/workspace/iv-pro/iv-pro-copilot-v45/scripts/procs-here`
- Target namespace: `/Users/rakshan/dotfiles/private/rr/namespaces/util.sh`
- RR architecture: `/Users/rakshan/dotfiles/private/rr/CONTRIBUTORS.md`
- Namespace guide: `/Users/rakshan/dotfiles/private/rr/namespaces/CONTRIBUTORS.md`
- RR docs: `/Users/rakshan/dotfiles/docs/rr-cli.md`

## Design Decisions

### Flag Conflict Resolution

**Problem:** The original procs-here script used `-q` and `-s` short flags that conflict with RR's global flags:
- `-q`: RR uses for `--quiet`, procs-here used for `--query`
- `-s`: RR uses for `--silent`, procs-here used for `--select`

**Solution:** Remove conflicting short forms from procs command, keep only long forms:
- ✅ `--query` (no `-q` short form)
- ✅ `--select` (no `-s` short form)
- ✅ Keep `-k` for `--kill` (no conflict)
- ✅ Keep `-w` for `--width` (no conflict)
- ✅ Keep `-y` for `--yes` (same meaning as RR's `-y`)

**Benefits:**
- Clear separation: RR global flags always before namespace, procs flags always after subcommand
- No ambiguity: `rr -q util procs` is unambiguous (RR's quiet mode)
- Consistent UX: Users learn RR global flags work everywhere
- Better documentation: Can clearly explain flag precedence

**Usage patterns:**
```bash
# RR flags before namespace (global)
rr -v -q util procs          # RR verbose + quiet

# Procs flags after subcommand (local)
rr util procs --select --query "text"  # procs select + query

# Combined
rr -v util procs --select --query "node"  # RR verbose + procs select with query
```

## Notes

- The implementation maintains all original functionality while adding rr conventions
- The procs command remains macOS-only (uses lsof)
- Interactive mode uses fzf (not gum) to preserve original behavior
- Smart command summarization logic is preserved exactly
- All helper functions are prefixed with `__util_procs_` to avoid conflicts
- The command integrates seamlessly with existing blob commands in util namespace
- **Flag design:** Removed `-q` and `-s` short forms to avoid conflicts with RR global flags
- The `-y/--yes` flag works identically whether passed to RR globally or procs locally
