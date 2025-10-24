# Tmux Namespace Implementation Plan for rr CLI

## Overview

Add a new `tmux` namespace to the `rr` CLI dispatcher for managing tmux sessions for common project directories. This namespace will provide simple commands to create/attach to tmux sessions for dotfiles, Obsidian vault, work project, and general projects directory.

## Current State Analysis

### Existing Infrastructure

**Tmux Usage:**
- Existing tmux function `t()` in `shell/shell_functions:114-119`
- Uses fzf for session selection
- Creates or attaches to named sessions
- Current implementation: `t [session-name]` or `t` (interactive)

**Project Directories:**
- `~/dotfiles` - Dotfiles repository
- `~/obsidian-vault` - Obsidian notes (assumed location)
- `~/workspace/iv-pro` - Work project
- `~/projects/` - General projects directory
  - Subdirectories: ai, elixir, go, htpc, node, python, rust

**Existing Patterns:**
- rr CLI infrastructure complete (Phases 1-5 implemented)
- Helper library available: `private/rr/lib/helpers.sh`
- Similar namespaces: `server.sh`, `blog.sh` - Good references for simple commands

### User Request Details

**Commands requested:**
1. `rr tmux dotfiles` - Create/attach to dotfiles tmux session
2. `rr tmux obsidian` - Create/attach to Obsidian tmux session
3. `rr tmux work` - Create/attach to work project tmux session
4. `rr tmux projects` - Create/attach to projects directory tmux session
5. Alias: `rr t` - Short alias for the tmux namespace

**Alternative command suggested:** `tt tmux obsidian`
- Note: This appears to be a typo. The pattern should be `rr t obsidian` using the alias

## Desired End State

### After Implementation

Users can manage tmux sessions using:

```bash
# Full commands
rr tmux dotfiles       # Create/attach to ~/dotfiles session
rr tmux obsidian       # Create/attach to ~/obsidian-vault session
rr tmux work           # Create/attach to ~/workspace/iv-pro session
rr tmux projects       # Create/attach to ~/projects session

# Using alias
rr t dotfiles          # Same as: rr tmux dotfiles
rr t obsidian          # Same as: rr tmux obsidian
rr t work              # Same as: rr tmux work
rr t projects          # Same as: rr tmux projects

# Non-interactive mode (for automation)
rr -y tmux dotfiles    # Skip confirmations
```

### Success Criteria

- ✓ `rr tmux dotfiles` creates/attaches to tmux session in ~/dotfiles
- ✓ `rr tmux obsidian` creates/attaches to tmux session in ~/obsidian-vault
- ✓ `rr tmux work` creates/attaches to tmux session in ~/workspace/iv-pro
- ✓ `rr tmux projects` creates/attaches to tmux session in ~/projects
- ✓ All commands work in tmux (attach) and outside tmux (new terminal)
- ✓ Alias `rr t` resolves to `rr tmux`
- ✓ All commands support quiet/silent/verbose modes
- ✓ Documentation created at `docs/namespaces/tmux.md`

## What We're NOT Doing

To prevent scope creep:

1. **Not replacing the existing `t()` function** - Keep the interactive fzf session selector
2. **Not implementing session management** - No kill, list, or rename commands (use native tmux)
3. **Not configuring tmux** - No tmux configuration management
4. **Not handling .tmux files** - Existing functionality stays in `t()` function
5. **Not managing tmux plugins** - No tmux plugin management
6. **Not creating custom layouts** - Simple session creation only

## Implementation Approach

### Strategy

1. **Leverage existing patterns**: Use `server.sh` and `blog.sh` as templates
2. **Reuse tmux logic**: Call existing `t()` function from shell_functions
3. **Simple implementation**: Just create/attach, no complex management
4. **Keep it focused**: Four specific directory shortcuts, nothing more

### Tmux Commands to Use

```bash
# Check if session exists
tmux has-session -t session-name 2>/dev/null

# Create new session in specific directory
tmux new-session -d -s session-name -c /path/to/directory

# Attach to session (inside tmux)
tmux switch-client -t session-name

# Attach to session (outside tmux)
tmux attach -t session-name

# Combined: create if doesn't exist, then attach
tmux new-session -A -s session-name -c /path/to/directory
```

## Implementation

### Phase 1: Create Tmux Namespace

**Time Estimate**: 45 minutes - 1 hour

#### 1. Create Namespace File

**File**: `private/rr/namespaces/tmux.sh`

**Complete Implementation:**

```bash
#!/usr/bin/env bash
# namespaces/tmux.sh - Manage tmux sessions for common project directories

CMD="${1:-}"
shift || true

# Project directories
DOTFILES_DIR="$HOME/dotfiles"
OBSIDIAN_DIR="$HOME/obsidian-vault"
WORK_DIR="$HOME/workspace/iv-pro"
PROJECTS_DIR="$HOME/projects"

# Source shared helpers
source "$RR_DIR/lib/common.sh"

# Check if gum is available
HAS_GUM=false
command -v gum >/dev/null 2>&1 && HAS_GUM=true

# Helper: Create or attach to tmux session
# Args: session-name directory-path
tmux_session() {
  local session_name="$1"
  local directory="$2"

  debug "tmux" "Session: $session_name, Directory: $directory"

  # Validate directory exists
  if [[ ! -d "$directory" ]]; then
    rr_fail "Directory not found: $directory"
    return 1
  fi

  # Check if we're inside tmux
  if [[ -n "${TMUX:-}" ]]; then
    trace "tmux" "Inside tmux, using switch-client"
    # Inside tmux: switch to session
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
      debug "tmux" "Creating new session: $session_name"
      tmux new-session -d -s "$session_name" -c "$directory"
    fi
    tmux switch-client -t "$session_name"
  else
    trace "tmux" "Outside tmux, using new-session -A"
    # Outside tmux: attach or create
    tmux new-session -A -s "$session_name" -c "$directory"
  fi
}

# Help function
tmux_help() {
  cat <<'EOF'
Usage: rr tmux <command> [options]

Commands:
  dotfiles    Create/attach to tmux session in ~/dotfiles
  obsidian    Create/attach to tmux session in ~/obsidian-vault
  work        Create/attach to tmux session in ~/workspace/iv-pro
  projects    Create/attach to tmux session in ~/projects

Examples:
  # Create or attach to dotfiles session
  rr tmux dotfiles

  # Using alias
  rr t obsidian

  # Non-interactive mode (for automation)
  rr -y tmux work

  # Verbose mode (show debug output)
  rr -v tmux projects

Note: This creates named tmux sessions. Use 't' function for interactive session selection.

For detailed documentation: rr docs tmux
EOF
}

# Command implementations
case "$CMD" in
dotfiles)
  debug "tmux" "Creating/attaching to dotfiles session"
  trace "tmux" "Directory: $DOTFILES_DIR"

  if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
    rr_info "Switching to dotfiles tmux session..."
  fi

  tmux_session "dotfiles" "$DOTFILES_DIR"
  ;;

obsidian)
  debug "tmux" "Creating/attaching to obsidian session"
  trace "tmux" "Directory: $OBSIDIAN_DIR"

  if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
    rr_info "Switching to obsidian tmux session..."
  fi

  tmux_session "obsidian" "$OBSIDIAN_DIR"
  ;;

work)
  debug "tmux" "Creating/attaching to work session"
  trace "tmux" "Directory: $WORK_DIR"

  if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
    rr_info "Switching to work tmux session..."
  fi

  tmux_session "work" "$WORK_DIR"
  ;;

projects)
  debug "tmux" "Creating/attaching to projects session"
  trace "tmux" "Directory: $PROJECTS_DIR"

  if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
    rr_info "Switching to projects tmux session..."
  fi

  tmux_session "projects" "$PROJECTS_DIR"
  ;;

--help | help | "")
  tmux_help
  ;;

*)
  echo "Unknown command: $CMD" >&2
  echo "Run 'rr tmux --help' for usage" >&2
  exit 1
  ;;
esac
```

**Key Features:**
- ✅ Creates or attaches to named tmux sessions
- ✅ Sets working directory for new sessions
- ✅ Handles inside/outside tmux scenarios correctly
- ✅ Validates directories exist before attempting connection
- ✅ Supports quiet/silent/verbose modes via debug/trace
- ✅ Uses helper functions from `lib/common.sh`
- ✅ Simple, focused implementation

#### 2. Create Documentation

**File**: `private/rr/docs/namespaces/tmux.md`

**Content:**

```markdown
# Tmux Namespace Documentation

## Overview

The `tmux` namespace provides commands for quickly creating or attaching to tmux sessions for common project directories. It offers shortcuts to frequently-used workspaces.

## Commands

### rr tmux dotfiles

**Purpose**: Create or attach to a tmux session in the dotfiles directory.

**Syntax**:
```bash
rr tmux dotfiles
```

**What It Does**:
1. Checks if a tmux session named "dotfiles" exists
2. Creates the session in `~/dotfiles` if it doesn't exist
3. Attaches to or switches to the session
4. Sets working directory to `~/dotfiles`

**Examples**:

From outside tmux:
```bash
$ rr tmux dotfiles
Switching to dotfiles tmux session...
# Opens new terminal window attached to dotfiles session
```

From inside tmux:
```bash
$ rr tmux dotfiles
Switching to dotfiles tmux session...
# Switches current tmux window to dotfiles session
```

Verbose mode:
```bash
$ rr -v tmux dotfiles
[tmux] Creating/attaching to dotfiles session
Switching to dotfiles tmux session...
```

**Exit Codes**:
- 0: Success (session created or attached)
- 1: Error (directory not found)

---

### rr tmux obsidian

**Purpose**: Create or attach to a tmux session in the Obsidian vault directory.

**Syntax**:
```bash
rr tmux obsidian
```

**Prerequisites**:
- Obsidian vault exists at `~/obsidian-vault`

**Examples**:

```bash
$ rr tmux obsidian
Switching to obsidian tmux session...
```

Using alias:
```bash
$ rr t obsidian
Switching to obsidian tmux session...
```

**Exit Codes**:
- 0: Success
- 1: Error (directory not found)

---

### rr tmux work

**Purpose**: Create or attach to a tmux session in the work project directory.

**Syntax**:
```bash
rr tmux work
```

**Prerequisites**:
- Work project exists at `~/workspace/iv-pro`

**Examples**:

```bash
$ rr tmux work
Switching to work tmux session...
```

**Exit Codes**:
- 0: Success
- 1: Error (directory not found)

---

### rr tmux projects

**Purpose**: Create or attach to a tmux session in the projects directory.

**Syntax**:
```bash
rr tmux projects
```

**What It Does**:
Opens a session in `~/projects` where you can navigate to various subdirectories:
- `~/projects/ai` - AI projects
- `~/projects/elixir` - Elixir projects
- `~/projects/go` - Go projects
- `~/projects/node` - Node.js projects
- `~/projects/python` - Python projects
- `~/projects/rust` - Rust projects

**Examples**:

```bash
$ rr tmux projects
Switching to projects tmux session...
```

**Exit Codes**:
- 0: Success
- 1: Error (directory not found)

---

## Tmux Session Management

### Session Names

Each command creates a named tmux session:
- `dotfiles` - For `rr tmux dotfiles`
- `obsidian` - For `rr tmux obsidian`
- `work` - For `rr tmux work`
- `projects` - For `rr tmux projects`

### Inside vs Outside Tmux

**Outside tmux** (in a regular terminal):
- Creates session if it doesn't exist
- Attaches to the session
- Blocks current terminal (normal tmux behavior)

**Inside tmux** (already in a tmux session):
- Creates session if it doesn't exist
- Switches to the session
- Keeps you in the same tmux server

### Working with Sessions

```bash
# List all tmux sessions
tmux list-sessions

# Detach from current session
Ctrl-b d

# Kill a session
tmux kill-session -t session-name

# Rename a session
Ctrl-b $
```

## Common Use Cases

### Daily Workflow

**Goal**: Quickly switch between common workspaces

```bash
# Morning: Open dotfiles session
rr tmux dotfiles

# Check emails, then switch to work
Ctrl-b d                    # Detach
rr tmux work               # Switch to work

# Take notes during meeting
Ctrl-b d
rr tmux obsidian

# Back to work
rr tmux work
```

### Using Aliases

**Goal**: Minimize typing with aliases

```bash
# Add to ~/.config/rr/aliases.conf
t=tmux

# Then use:
rr t dotfiles
rr t obsidian
rr t work
rr t projects
```

### Integration with Existing `t()` Function

**Goal**: Use both rr tmux and the interactive selector

```bash
# For predefined workspaces: use rr tmux
rr tmux dotfiles

# For ad-hoc sessions: use t function
t                          # Opens fzf selector
t my-custom-session       # Create/attach to custom session
```

The `t()` function in shell_functions provides:
- Interactive fzf session selection
- Custom session names
- .tmux file execution
- More flexibility for non-standard workflows

## Troubleshooting

### Directory Not Found

**Symptoms**:
```bash
$ rr tmux obsidian
Error: Directory not found: /Users/rakshan/obsidian-vault
```

**Solutions**:
1. Check if directory exists: `ls ~/obsidian-vault`
2. Create directory if needed: `mkdir ~/obsidian-vault`
3. Update namespace file if your vault is in a different location

### Session Already Attached

**Symptoms**:
```
sessions should be nested with care, unset $TMUX to force
```

**Solution**:
This shouldn't happen with the current implementation, as it uses `switch-client` when inside tmux. If you encounter this:
```bash
# Exit current tmux session
exit

# Then run command
rr tmux dotfiles
```

### Can't Switch Sessions

**Symptoms**:
Session is created but you can't switch to it

**Solutions**:
1. Check tmux is running: `tmux list-sessions`
2. Manually attach: `tmux attach -t session-name`
3. Check for tmux configuration issues: `tmux show-options -g`

## Implementation Details

**Namespace File**: `private/rr/namespaces/tmux.sh`

**Key Functions**:
- `tmux_session()` - Core session management logic
- Handles inside/outside tmux scenarios
- Validates directories before creating sessions

**Tmux Commands Used**:
- `tmux has-session -t <name>` - Check if session exists
- `tmux new-session -d -s <name> -c <dir>` - Create detached session
- `tmux switch-client -t <name>` - Switch (when inside tmux)
- `tmux new-session -A -s <name> -c <dir>` - Create or attach

**Environment Variables**:
- `RR_QUIET` - Suppress informational output
- `RR_SILENT` - Suppress all output
- `RR_VERBOSE` - Show debug/trace messages
- `TMUX` - Set when inside tmux (used to detect context)

## Differences from `t()` Function

| Feature | `rr tmux` | `t()` function |
|---------|-----------|----------------|
| **Purpose** | Quick shortcuts to specific dirs | General session management |
| **Session selection** | Explicit command | FZF interactive selector |
| **Directory** | Predefined locations | Current directory or custom |
| **.tmux files** | Not supported | Executes if present |
| **Flexibility** | Limited (4 commands) | Unlimited (any session name) |
| **Use case** | Common workspaces | Ad-hoc sessions |

**When to use which:**
- Use `rr tmux`: For daily workflow with dotfiles, obsidian, work, projects
- Use `t()`: For custom sessions, one-off directories, interactive selection

## See Also

- **Existing t() function**: `shell/shell_functions:114-119`
- **Tmux documentation**: https://github.com/tmux/tmux/wiki
- **Tmux commands**: `man tmux`
- **rr CLI guide**: `private/rr/CONTRIBUTORS.md`
```

#### 3. Add Namespace Alias

**File**: `~/.config/rr/aliases.conf`

**Add line:**
```conf
t=tmux
```

_Note: File is auto-generated on first run. User can add this line manually or during testing._

#### 4. Make Executable

```bash
chmod +x private/rr/namespaces/tmux.sh
```

### Phase 2: Testing

**Time Estimate**: 20-30 minutes

#### Test All Commands

```bash
# Test help
rr tmux help

# Test each command (from outside tmux)
rr tmux dotfiles
# Exit and repeat for others
rr tmux obsidian
rr tmux work
rr tmux projects

# Test alias
rr t dotfiles

# Test verbose mode
rr -v tmux dotfiles
rr -vv tmux obsidian

# Test quiet mode
rr -q tmux work

# Test from inside tmux
rr tmux dotfiles
# Should switch sessions, not nest
```

#### Test Edge Cases

```bash
# Test with non-existent directory
# Temporarily rename obsidian-vault to test error handling
mv ~/obsidian-vault ~/obsidian-vault.bak
rr tmux obsidian  # Should show error
mv ~/obsidian-vault.bak ~/obsidian-vault

# Test session already exists
rr tmux work      # Creates session
rr tmux work      # Should attach to existing

# Test from different directory
cd /tmp
rr tmux dotfiles  # Should still open in ~/dotfiles
pwd               # Should show ~/dotfiles
```

### Phase 3: Documentation and Completion

**Time Estimate**: 10-15 minutes

#### Update Shell Completion

Completion should auto-discover the new namespace. Test with:

```bash
exec zsh  # Reload shell
rr <TAB>  # Should show 'tmux' in list
rr tmux <TAB>  # Should show: dotfiles, obsidian, work, projects
rr t <TAB>  # Should show tmux commands (alias resolution)
```

If completion doesn't work, check:
```bash
# Verify completion file includes alias resolution
cat ~/dotfiles/private/rr/completions/_rr | grep -A5 "alias"
```

## Success Criteria

### Automated Tests

```bash
# Test namespace exists and is executable
[[ -x private/rr/namespaces/tmux.sh ]] && echo "✓ tmux.sh is executable"

# Test help works
rr tmux help | grep -q "Usage" && echo "✓ Help command works"

# Test documentation exists
[[ -f private/rr/docs/namespaces/tmux.md ]] && echo "✓ Documentation exists"

# Test alias is configured
grep -q "^t=tmux" ~/.config/rr/aliases.conf && echo "✓ Alias configured"
```

### Manual Tests

- [ ] `rr tmux help` shows all commands with examples
- [ ] `rr tmux dotfiles` creates/attaches to dotfiles session in ~/dotfiles
- [ ] `rr tmux obsidian` creates/attaches to obsidian session in ~/obsidian-vault
- [ ] `rr tmux work` creates/attaches to work session in ~/workspace/iv-pro
- [ ] `rr tmux projects` creates/attaches to projects session in ~/projects
- [ ] Sessions work correctly when run from outside tmux (attach)
- [ ] Sessions work correctly when run from inside tmux (switch-client)
- [ ] `rr t dotfiles` works (alias resolution)
- [ ] Verbose mode shows debug messages
- [ ] Error messages are clear when directory doesn't exist
- [ ] Documentation is complete and accurate
- [ ] Shell completion works for namespace and commands

## Estimated Timeline

- **Phase 1**: Create namespace - 45 minutes to 1 hour
  - Create namespace file: 20-30 minutes
  - Write documentation: 20-30 minutes
  - Add alias: 2 minutes
- **Phase 2**: Testing - 20-30 minutes
- **Phase 3**: Completion check - 10-15 minutes

**Total**: 1.25 - 1.75 hours

## References

### Existing Code to Reference

- **Similar namespace**: `private/rr/namespaces/server.sh` - Simple commands
- **Helper library**: `private/rr/lib/helpers.sh` - Shared patterns
- **Existing tmux function**: `shell/shell_functions:114-119` - Current implementation
- **Namespace guide**: `private/rr/namespaces/CONTRIBUTORS.md` - Implementation patterns

### Tmux Documentation

- **Tmux manual**: `man tmux`
- **Tmux wiki**: https://github.com/tmux/tmux/wiki
- **Session commands**: https://github.com/tmux/tmux/wiki/Getting-Started#sessions

### Key Files

- **rr dispatcher**: `private/rr/bin/rr`
- **Aliases config**: `~/.config/rr/aliases.conf`
- **rr Architecture**: `private/rr/CONTRIBUTORS.md`

## Notes

### Design Decisions

**Why four specific commands instead of a generic solution?**
- Focused on most common use cases (90% of daily usage)
- Simple, predictable behavior
- Easy to remember
- Existing `t()` function handles the general case

**Why not replace the existing `t()` function?**
- `t()` provides valuable features (fzf selection, .tmux files)
- Complementary tools: `rr tmux` for quick access, `t()` for flexibility
- Backward compatibility with existing workflow

**Why named sessions instead of directory-based?**
- Easier to remember and reference
- More stable (doesn't break if you rename directories)
- Follows tmux best practices

**Session Name Choices:**
- `dotfiles` - Clear, matches directory name
- `obsidian` - Short, recognizable
- `work` - Generic, can be reused if project changes
- `projects` - Matches directory name

### Future Enhancements (Not in Scope)

Potential additions for later:
- `rr tmux list` - List active sessions
- `rr tmux kill <session>` - Kill specific session
- Custom session names: `rr tmux custom ~/path/to/dir`
- `.rr-tmux` config file for custom directories
- Window/pane management
- Session templates

**Decision**: Keep it simple for now. Add features only when needed.
