# RR CLI Dispatcher

## Overview

`rr` is a unified command-line interface dispatcher that consolidates scattered shell commands, scripts, and utilities into a well-organized, discoverable namespace structure. It provides a consistent, user-friendly interface for managing dotfiles, system configuration, and development tools.

## Why RR?

Before `rr`, dotfiles commands were scattered across:
- 7 `nix-*` functions in `shell/shell_functions`
- 14 custom bin scripts
- 30+ shell functions across multiple files
- 25+ shell aliases
- 25+ just recipes

**Problems:**
- Hard to discover available commands
- Inconsistent interfaces and flags
- No command history or search
- Limited automation support
- No unified help system

**Solution:**
`rr` provides a namespace-based CLI that organizes commands logically, offers powerful discovery features, and supports both interactive use and automation.

## Quick Start

### Basic Usage

```bash
# Show all available commands
rr help

# Use a command
rr nix switch              # Rebuild Home Manager configuration
rr karabiner build         # Build Karabiner config
rr git branch              # Fuzzy branch selector

# Get help for a namespace
rr nix --help

# View detailed documentation
rr docs nix
```

### Short Aliases

```bash
# Use short aliases for quick access
rr n switch                # Same as: rr nix switch
rr k build                 # Same as: rr karabiner build
rr kb build                # Alternative karabiner alias
```

### Command History

```bash
# Browse and re-run command history
rr history

# Re-run last command
rr last

# Search for commands
rr search build            # Find all commands with "build"
rr which switch            # Show which namespace has "switch"
```

## Key Features

### 1. Namespace Organization

Commands are organized into logical namespaces:
- **nix** - Nix and Home Manager operations (7 commands)
- **karabiner** - Karabiner-Elements configuration (1 command)
- **git** - Git utilities with FZF integration (1 command)
- **tmux** - Tmux session management (multiple commands)
- **server** - Server management utilities (multiple commands)
- **blog**, **brain**, **obsidian** - Additional specialized namespaces

### 2. Non-Interactive Mode

All commands support automation and LLM execution:

```bash
# Interactive mode (default)
rr nix switch              # Shows gum UI with confirmation

# Non-interactive mode (for LLMs/automation)
rr -y nix switch           # No prompts, plain output
rr --yes nix clean
rr --non-interactive nix update
```

**Perfect for:**
- LLM/AI agent execution (Claude Code, Cursor, etc.)
- CI/CD pipelines
- Automation scripts
- Batch operations

### 3. Output Control

Fine-grained control over command output:

```bash
# Quiet mode - suppress stdout (show errors on stderr)
rr -q nix profile          # No "Current Nix profile:" prefix
rr -q nix size             # Just the number: 82.223251776

# Silent mode - suppress all output
rr -s nix switch           # Completely silent rebuild

# Verbose mode - show debug messages
rr -v nix profile          # Shows: [nix] Getting current Nix profile
rr -vv nix profile         # Shows trace messages too

# Bash trace mode
rr --trace nix profile     # Enables set -x for debugging
```

### 4. Structured Output

JSON output for scripting and automation:

```bash
# JSON output
rr --json nix size
# Output: {"size_gb":82.223251776}

# Parse with jq
rr --json nix size | jq '.size_gb'
# Output: 82.223251776

# Custom format
rr --format json nix size
```

### 5. Beautiful UI (Iceberg Theme)

When used interactively, `rr` provides a beautiful terminal UI using [gum](https://github.com/charmbracelet/gum) with the Iceberg color scheme:

- **Teal** (#5fb3b3) - "rr" branding
- **Blue** (#84a0c6) - Headers and UI elements
- **Cyan** (#89b8c2) - Commands
- **Green** (#b4be82) - Flags and options

Theme is configured declaratively via Nix in `nixpkgs/home-manager/modules/zsh.nix`.

### 6. Shell Completion

Zsh completion with dynamic command discovery:

```bash
rr <TAB>                   # Shows all namespaces
rr nix <TAB>               # Shows all nix commands
rr n<TAB>                  # Shows alias completion
```

### 7. Discovery & Search

Powerful tools for discovering commands:

```bash
# Search for commands across all namespaces
rr search build
# Shows: nix:build, karabiner:build, etc.

# Find which namespace has a command
rr which switch
# Output:
# Command: switch
# Namespace: nix
# Usage: rr nix switch
```

### 8. Command History

Automatic command tracking with timing:

```bash
# View history file
cat ~/.config/rr/history
# Format: timestamp|command|exit_code|duration
# Example: 2025-10-20T10:30:45-07:00|rr nix switch|0|45s

# Browse history with fzf
rr history

# Re-run last command
rr last
```

## Available Namespaces

### nix (7 commands)

Manages Nix and Home Manager configurations.

| Command | Description | Features |
|---------|-------------|----------|
| `profile` | Show current profile (mbp/mbpi/linux) | Quiet, Verbose, JSON |
| `build` | Build without activating | Quiet, Verbose |
| `activate` | Activate built configuration | Quiet, Verbose |
| `switch` | Full rebuild with flake updates | Quiet, Verbose, Non-interactive, Gum UI |
| `update` | Update flake inputs only | Quiet, Verbose, Non-interactive, Gum UI |
| `clean` | Garbage collection | Quiet, Verbose, Non-interactive, Gum UI |
| `size` | Show store size | Quiet, Verbose, Non-interactive, Gum UI, JSON |

```bash
# Examples
rr nix profile             # Show: mbp
rr nix switch              # Full rebuild with UI
rr -y nix switch           # Non-interactive rebuild
rr --json nix size         # {"size_gb":82.223251776}
```

**Detailed docs:** `rr docs nix` or see `private/rr/docs/namespaces/nix.md`

### karabiner (1 command)

Manages Karabiner-Elements configuration.

| Command | Description | Features |
|---------|-------------|----------|
| `build` | Build TypeScript rules to JSON | Quiet, Verbose |

```bash
# Examples
rr karabiner build         # Build config from TypeScript
rr kb build                # Using alias
rr -q karabiner build      # Quiet build
```

**Detailed docs:** `rr docs karabiner` or see `private/rr/docs/namespaces/karabiner.md`

### git (1 command)

Git utilities with FZF integration.

| Command | Description | Features |
|---------|-------------|----------|
| `branch` | Fuzzy search and checkout branches | Quiet, Verbose |

```bash
# Examples
rr git branch              # Interactive branch selector
gco                        # Shell alias that uses git-branch internally
```

**Detailed docs:** `rr docs git` or see `private/rr/docs/namespaces/git.md`

### tmux (multiple commands)

Tmux session management utilities.

```bash
# Examples
rr tmux <command>          # See: rr tmux --help
```

**Detailed docs:** `rr docs tmux` or see `private/rr/docs/namespaces/tmux.md`

### server (multiple commands)

Server management utilities.

```bash
# Examples
rr server <command>        # See: rr server --help
```

**Detailed docs:** `rr docs server` or see `private/rr/docs/namespaces/server.md`

## Global Flags

All flags must come **before** the namespace:

### Non-Interactive Mode
- `-y` / `--yes` / `--non-interactive` - Skip all interactive prompts

### Output Control
- `-q` / `--quiet` - Suppress stdout (show errors on stderr)
- `-s` / `--silent` - Suppress all output (stdout and stderr)

### Verbose Modes
- `-v` - Verbose output (show debug messages to stderr)
- `-vv` - Extra verbose (show trace messages to stderr)
- `--trace` - Enable bash trace mode (set -x)

### Output Format
- `--json` - JSON output format (where applicable)
- `--format <format>` - Custom output format

### Flag Examples

```bash
# Non-interactive
rr -y nix switch           # No prompts
rr --yes nix clean
rr --non-interactive nix update

# Output control
rr -q nix profile          # Just "mbp"
rr -s nix switch           # Completely silent
rr -v nix profile          # Show debug messages
rr -vv nix profile         # Show trace messages

# Structured output
rr --json nix size         # JSON output
rr --format json nix size  # Alternative syntax

# Combinations
rr -v -q nix profile       # Debug to stderr, suppress stdout
rr -y -s nix switch        # Non-interactive + silent
```

## Special Commands

### help / --help / -h
Show colorized help with all namespaces and flags.

```bash
rr help
rr --help
rr -h
rr                         # No args shows help too
```

### history
Browse and re-run command history with fzf.

```bash
rr history
```

### last
Re-run the last command.

```bash
rr last
```

### search
Search for commands across all namespaces.

```bash
rr search build            # Find all "build" commands
rr search clean            # Find all "clean" commands
```

### which
Show which namespace contains a command.

```bash
rr which switch
# Output:
# Command: switch
# Namespace: nix
# Usage: rr nix switch
```

### docs
View formatted documentation for a namespace.

```bash
rr docs nix                # View with glow (if installed)
rr docs karabiner
rr docs git
```

## Configuration

### Namespace Aliases

**File:** `~/.config/rr/aliases.conf`

Default aliases:
```conf
# Namespace aliases
# Format: alias=full-namespace

n=nix
g=git
k=karabiner
kb=karabiner
```

**Usage:**
```bash
rr n switch                # Same as: rr nix switch
rr k build                 # Same as: rr karabiner build
```

**Custom aliases:**
Edit `~/.config/rr/aliases.conf` to add your own:
```conf
x=my-namespace
```

### Command History

**File:** `~/.config/rr/history`

Format: `timestamp|command|exit_code|duration`

Example:
```
2025-10-20T10:30:45-07:00|rr nix switch|0|45s
2025-10-20T11:15:23-07:00|rr karabiner build|0|2s
2025-10-20T14:42:11-07:00|rr nix size|0|1s
```

### Gum Theme Configuration

Theme is configured via Nix in `nixpkgs/home-manager/modules/zsh.nix`:

```nix
programs.zsh = {
  sessionVariables = {
    GUM_CONFIRM_SELECTED_BACKGROUND = "110";  # Iceberg blue
    GUM_CONFIRM_PROMPT_FOREGROUND = "110";
    GUM_SPIN_SPINNER_FOREGROUND = "110";
    GUM_STYLE_FOREGROUND = "110";
    GUM_STYLE_BORDER_FOREGROUND = "110";
  };
};
```

Apply changes:
```bash
rr nix switch
```

## Architecture

### Directory Structure

```
private/rr/
├── CONTRIBUTORS.md          # Architecture and implementation guide
├── bin/
│   └── rr                   # Main dispatcher script
├── namespaces/
│   ├── nix.sh              # Nix/Home Manager commands
│   ├── karabiner.sh        # Karabiner configuration
│   ├── git.sh              # Git utilities
│   ├── tmux.sh             # Tmux management
│   ├── server.sh           # Server utilities
│   └── [others].sh         # Additional namespaces
├── completions/
│   └── _rr                 # Zsh completion
├── docs/
│   └── namespaces/         # Detailed namespace docs
└── lib/
    └── common.sh           # Shared helper functions

~/dotfiles/
└── bin/
    └── rr -> ../private/rr/bin/rr  # Symlink for PATH access
```

### Request Flow

```
User Input
    ↓
rr dispatcher (bin/rr)
    ↓
Parse global flags (-y, -q, -v, --json, etc.)
    ↓
Resolve namespace aliases (n → nix)
    ↓
Source shell_functions (existing utilities)
    ↓
Export environment variables (RR_NON_INTERACTIVE, RR_QUIET, etc.)
    ↓
Route to namespace script (namespaces/nix.sh)
    ↓
Execute command (profile, switch, build, etc.)
    ↓
Track to history (~/.config/rr/history)
    ↓
Return result
```

### Environment Variables

Exported by dispatcher, available in namespaces:

```bash
RR_DIR                     # Path to private/rr/
DOTFILES_DIR               # Path to dotfiles root
RR_NON_INTERACTIVE         # "true" when -y/--yes/--non-interactive
RR_QUIET                   # "true" when -q/--quiet
RR_SILENT                  # "true" when -s/--silent
RR_VERBOSE                 # 0 (default), 1 (-v), or 2 (-vv)
RR_OUTPUT_FORMAT           # "default", "json", etc.
```

### Helper Functions

Available in all namespaces (exported from dispatcher):

```bash
rr_stdout <message>        # Normal output (suppressed by --quiet)
rr_stderr <message>        # Error output (shown unless --silent)
rr_info <message>          # Informational (suppressed by --quiet)
rr_error <message>         # Error messages (shown unless --silent)
rr_success <message>       # Success with ✓ (suppressed by --quiet)
rr_fail <message>          # Failure with ✗ (shown unless --silent)
```

Debug/trace functions from `lib/common.sh`:

```bash
debug "namespace" "message"   # Shows when RR_VERBOSE >= 1
trace "namespace" "message"   # Shows when RR_VERBOSE >= 2
```

## Integration with Existing Commands

### Shell Functions

`rr` namespaces can call existing functions from `shell/shell_functions`:

```bash
# In namespaces/nix.sh
switch)
  nix-switch               # Calls existing function
  ;;
```

Available functions include:
- All `nix-*` functions
- Platform detection: `is_mac()`, `is_linux()`
- FZF utilities
- 30+ other shell utilities

### Just Recipes

Just recipes remain independent (accessed via `r` alias):

```bash
r <recipe>                 # Use just directly
```

`rr` does not wrap just recipes.

## Development Guide

### Adding a New Namespace

See detailed guide in `private/rr/CONTRIBUTORS.md` or `private/rr/namespaces/CONTRIBUTORS.md`.

**Quick start:**

1. Create `private/rr/namespaces/<name>.sh`
2. Implement command case statement
3. Add help function
4. Make executable: `chmod +x namespaces/<name>.sh`
5. Test: `rr <name> --help`
6. Document: Create `private/rr/docs/namespaces/<name>.md`

**Template:**

```bash
#!/usr/bin/env bash
# namespaces/<name>.sh - Brief description

CMD="${1:-}"
shift || true

source "$RR_DIR/lib/common.sh"

<name>_help() {
  cat << 'EOF'
Usage: rr <name> <command> [options]

Commands:
  cmd1    Description

Examples:
  rr <name> cmd1

For detailed docs: rr docs <name>
EOF
}

case "$CMD" in
  cmd1)
    debug "<name>" "Executing cmd1"
    # Implementation
    ;;
  --help|help|"")
    <name>_help
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    exit 1
    ;;
esac
```

### Feature Consistency

All commands should implement:

1. **Quiet/Silent support** - Check `RR_QUIET` and `RR_SILENT`
2. **Verbose output** - Use `debug()` and `trace()` functions
3. **Non-interactive mode** - Check `RR_NON_INTERACTIVE`
4. **Help text** - Comprehensive usage information
5. **Exit codes** - 0 for success, 1 for errors

See implementation examples in existing namespaces.

## Troubleshooting

### Completion not working

```bash
# Reload shell
exec zsh

# Or rebuild config
rr nix switch
```

### Gum styling not applied

```bash
# Apply Nix configuration
rr nix switch

# Reload shell
exec zsh
```

### Command not in history

Only `rr` commands are tracked in the history file at `~/.config/rr/history`.

### Alias not recognized

```bash
# Check alias file
cat ~/.config/rr/aliases.conf

# Edit if needed
vim ~/.config/rr/aliases.conf
```

### Verbose mode not showing output

Debug/trace messages go to **stderr**, not stdout:

```bash
# Redirect stderr to see debug output
rr -v nix profile 2>&1

# Or use with quiet to suppress stdout
rr -v -q nix profile
```

## Features

The `rr` CLI includes the following capabilities:

- Core dispatcher with namespace routing
- Command history tracking
- Namespace aliasing
- Smart search and discovery
- Iceberg theme via Nix
- Non-interactive mode (LLM-friendly)
- Shell completion (zsh)
- Quiet/silent/verbose modes
- JSON output (where applicable)
- Comprehensive documentation system
- Feature consistency across namespaces

## Additional Resources

### Documentation

- **Main architecture guide:** `private/rr/CONTRIBUTORS.md`
- **Namespace implementation:** `private/rr/namespaces/CONTRIBUTORS.md`
- **Dispatcher details:** `private/rr/bin/CONTRIBUTORS.md`
- **Individual namespaces:** `private/rr/docs/namespaces/*.md`

### Implementation Plans

- **CLI implementation:** `thoughts/_shared/plans/20251020_rr-cli-dispatcher-implementation.md`
- **Phase 5 tasks:** `thoughts/_shared/plans/20251020_rr-phase5-todo.md`
- **Pattern research:** `thoughts/_shared/research/2025-10-20_22-56-54_rr-namespace-patterns-generalization.md`

### Related Tools

- **gum:** https://github.com/charmbracelet/gum
- **fzf:** https://github.com/junegunn/fzf
- **glow:** https://github.com/charmbracelet/glow

### Existing Code

- **Shell functions:** `shell/shell_functions`
- **Nix configuration:** `nixpkgs/home-manager/modules/zsh.nix`
- **Just recipes:** `justfile`

## Future Enhancements

Potential additions (not currently planned):

- Additional namespaces from bin scripts
- Bash/Fish completion support
- Auto-generated documentation
- Plugin system for third-party namespaces
- Remote namespace loading
- Command aliasing (in addition to namespace aliasing)
- Tab completion for command arguments
- Interactive command builder

## Contributing

When adding features to `rr`:

1. **Maintain backward compatibility** - Don't break existing workflows
2. **Follow the namespace pattern** - Self-contained, help text, error handling
3. **Implement all feature flags** - Quiet, verbose, non-interactive
4. **Document thoroughly** - Help text, markdown docs, examples
5. **Test all modes** - Interactive, non-interactive, quiet, verbose
6. **Update completion** - Zsh completion should discover new commands automatically

See `private/rr/CONTRIBUTORS.md` for detailed contribution guidelines.

---

**Last Updated:** 2025-10-24
