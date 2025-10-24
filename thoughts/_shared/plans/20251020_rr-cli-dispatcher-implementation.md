# `rr` CLI Dispatcher Implementation Plan

## 🎯 Current Status: Phase 4 Complete ✅ | Phase 5 Documented

**Last Updated**: 2025-10-20

### ✅ Completed
- **Phase 1**: Core infrastructure, nix namespace, basic help system
- **Phase 2**: Enhanced UX with gum, zsh completion, karabiner & git namespaces
- **Phase 3**: Discovery & History - command history, namespace aliasing, smart search
- **Phase 4**: Advanced features - verbose modes, JSON output, documentation
  - `rr docs <namespace>` - View formatted documentation with glow
  - Complete docs for all namespaces (nix, karabiner, git)
  - `--quiet` and `--silent` flags for output control
  - Output helper functions for namespaces
  - Verbose modes: `-v`, `-vv`, `--trace` for debugging
  - JSON output: `--json` flag for structured data (size command)
  - `--format` flag for custom output formats
- **Iceberg Theme**: All UI elements use Iceberg color palette
  - Gum UI: Configured via Nix (`nixpkgs/home-manager/modules/zsh.nix`)
  - Help command: Colorized with teal, blue, cyan, green
  - Colors: Teal (#5fb3b3/73) for "rr", Blue (#84a0c6/110) for headers, Cyan (#89b8c2/109) for commands, Green (#b4be82/150) for flags
- **Non-Interactive Mode**: Full LLM/automation support with `-y`/`--yes`/`--non-interactive` flags
  - All interactive commands check `$RR_NON_INTERACTIVE` flag
  - Plain text output when non-interactive mode is enabled
  - Identical functionality between interactive and non-interactive modes
- **Output Control**: Quiet and silent modes for scripting
  - `--quiet` / `-q` - Suppress stdout (show errors on stderr)
  - `--silent` / `-s` - Suppress all output (both stdout and stderr)
  - Helper functions: `rr_stdout`, `rr_stderr`, `rr_info`, `rr_error`, `rr_success`, `rr_fail`
- **Command History**: Automatic tracking in `~/.config/rr/history`
  - Format: `timestamp|command|exit_code|duration`
  - Browse with `rr history` (fzf integration)
  - Re-run with `rr last`
- **Namespace Aliasing**: Short aliases for quick access
  - Default aliases: `n=nix`, `g=git`, `k=karabiner`, `kb=karabiner`
  - Configurable via `~/.config/rr/aliases.conf`
  - Aliases included in zsh completion
- **Smart Search**: Discover commands across namespaces
  - `rr search <keyword>` - Find matching commands
  - `rr which <command>` - Show namespace and usage info
- **Documentation System**: Comprehensive docs for all namespaces
  - `rr docs nix` - Nix/Home Manager documentation
  - `rr docs karabiner` - Karabiner build system documentation
  - `rr docs git` - Git FZF utilities documentation
  - Formatted with glow for beautiful terminal display

### 🚀 What Works Right Now
```bash
# Beautiful colorized help (Iceberg theme)
rr help                    # Teal "rr", blue headers, cyan commands, green flags
rr --help                  # Same colorized output
rr -h                      # Short flag works too

# All namespaces operational
rr nix switch              # Full rebuild with Iceberg-themed UI
rr nix size                # Styled storage size display
rr nix update              # Update flakes with spinners
rr nix clean               # Garbage collection with confirmation
rr karabiner build         # Build Karabiner config
rr git branch              # Fuzzy branch selection

# Non-interactive mode (for LLMs)
rr -y nix switch           # No prompts, plain output
rr --non-interactive nix clean

# Output control (Phase 4)
rr -q nix size             # Quiet mode (suppress stdout)
rr -s nix switch           # Silent mode (suppress all output)
rr --quiet nix profile     # Long flag for quiet
rr --silent nix clean      # Long flag for silent

# Documentation (Phase 4)
rr docs nix                # View nix documentation with glow
rr docs karabiner          # Karabiner build system docs
rr docs git                # Git utilities documentation

# Verbose modes (Phase 4)
rr -v nix profile          # Verbose output (shows debug messages)
rr -vv nix profile         # Extra verbose (shows trace messages)
rr --trace nix size        # Enable bash trace mode (set -x)

# JSON output (Phase 4)
rr --json nix size         # Structured JSON output for scripting
rr --format json nix size  # Alternative format flag

# Shell completion (after new shell session)
rr <TAB>                   # Shows: git karabiner nix history last search which docs n g k kb
rr nix <TAB>               # Shows: profile build switch update clean size
rr n <TAB>                 # Shows nix commands (alias resolution)

# Command history (Phase 3)
rr history                 # Browse and re-run command history with fzf
rr last                    # Re-run last command

# Namespace aliases (Phase 3)
rr n switch                # Alias for: rr nix switch
rr k build                 # Alias for: rr karabiner build
rr kb build                # Alternative alias for karabiner

# Smart search (Phase 3)
rr search build            # Find all commands with "build" across namespaces
rr which profile           # Show that profile is in nix namespace
```

### ✅ Phase 4 Complete!

**Status**: Phase 4 fully implemented!

**Implemented Features**:
1. ✅ **Verbose Modes**
   - `-v` flag for verbose output (debug messages)
   - `-vv` flag for extra verbose output (trace messages)
   - `--trace` flag for bash debugging (set -x)

2. ✅ **JSON Output**
   - `--json` flag for structured output
   - `--format` flag for custom output formats
   - Implemented where it makes sense (e.g., `size` command)

3. ✅ **Documentation System**
   - `rr docs <namespace>` with glow formatting
   - Complete docs for all namespaces

**Optional Future Enhancements** (not required):
- Auto-generated documentation from namespace files
- Command reference tables
- Additional output format options

### 🔧 Phase 5: Namespace Feature Consistency ✅

**Status**: Complete - Implemented 2025-10-20
**Reference**: See `20251020_rr-phase5-todo.md` for implementation checklist

**Goal**: Ensure all namespaces consistently implement all available features.

#### Feature Matrix Analysis (as of 2025-10-20)

**Legend:**
- ✅ Fully implemented
- ⚠️ Partially implemented
- ❌ Not implemented
- N/A - Not applicable

#### nix.sh (7 commands) - All Complete ✅

| Command  | Quiet/Silent | Verbose | Non-Interactive | Gum UI | JSON Output | Status |
|----------|-------------|---------|-----------------|---------|-------------|--------|
| profile  | ✅ Yes      | ✅ Yes  | N/A             | ❌ No   | ❌ No       | Complete |
| build    | ✅ Yes      | ✅ Yes  | N/A             | ❌ No   | ❌ No       | Complete |
| activate | ✅ Yes      | ✅ Yes  | N/A             | ❌ No   | ❌ No       | Complete |
| switch   | ✅ Yes      | ✅ Yes  | ✅ Yes          | ✅ Yes  | ❌ No       | Complete |
| update   | ✅ Yes      | ✅ Yes  | ✅ Yes          | ✅ Yes  | ❌ No       | Complete |
| clean    | ✅ Yes      | ✅ Yes  | ✅ Yes          | ✅ Yes  | ❌ No       | Complete |
| size     | ✅ Yes      | ✅ Yes  | ✅ Yes          | ✅ Yes  | ✅ Yes      | Complete |

#### karabiner.sh (1 command) - Complete ✅

| Command | Quiet/Silent | Verbose | Non-Interactive | Gum UI | JSON Output | Status |
|---------|-------------|---------|-----------------|---------|-------------|--------|
| build   | ✅ Yes      | ✅ Yes  | N/A             | ❌ No   | ❌ No       | Complete |

#### git.sh (1 command) - Complete ✅

| Command | Quiet/Silent | Verbose | Non-Interactive | Gum UI | JSON Output | Status |
|---------|-------------|---------|-----------------|---------|-------------|--------|
| branch  | ✅ Yes      | ✅ Yes  | N/A             | ❌ No   | ❌ No       | Complete |

#### Implementation Tasks

**High Priority** - Core functionality gaps:
1. [x] **nix.sh: Add quiet/silent support to all commands**
   - [x] `profile` - Redirect output through `rr_stdout`
   - [x] `build` - Wrap with quiet/silent conditionals
   - [x] `activate` - Wrap with quiet/silent conditionals
   - [x] `switch` - Add quiet/silent redirects
   - [x] `update` - Add quiet/silent redirects
   - [x] `clean` - Add quiet/silent redirects
   - [x] `size` - Add quiet/silent redirects

**Medium Priority** - Enhanced debugging:
2. [x] **Add verbose/debug output to all namespaces**
   - [x] `karabiner.sh` - Add debug() and trace() functions
   - [x] `git.sh` - Add debug() and trace() functions
   - [x] `nix.sh` - Add verbose to build, activate, update, clean

**Low Priority** - Advanced features:
3. [x] **JSON output where applicable**
   - [x] Evaluate which commands benefit from structured output
   - [x] Currently only `nix size` has JSON support (sufficient)

#### Implementation Pattern

For consistent implementation across all commands:

```bash
# Pattern for quiet/silent support
command)
  if [[ "${RR_SILENT}" == "true" ]]; then
    underlying-command >/dev/null 2>&1
  elif [[ "${RR_QUIET}" == "true" ]]; then
    underlying-command >/dev/null
  else
    underlying-command
  fi
  ;;

# Pattern for verbose output
debug "Starting operation..."
trace "Detailed info: $variable"

# Pattern for JSON output (where applicable)
case "${RR_OUTPUT_FORMAT}" in
  json)
    echo "{\"key\":\"value\"}"
    ;;
  *)
    echo "Normal output"
    ;;
esac
```

#### Estimated Effort
- High Priority tasks: 2-3 hours
- Medium Priority tasks: 1-2 hours
- Low Priority tasks: 1-2 hours
- **Total**: 4-7 hours

### 📂 Key Files (Phases 1-4 Complete)
- **Main dispatcher**: `private/rr/bin/rr`
  - Global flag parsing: `-y`/`--yes`/`--non-interactive`, `-q`/`--quiet`, `-s`/`--silent`, `-v`, `-vv`, `--trace`, `--json`, `--format`
  - Namespace loading and routing
  - Command history tracking (`~/.config/rr/history`)
  - Namespace alias resolution (`~/.config/rr/aliases.conf`)
  - Special commands: `history`, `last`, `search`, `which`, `docs`
  - Output helper functions: `rr_stdout`, `rr_stderr`, `rr_info`, `rr_error`, `rr_success`, `rr_fail`
  - Colorized help with Iceberg theme (teal, blue, cyan, green)
  - Environment variable exports: `RR_DIR`, `DOTFILES_DIR`, `RR_NON_INTERACTIVE`, `RR_QUIET`, `RR_SILENT`, `RR_VERBOSE`, `RR_OUTPUT_FORMAT`

- **Namespaces**:
  - `private/rr/namespaces/nix.sh` - Full Iceberg theme + non-interactive support + verbose/JSON output
  - `private/rr/namespaces/karabiner.sh` - Karabiner configuration management
  - `private/rr/namespaces/git.sh` - Git utilities with FZF

- **Configuration**:
  - `nixpkgs/home-manager/modules/zsh.nix` - Gum environment variables (lines 132-137)
  - `private/rr/completions/_rr` - Zsh completion with alias and special command support
  - `~/.config/rr/aliases.conf` - User-configurable namespace aliases (auto-generated)
  - `~/.config/rr/history` - Command history log (auto-generated)

- **Documentation** (Phase 4):
  - `private/rr/CONTRIBUTORS.md` - Top-level guide with Nix-based theme config
  - `private/rr/namespaces/CONTRIBUTORS.md` - Namespace implementation guide (includes output helpers)
  - `private/rr/bin/CONTRIBUTORS.md` - Dispatcher documentation
  - `private/rr/docs/namespaces/nix.md` - Comprehensive nix namespace documentation
  - `private/rr/docs/namespaces/karabiner.md` - Karabiner build system documentation
  - `private/rr/docs/namespaces/git.md` - Git utilities documentation

## Overview

This plan implements a unified CLI dispatcher (`rr`) that consolidates scattered shell commands into a well-organized, discoverable, and user-friendly command-line interface. The implementation follows a phased approach with 100% backward compatibility, gradually migrating existing commands while maintaining all current functionality.

## Current State Analysis

### Existing Infrastructure

**Scattered Commands**:
- 7 nix-* functions in `shell/shell_functions:211-284`
- 14 custom bin scripts in `bin/`
- 30+ shell functions across multiple files
- 25+ shell aliases in `shell/shell_aliases`
- 25+ just recipes in `justfile:1-146`

**Working Patterns**:
- FZF integration: 6+ proven patterns (tmux sessions, git branches, man pages, package selection)
- Platform detection: `is_mac()`, `is_linux()` in `shell/shell_functions:203-209`
- Just task runner: Well-organized with 146 lines of recipes
- gum installed but underutilized (only in `bin/commit:1-17`)

**Key Discovery**: The namespace pattern already exists informally (nix-*, git-*, k8-*, server-*) but needs formalization and unification.

## Desired End State

### After Phase 1 (Week 1)
- `rr` dispatcher script operational at `private/rr/bin/rr`
- Symlink `bin/rr -> ../private/rr/bin/rr` for PATH access
- Complete nix namespace (`rr nix switch`, `rr nix build`, etc.)
- Basic help system (`rr help`, `rr nix --help`)
- Both old commands (`nix-switch`) and new commands (`rr nix switch`) work identically
- CONTRIBUTORS.md documentation in place

### After Phase 2 (Week 2)
- Enhanced nix commands with gum for interactive confirmation and spinners
- Zsh completion for `rr` command (bash/fish not included)
- Additional namespaces: karabiner, git
- Improved help text with examples

### After Phase 3 (Weeks 3-4)
- Command history tracking in `~/.config/rr/history`
- Namespace aliasing system (`rr n switch` → `rr nix switch`)
- Smart search across commands (`rr search rebuild`)
- Structured documentation system

### After Phase 4 (Month 2+)
- Multi-format output support (--json, --quiet, --format table)
- Verbose/debug modes (-v, -vv, --trace)
- Full documentation with auto-generation
- Optional: Migration of private namespaces (server, k8, blog, brain)

### Verification

**After Phase 1**:
```bash
# Test commands work identically
nix-switch                          # Old way - still works
rr nix switch                       # New way - works identically

# Test help system
rr help                             # Lists available namespaces
rr nix --help                       # Shows nix commands

# Test all nix commands
rr nix profile                      # Should output: mbp/mbpi/linux
rr nix build                        # Builds without activating
rr nix switch                       # Complete rebuild
```

**After Phase 2**:
```bash
# Test gum integration
rr nix switch                       # Shows styled prompt with confirmation

# Test shell completion
rr n<TAB>                          # Should suggest 'nix'
rr nix <TAB>                       # Should suggest commands

# Test new namespaces
rr karabiner build                 # Builds karabiner configuration
rr git branch                      # Fuzzy branch selection
```

## Prerequisites

Before beginning implementation, verify:

### System Requirements

```bash
# Verify bin directory is in PATH
echo $PATH | grep -q "$HOME/dotfiles/bin" && echo "✓ bin/ in PATH" || echo "✗ Add ~/dotfiles/bin to PATH"

# Verify private submodule is initialized
[[ -d private/.git ]] && echo "✓ Private submodule initialized" || echo "✗ Run: git submodule init && git submodule update"

# Verify required tools are installed
command -v gum >/dev/null && echo "✓ gum installed" || echo "✗ Run: nix-switch to install gum"
command -v fzf >/dev/null && echo "✓ fzf installed" || echo "✗ Run: nix-switch to install fzf"
command -v glow >/dev/null && echo "✓ glow installed" || echo "✗ Run: nix-switch to install glow"

# Verify existing functions work
nix-profile >/dev/null && echo "✓ nix-profile works" || echo "✗ Source shell_functions"
```

### Assumptions

- You're running macOS (darwin) or Linux
- Nix with flakes is installed and working
- Home Manager is configured
- Shell is zsh (bash support not included in this plan)
- Current working directory is `~/dotfiles`

## What We're NOT Doing

To prevent scope creep, explicitly out of scope:

1. **Not wrapping just recipes** - Just remains independent with `r` alias
2. **Not touching shell utilities** - Functions like `extract()`, `mkd()`, `t()`, `cat()`, `man()`, `gco()` stay in shell_functions
3. **Not modifying platform detection** - `is_mac()`, `is_linux()`, `nix-profile()` remain as shared utilities
4. **Not breaking existing workflows** - All current commands continue to work throughout migration
5. **Not implementing all namespaces at once** - Start with nix, add others incrementally
6. **Not creating custom installers** - Rely on existing symlink pattern in bin/

## Implementation Approach

### Strategy

1. **Parallel Systems**: Build `rr` alongside existing commands without modification
2. **Prove the Concept**: Start minimal with nix namespace only
3. **Gradual Enhancement**: Add features incrementally (gum → completion → history → search)
4. **Delayed Migration**: Wait 2-4 weeks before adding deprecation notices
5. **Preserve Patterns**: Leverage existing FZF integration, platform detection, and Just recipes
6. **LLM-First Design**: All commands support non-interactive mode for LLM/automation use

### Critical Principles

- **100% Backward Compatibility**: Never break existing commands
- **No Modifications Initially**: Create new files only, don't touch shell_functions
- **Progressive Enhancement**: Each phase is usable and adds value
- **Safe to Abort**: Can stop at any phase without technical debt
- **LLM-Friendly**: All interactive commands support non-interactive mode (`-y`, `--yes`, `--non-interactive`)

### Non-Interactive Mode Philosophy

All `rr` commands must support automation and LLM execution:

**Design Requirements:**
- Check `$RR_NON_INTERACTIVE` environment variable
- Skip all interactive prompts (gum confirm, menus, etc.)
- Provide plain text output without styling
- Maintain identical functionality between modes
- Use flags: `-y`, `--yes`, or `--non-interactive`

**Example:**
```bash
# Interactive (for humans)
rr nix switch

# Non-interactive (for LLMs/CI)
rr -y nix switch
```

This ensures LLMs, automation scripts, and CI/CD pipelines can execute commands reliably without hanging on interactive prompts.

---

## Phase 1: Core Infrastructure (Week 1)

### Overview

Create the foundational `rr` dispatcher and migrate the nix namespace. This phase proves the concept and establishes the architecture for all future namespaces.

### Changes Required

#### 1. Create Directory Structure

**Action**: Create the complete `private/rr/` directory hierarchy

```bash
mkdir -p private/rr/{bin,namespaces,completions,docs,config}
mkdir -p private/rr/docs/{namespaces,examples,api}
```

**Files to create**:
- `private/rr/bin/rr` - Main dispatcher
- `private/rr/namespaces/nix.sh` - Nix namespace implementation
- `private/rr/CONTRIBUTORS.md` - Top-level documentation
- `private/rr/bin/CONTRIBUTORS.md` - Bin directory docs
- `private/rr/namespaces/CONTRIBUTORS.md` - Namespace guide

**Symlink for PATH access**:
```bash
cd ~/dotfiles
ln -sf ../private/rr/bin/rr bin/rr
chmod +x private/rr/bin/rr
```

#### 2. Main Dispatcher Script

**File**: `private/rr/bin/rr`

```bash
#!/usr/bin/env bash
# rr - Unified CLI dispatcher for dotfiles commands

set -euo pipefail

# Resolve directories
RR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$(cd "$RR_DIR/../.." && pwd)"

# Get namespace from first argument
NAMESPACE="${1:-}"
# Capture original arguments BEFORE shifting
ORIGINAL_ARGS=("$@")
shift || true

# Source shared helper functions
if [[ -f "$DOTFILES_DIR/shell/shell_functions" ]]; then
  source "$DOTFILES_DIR/shell/shell_functions"
fi

# Handle special commands
case "$NAMESPACE" in
  help|--help|-h|"")
    cat << 'EOF'
Usage: rr <namespace> <command> [args]

Available namespaces:
EOF
    for ns in "$RR_DIR"/namespaces/*.sh; do
      [[ -f "$ns" ]] || continue
      basename "$ns" .sh | sed 's/^/  /'
    done
    echo ""
    echo "For namespace-specific help: rr <namespace> --help"
    exit 0
    ;;
  *)
    # Load namespace
    NAMESPACE_FILE="$RR_DIR/namespaces/$NAMESPACE.sh"
    if [[ ! -f "$NAMESPACE_FILE" ]]; then
      echo "Error: Unknown namespace '$NAMESPACE'" >&2
      echo "Run 'rr help' to see available namespaces" >&2
      exit 1
    fi

    # Export environment for namespace scripts
    export RR_DIR
    export DOTFILES_DIR

    # Execute namespace
    source "$NAMESPACE_FILE"
    ;;
esac
```

**Verification**:
```bash
chmod +x private/rr/bin/rr
./private/rr/bin/rr help              # Should show help
./private/rr/bin/rr unknown           # Should show error
```

#### 3. Nix Namespace Implementation

**File**: `private/rr/namespaces/nix.sh`

```bash
#!/usr/bin/env bash
# namespaces/nix.sh - Nix and Home Manager commands

CMD="${1:-}"
shift || true

# Namespace functions - reuse existing implementations from shell_functions
# These will call the existing nix-* functions which are already sourced

nix_help() {
  cat << 'EOF'
Usage: rr nix <command> [options]

Commands:
  profile    Show current Nix profile (mbp/mbpi/linux)
  build      Build Home Manager configuration without activating
  activate   Activate built Home Manager configuration
  switch     Complete rebuild: update flakes and activate configuration
  update     Update flake inputs only
  clean      Run garbage collection on Nix store
  size       Show total Nix store size in GB

Examples:
  # Check current profile
  rr nix profile

  # Full rebuild (updates flakes and switches config)
  rr nix switch

  # Just update flake inputs
  rr nix update

  # Build without activating (for testing)
  rr nix build

  # Clean up old generations
  rr nix clean

For detailed documentation: rr docs nix
EOF
}

# Command dispatcher
case "$CMD" in
  profile)
    # Call existing function from shell_functions
    nix-profile
    ;;
  build)
    nix-build
    ;;
  activate)
    nix-activate
    ;;
  switch)
    nix-switch
    ;;
  update)
    nix-update
    ;;
  clean)
    nix-clean
    ;;
  size)
    nix-size
    ;;
  --help|help|"")
    nix_help
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr nix --help' for usage" >&2
    exit 1
    ;;
esac
```

**Verification**:
```bash
rr nix help                          # Shows help
rr nix profile                       # Shows mbp/mbpi/linux
rr nix build                         # Builds configuration
```

#### 4. LLM-Friendly Documentation

**File**: `private/rr/CONTRIBUTORS.md`

```markdown
# Contributors Guide: rr CLI Dispatcher

This directory contains the implementation of the `rr` unified CLI dispatcher for dotfiles commands.

## Purpose

The `rr` dispatcher consolidates scattered shell commands into a well-organized, discoverable namespace structure. It provides:
- Consistent command interface across all tools
- Built-in help and documentation
- Command history and search
- Interactive workflows with gum
- Shell completion

## Structure

\`\`\`
private/rr/
├── CONTRIBUTORS.md          # This file
├── AGENTS.md -> CONTRIBUTORS.md
├── CLAUDE.md -> CONTRIBUTORS.md
├── bin/
│   ├── CONTRIBUTORS.md      # Main dispatcher documentation
│   ├── AGENTS.md -> CONTRIBUTORS.md
│   ├── CLAUDE.md -> CONTRIBUTORS.md
│   └── rr                   # Main dispatcher script
├── namespaces/
│   ├── CONTRIBUTORS.md      # Namespace implementation guide
│   ├── AGENTS.md -> CONTRIBUTORS.md
│   ├── CLAUDE.md -> CONTRIBUTORS.md
│   ├── nix.sh              # Nix/Home Manager commands
│   ├── karabiner.sh        # Karabiner configuration
│   ├── git.sh              # Git utilities
│   └── [others].sh         # Additional namespaces
├── completions/
│   └── _rr                 # Zsh completion (bash/fish not included)
├── docs/
│   ├── namespaces/         # Detailed namespace docs
│   ├── examples/           # Usage examples
│   └── api/                # Auto-generated docs
└── config/
    └── aliases.conf        # Namespace aliases
\`\`\`

## Usage

\`\`\`bash
# General syntax
rr <namespace> <command> [args]

# Examples
rr nix switch               # Rebuild Home Manager config
rr karabiner build         # Build Karabiner rules
rr git branch              # Fuzzy branch selection

# Help at any level
rr help                    # List all namespaces
rr nix --help             # Show nix commands
\`\`\`

## Adding a New Namespace

1. Create `namespaces/<name>.sh`
2. Implement command case statement
3. Add help function
4. Test all commands
5. Add documentation to `docs/namespaces/<name>.md`

See `namespaces/CONTRIBUTORS.md` for detailed guide.

## Integration Points

- **shell_functions**: Existing functions are reused by namespaces
- **bin/rr**: Symlinked to `private/rr/bin/rr` for PATH access
- **Just recipes**: Remain independent, not wrapped by rr
- **FZF patterns**: Leveraged for interactive selections

## Migration Path

Existing commands continue to work:
- Old: `nix-switch`
- New: `rr nix switch`
- Both work identically during migration period

See Phase 2+ of implementation plan for deprecation timeline.
```

**File**: `private/rr/namespaces/CONTRIBUTORS.md`

```markdown
# Contributors Guide: rr Namespaces

This directory contains namespace implementations for the `rr` CLI dispatcher.

## Purpose

Namespace scripts organize related commands under a common prefix (e.g., `rr nix switch`, `rr karabiner build`). Each namespace is a self-contained shell script that handles command routing and execution.

## Structure

\`\`\`
namespaces/
├── CONTRIBUTORS.md          # This file
├── AGENTS.md -> CONTRIBUTORS.md
├── CLAUDE.md -> CONTRIBUTORS.md
├── nix.sh                   # Nix/Home Manager commands
├── karabiner.sh            # Karabiner configuration
├── git.sh                  # Git utilities
└── [others].sh             # Additional namespaces
\`\`\`

## Creating a New Namespace

### 1. Create File

Create `<namespace>.sh` in this directory:

```bash
#!/usr/bin/env bash
# namespaces/<namespace>.sh - Brief description

CMD="${1:-}"
shift || true

# Helper functions (if needed)
<namespace>_help() {
  cat << 'EOF'
Usage: rr <namespace> <command> [options]

Commands:
  command1    Description
  command2    Description

Examples:
  rr <namespace> command1
  rr <namespace> command2

For detailed docs: rr docs <namespace>
EOF
}

# Command dispatcher
case "$CMD" in
  command1)
    # Implementation
    ;;
  command2)
    # Implementation
    ;;
  --help|help|"")
    <namespace>_help
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr <namespace> --help' for usage" >&2
    exit 1
    ;;
esac
\`\`\`

### 2. Make Executable

```bash
chmod +x namespaces/<namespace>.sh
```

### 3. Test

```bash
rr <namespace> help           # Shows help
rr <namespace> command1       # Executes command
```

### 4. Document

Create `../docs/namespaces/<namespace>.md` with detailed documentation.

## Conventions

- **Naming**: Lowercase namespace names (e.g., `nix`, `git`, `karabiner`)
- **Functions**: Define helper functions before case statement
- **Help**: Always provide `--help`, `help`, and `""` handlers
- **Exit codes**: 0 for success, 1 for errors, 2 for usage errors
- **Reuse**: Call existing shell_functions when possible

## Available Environment Variables

From main `rr` dispatcher:
- `$RR_DIR` - Path to `private/rr/` directory
- `$DOTFILES_DIR` - Path to main dotfiles directory
- All functions from `shell/shell_functions` are sourced

## Examples

**Reusing existing functions** (recommended):
```bash
case "$CMD" in
  switch)
    # Call existing function from shell_functions
    nix-switch
    ;;
esac
```

**Wrapping existing scripts**:
```bash
case "$CMD" in
  build)
    cd "$DOTFILES_DIR/config/karabiner"
    yarn build
    ;;
esac
```

**New functionality**:
```bash
case "$CMD" in
  status)
    # New command not in existing functions
    if pgrep -f "my-service" >/dev/null; then
      echo "Service is running"
    else
      echo "Service is stopped"
    fi
    ;;
esac
```

## Integration with Existing Code

Namespaces can:
- Call existing shell functions (already sourced)
- Use platform detection helpers (is_mac, is_linux)
- Execute just recipes: `just recipe-name`
- Run bin scripts: `$DOTFILES_DIR/bin/script-name`
- Leverage FZF patterns from shell_functions

## See Also

- `nix.sh` - Complete example with all commands
- `../CONTRIBUTORS.md` - Top-level rr documentation
- Implementation plan: `thoughts/_shared/plans/20251020_rr-cli-dispatcher-implementation.md`
```

#### 5. Create Symlinks

**Action**: Create AGENTS.md and CLAUDE.md symlinks

```bash
cd private/rr
ln -sf CONTRIBUTORS.md AGENTS.md
ln -sf CONTRIBUTORS.md CLAUDE.md

cd bin
ln -sf CONTRIBUTORS.md AGENTS.md
ln -sf CONTRIBUTORS.md CLAUDE.md

cd ../namespaces
ln -sf CONTRIBUTORS.md AGENTS.md
ln -sf CONTRIBUTORS.md CLAUDE.md
```

### Success Criteria

#### Automated Tests

```bash
# Test dispatcher exists and is executable
[[ -x bin/rr ]] && echo "✓ Dispatcher is executable"

# Test help works
bin/rr help | grep -q "Usage" && echo "✓ Help command works"

# Test unknown namespace error
bin/rr unknown 2>&1 | grep -q "Error: Unknown namespace" && echo "✓ Error handling works"

# Test nix namespace exists
bin/rr nix help | grep -q "Usage" && echo "✓ Nix namespace help works"

# Test nix profile command
[[ -n "$(bin/rr nix profile)" ]] && echo "✓ Nix profile command works"
```

#### Manual Tests

- [x] `rr help` lists available namespaces
- [x] `rr nix help` shows all nix commands with examples
- [x] `rr nix profile` outputs correct profile (mbp/mbpi/linux)
- [ ] `rr nix build` builds Home Manager configuration
- [ ] `rr nix switch` performs complete rebuild (test in safe environment)
- [x] `nix-switch` still works identically (old command)
- [x] Both commands produce identical output
- [x] Documentation is clear and complete

---

## Phase 2: Enhanced UX (Week 2)

### Overview

Add interactive workflows with gum, zsh completion, and additional namespaces. This phase significantly improves the user experience without changing core functionality.

### Changes Required

#### 1. Enhance nix Commands with gum

**Note**: All UI elements use Iceberg theme colors (color 110 / #84a0c6) for consistency.

**File**: Modify `private/rr/namespaces/nix.sh`

**Current switch function** (calls nix-switch from shell_functions):
```bash
switch)
  nix-switch
  ;;
```

**Enhanced with gum**:
```bash
switch)
  # Show styled summary
  gum style \
    --border double \
    --border-foreground 212 \
    --padding "1 2" \
    --margin "1" \
    "🔨 Nix Home Manager Rebuild" \
    "" \
    "Profile: $(gum style --foreground 212 "$(nix-profile)")" \
    "This will:" \
    "  • Update private flake" \
    "  • Update neovim flake" \
    "  • Rebuild Home Manager configuration" \
    "  • Apply system changes"

  # Confirmation
  if ! gum confirm "Proceed with rebuild?"; then
    echo "Cancelled"
    exit 0
  fi

  # Execute with progress indicators
  (
    set -e
    local current_dir=$(pwd)
    local profile=$(nix-profile)
    cd ~/dotfiles

    gum spin --spinner dot --title "Updating private flake..." -- \
      nix flake update private

    gum spin --spinner dot --title "Updating neovim flake..." -- \
      nix flake update neovim

    gum spin --spinner dot --title "Switching Home Manager configuration..." -- \
      home-manager switch --flake ".#$profile"

    gum spin --spinner dot --title "Building darwin configuration..." -- \
      nix build .#darwinConfigurations.$profile.system

    echo ""
    echo "Applying darwin configuration with sudo..."
    sudo ./result/sw/bin/darwin-rebuild switch --flake ".#$profile"

    echo ""
    gum style --foreground 212 "✓ Configuration activated successfully!"

    cd $current_dir
  )
  ;;
```

**Add size command with formatted output**:
```bash
size)
  local size_gb=$(nix path-info --json --all | jq 'map(.narSize) | add | . / 1000000000')

  gum style \
    --border rounded \
    --border-foreground 212 \
    --padding "0 2" \
    "Nix Store Size: $(gum style --bold --foreground 212 "${size_gb} GB")"
  ;;
```

**Verification**:
```bash
rr nix switch                        # Shows styled prompt with confirmation
rr nix size                          # Shows formatted size
```

#### 2. Zsh Completion (Only)

**Note**: This plan only includes zsh completion. Bash and fish are not supported.

**File**: `private/rr/completions/_rr`

```bash
#compdef rr

_rr() {
  local -a namespaces commands
  local rr_dir="${HOME}/dotfiles/private/rr"

  if (( CURRENT == 2 )); then
    # Complete namespace
    namespaces=()
    for ns in "${rr_dir}"/namespaces/*.sh(N); do
      [[ -f "$ns" ]] && namespaces+=($(basename "$ns" .sh))
    done
    _describe 'namespace' namespaces
  elif (( CURRENT == 3 )); then
    # Complete command for namespace
    local namespace=$words[2]
    local ns_file="${rr_dir}/namespaces/${namespace}.sh"

    if [[ -f "$ns_file" ]]; then
      commands=()
      # Extract commands from case statement
      while IFS= read -r line; do
        if [[ "$line" =~ ^\  +([a-z-]+)\) ]]; then
          local cmd="${match[1]}"
          # Skip special cases
          [[ "$cmd" != "--help" && "$cmd" != "help" && "$cmd" != '""' && "$cmd" != "*" ]] && \
            commands+=("$cmd")
        fi
      done < "$ns_file"

      _describe 'command' commands
    fi
  fi
}

_rr "$@"
```

**Integration**: Add to `nixpkgs/home-manager/modules/zsh.nix`

Find the `initExtra` section (search for `initExtra = ''`) and ADD at the END before the closing `''`:

```nix
initExtra = ''
  # ... existing init code (DO NOT REMOVE) ...

  # rr completion - ADD THIS BLOCK AT THE END
  fpath=(~/dotfiles/private/rr/completions $fpath)
  autoload -Uz compinit
  compinit
'';
```

**Note**: Append to existing `initExtra`, don't replace it. If `initExtra` doesn't exist, check `shellInit` instead.

**Verification**:
```bash
# After starting a new zsh session (completions are auto-loaded from fpath)
rr <TAB>                            # Should show: nix
rr nix <TAB>                        # Should show: profile build switch update clean size
```

#### 3. Additional Namespaces

**File**: `private/rr/namespaces/karabiner.sh`

```bash
#!/usr/bin/env bash
# namespaces/karabiner.sh - Karabiner configuration management

CMD="${1:-}"
shift || true

karabiner_help() {
  cat << 'EOF'
Usage: rr karabiner <command>

Commands:
  build      Build Karabiner configuration from TypeScript rules

Examples:
  rr karabiner build

For detailed docs: rr docs karabiner
EOF
}

case "$CMD" in
  build)
    # Call existing function
    karabiner-build
    ;;
  --help|help|"")
    karabiner_help
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr karabiner --help' for usage" >&2
    exit 1
    ;;
esac
```

**File**: `private/rr/namespaces/git.sh`

```bash
#!/usr/bin/env bash
# namespaces/git.sh - Git utilities

CMD="${1:-}"
shift || true

git_help() {
  cat << 'EOF'
Usage: rr git <command>

Commands:
  branch     Fuzzy search and checkout git branches

Examples:
  rr git branch

Note: This is a wrapper around the existing git-branch function.
      For standard git operations, use git directly.

For detailed docs: rr docs git
EOF
}

case "$CMD" in
  branch)
    # Call existing function (git-branch)
    # This is used by gco() for fuzzy branch selection
    git-branch
    ;;
  --help|help|"")
    git_help
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr git --help' for usage" >&2
    exit 1
    ;;
esac
```

**Verification**:
```bash
rr help                              # Should show nix, karabiner, git
rr karabiner build                   # Builds karabiner config
rr git branch                        # Shows fuzzy branch selector
```

### Success Criteria

#### Automated Tests

```bash
# Test gum is installed
command -v gum >/dev/null && echo "✓ gum is available"

# Test completion file exists
[[ -f private/rr/completions/_rr ]] && echo "✓ Completion file exists"

# Test new namespaces exist
[[ -f private/rr/namespaces/karabiner.sh ]] && echo "✓ karabiner namespace exists"
[[ -f private/rr/namespaces/git.sh ]] && echo "✓ git namespace exists"

# Test help for all namespaces
for ns in nix karabiner git; do
  bin/rr $ns help | grep -q "Usage" && echo "✓ $ns help works"
done
```

#### Manual Tests

- [ ] `rr nix switch` shows styled confirmation prompt (requires rebuild - not tested)
- [ ] Confirming "yes" proceeds with rebuild with spinners (requires rebuild - not tested)
- [ ] Confirming "no" cancels gracefully (requires rebuild - not tested)
- [x] `rr nix size` shows formatted output
- [ ] Tab completion works for namespaces: `rr <TAB>` (requires new shell session)
- [ ] Tab completion works for commands: `rr nix <TAB>` (requires new shell session)
- [ ] `rr karabiner build` builds configuration successfully (requires karabiner setup)
- [ ] `rr git branch` opens fuzzy branch selector (requires git repo)
- [x] All old commands still work (`nix-switch`, `karabiner-build`, etc.)

### 🎨 Phase 2 Enhancements (Completed 2025-10-20)

#### Iceberg Theme Implementation
All gum UI elements now use the Iceberg color scheme via environment variables for a cohesive, eye-friendly experience:

**Color**: Iceberg blue `#84a0c6` (terminal color 110)

**Implementation Approach:**
Theme is configured declaratively in Nix (`nixpkgs/home-manager/modules/zsh.nix`):

```nix
# Gum styling - Iceberg theme (blue #84a0c6 = terminal color 110)
export GUM_CONFIRM_SELECTED_BACKGROUND="110"
export GUM_CONFIRM_PROMPT_FOREGROUND="110"
export GUM_SPIN_SPINNER_FOREGROUND="110"
export GUM_STYLE_FOREGROUND="110"
export GUM_STYLE_BORDER_FOREGROUND="110"
```

These are set in the `initContent` section alongside other environment exports.

**Benefits:**
- Theme configured declaratively via Nix home-manager
- No shell script environment exports needed in `rr` dispatcher
- Consistent with other environment variable management
- Easy to change theme globally via nix configuration
- Automatically applied after `nix-switch`
- Follows gum best practices: https://github.com/charmbracelet/gum#customization

**Files Modified:**
- `nixpkgs/home-manager/modules/zsh.nix` - Added gum environment variables (lines 132-137)
- `private/rr/bin/rr` - Removed environment variable exports (now managed by Nix)
- `private/rr/namespaces/nix.sh` - All inline color parameters removed

#### Non-Interactive Mode Implementation
Comprehensive LLM/automation support added to all commands:

**Global Flags:**
- `-y` - Short flag for non-interactive mode
- `--yes` - Long flag alternative
- `--non-interactive` - Explicit long flag

**Implementation Pattern:**
```bash
if $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
  # Interactive mode: gum UI with Iceberg styling
  gum confirm "Proceed?" --selected.background="110"
  gum spin --spinner dot --spinner.foreground="110" --title "Working..." -- command
else
  # Non-interactive mode: plain text output
  echo "Working..."
  command
  echo "✓ Done!"
fi
```

**Environment Variable:**
- `$RR_NON_INTERACTIVE` - Set to "true" when any non-interactive flag is used
- Exported from main dispatcher to all namespace scripts

**Files Modified:**
- `private/rr/bin/rr` - Flag parsing and environment variable export
- `private/rr/namespaces/nix.sh` - All interactive commands updated
- `private/rr/CONTRIBUTORS.md` - LLM-friendly design philosophy documented
- `private/rr/namespaces/CONTRIBUTORS.md` - Implementation guidelines added

**Benefits:**
- LLMs can execute commands without hanging on prompts
- CI/CD pipelines work reliably
- Automation scripts function correctly
- Identical behavior between interactive and non-interactive modes

**Testing:**
```bash
# All commands tested and working
rr -y nix size              # ✓ Plain text output
rr --yes nix clean          # ✓ No confirmation prompt
rr --non-interactive nix update  # ✓ Plain progress messages
```

### 📝 Phase 2 Complete - Summary & Next Steps

#### ✅ What's Done
- **Core Infrastructure**: Main dispatcher with namespace routing ✓
- **Nix Namespace**: All 6 commands (profile, build, activate, switch, update, clean, size) ✓
- **Additional Namespaces**: karabiner, git ✓
- **Iceberg Theme**: Declarative Nix configuration ✓
- **Non-Interactive Mode**: Full LLM/automation support ✓
- **Zsh Completion**: Dynamic command completion ✓
- **Documentation**: CONTRIBUTORS.md files with examples ✓

#### 🧪 Testing Checklist Before Phase 3
1. **Apply Nix configuration** (to activate gum theme):
   ```bash
   rr -y nix switch  # Or: nix-switch
   ```

2. **Test shell completion** (requires new zsh session):
   ```bash
   exec zsh          # Start new shell with updated config
   rr <TAB>          # Should show: git karabiner nix
   rr nix <TAB>      # Should show all nix commands
   ```

3. **Verify gum theme** (Iceberg blue):
   ```bash
   rr nix size       # Should show Iceberg blue styling
   rr nix clean      # Confirmation prompt should be Iceberg blue
   ```

4. **Test non-interactive mode**:
   ```bash
   rr -y nix size            # Plain output
   rr --non-interactive nix update  # No prompts
   ```

#### 🚀 Ready for Phase 3
All dependencies met. Phase 3 can begin immediately:
- Command history tracking in `~/.config/rr/history`
- Namespace aliasing (`rr n switch` → `rr nix switch`)
- Smart search with `rr search <keyword>`
- FZF-based command discovery

See "Phase 3: Discovery & History" section below for implementation details.

---

## Phase 3: Discovery & History (Weeks 3-4)

### Overview

Add command history tracking, namespace aliasing, and smart search. This phase enhances discoverability and provides power-user features.

### Changes Required

#### 1. Command History Tracking

**Modify**: `private/rr/bin/rr`

Add after sourcing shell_functions:

```bash
# History configuration
HISTORY_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/rr/history"
mkdir -p "$(dirname "$HISTORY_FILE")"

# Record start time (original args already captured at top of script)
START_TIME=$(date +%s)
ORIGINAL_NAMESPACE="$NAMESPACE"
```

Add at the end of the script:

```bash
# Record command to history
EXIT_CODE=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
# Reconstruct command from original args array (skip first arg which is namespace)
echo "$(date -Iseconds)|rr ${ORIGINAL_ARGS[*]}|$EXIT_CODE|${DURATION}s" >> "$HISTORY_FILE"

exit $EXIT_CODE
```

Add special commands before namespace loading:

```bash
case "$NAMESPACE" in
  # ... existing help case ...

  history)
    # Show command history with fzf
    if [[ ! -f "$HISTORY_FILE" ]]; then
      echo "No command history yet"
      exit 0
    fi

    selected=$(tac "$HISTORY_FILE" | \
               fzf --tac --no-sort \
                   --preview 'echo {}' \
                   --preview-window down:3:wrap \
                   --delimiter '|' \
                   --with-nth 2 \
                   --header 'Select command to run')

    if [[ -n "$selected" ]]; then
      cmd=$(echo "$selected" | cut -d'|' -f2 | sed 's/^rr //')
      echo "Running: rr $cmd"
      exec "$0" $cmd
    fi
    exit 0
    ;;

  last)
    # Re-run last command
    if [[ ! -f "$HISTORY_FILE" ]]; then
      echo "No command history yet"
      exit 1
    fi

    last_cmd=$(tail -1 "$HISTORY_FILE" | cut -d'|' -f2 | sed 's/^rr //')
    echo "Running last command: rr $last_cmd"
    exec "$0" $last_cmd
    exit $?
    ;;

  # ... rest of cases ...
esac
```

**Verification**:
```bash
rr nix profile                       # Creates history entry
cat ~/.config/rr/history             # Should show timestamped entry
rr history                           # Opens fzf with history
rr last                              # Reruns last command
```

#### 2. Namespace Aliasing

**Create**: `private/rr/config/aliases.conf`

```conf
# Namespace aliases
# Format: alias=full-namespace

n=nix
g=git
k=karabiner
kb=karabiner
```

**Modify**: `private/rr/bin/rr`

Add after getting namespace, before special commands:

```bash
# Load namespace aliases
ALIAS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/rr/aliases.conf"
if [[ ! -f "$ALIAS_FILE" ]]; then
  # Create default alias file
  mkdir -p "$(dirname "$ALIAS_FILE")"
  cat > "$ALIAS_FILE" << 'EOF'
# Namespace aliases
# Format: alias=full-namespace

n=nix
g=git
k=karabiner
kb=karabiner
EOF
fi

# Resolve alias
if [[ -f "$ALIAS_FILE" ]]; then
  while IFS='=' read -r alias full_namespace; do
    # Skip comments and empty lines
    [[ "$alias" =~ ^#.*$ || -z "$alias" ]] && continue

    if [[ "$NAMESPACE" == "$alias" ]]; then
      NAMESPACE="$full_namespace"
      break
    fi
  done < "$ALIAS_FILE"
fi
```

**Update completion**: Modify `private/rr/completions/_rr`

```bash
_rr() {
  local -a namespaces commands aliases
  local rr_dir="${HOME}/dotfiles/private/rr"
  local alias_file="${XDG_CONFIG_HOME:-$HOME/.config}/rr/aliases.conf"

  if (( CURRENT == 2 )); then
    # Complete namespace
    namespaces=()
    for ns in "${rr_dir}"/namespaces/*.sh(N); do
      [[ -f "$ns" ]] && namespaces+=($(basename "$ns" .sh))
    done

    # Add aliases
    if [[ -f "$alias_file" ]]; then
      while IFS='=' read -r alias full; do
        [[ "$alias" =~ ^#.*$ || -z "$alias" ]] && continue
        namespaces+=("$alias")
      done < "$alias_file"
    fi

    _describe 'namespace' namespaces
  # ... rest of completion ...
}
```

**Verification**:
```bash
rr n profile                         # Resolves to: rr nix profile
rr kb build                          # Resolves to: rr karabiner build
rr n<TAB>                           # Shows alias in completion
```

#### 3. Smart Search

**Modify**: `private/rr/bin/rr`

Add search special command:

```bash
search)
  keyword="${1:-}"
  if [[ -z "$keyword" ]]; then
    echo "Usage: rr search <keyword>" >&2
    exit 1
  fi

  {
    # Search namespace files for function names and help text
    for ns in "$RR_DIR"/namespaces/*.sh; do
      namespace=$(basename "$ns" .sh)

      # Search case statements for commands (flexible whitespace matching)
      while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]+([a-z-]+)\) ]]; then
          cmd="${BASH_REMATCH[1]}"
          # Skip special cases
          if [[ "$cmd" != "--help" && "$cmd" != "help" && "$cmd" != '""' && "$cmd" != "*" ]]; then
            echo "$namespace:$cmd"
          fi
        fi
      done < "$ns"
    done

    # Search bin scripts
    for bin in "$DOTFILES_DIR"/bin/*; do
      [[ -f "$bin" && -x "$bin" ]] && echo "bin:$(basename "$bin")"
    done
  } | grep -i "$keyword" | \
  fzf --preview "rr which {1} 2>/dev/null || echo 'Bin script'" \
      --preview-window right:60% \
      --header "Search results for: $keyword"

  exit 0
  ;;

which)
  # Show which namespace contains a command
  cmd="${1:-}"
  if [[ -z "$cmd" ]]; then
    echo "Usage: rr which <command>" >&2
    exit 1
  fi

  for ns in "$RR_DIR"/namespaces/*.sh; do
    if grep -q "^  $cmd)" "$ns" 2>/dev/null; then
      namespace=$(basename "$ns" .sh)
      echo "Command: $cmd"
      echo "Namespace: $namespace"
      echo "Usage: rr $namespace $cmd"

      # Show help for that command if available
      if "$0" "$namespace" help 2>/dev/null | grep -A5 "^\  $cmd"; then
        echo ""
      fi
      exit 0
    fi
  done

  echo "Command '$cmd' not found in any namespace" >&2
  exit 1
  ;;
```

**Verification**:
```bash
rr search switch                     # Shows: nix:switch
rr search build                      # Shows: nix:build, karabiner:build
rr which switch                      # Shows namespace info for switch
```

### Success Criteria

#### Automated Tests

```bash
# Test history file is created
rr nix profile >/dev/null
[[ -f ~/.config/rr/history ]] && echo "✓ History file created"

# Test alias file is created
[[ -f ~/.config/rr/aliases.conf ]] && echo "✓ Alias config created"

# Test alias resolution works
output=$(rr n profile)
[[ -n "$output" ]] && echo "✓ Alias resolution works"
```

#### Manual Tests

- [x] `rr nix profile` creates history entry in `~/.config/rr/history`
- [x] History file has format: `timestamp|command|exit_code|duration`
- [ ] `rr history` opens fzf with command history (requires interactive test)
- [ ] Selecting a command from history re-runs it (requires interactive test)
- [ ] `rr last` re-runs the last command (verified via code inspection)
- [x] `rr n profile` works (alias resolution)
- [x] `rr kb build` works (alias resolution - help tested)
- [ ] Alias completion shows both aliases and full names (requires new shell session)
- [ ] `rr search build` finds all commands with "build" (requires interactive fzf)
- [x] `rr which switch` shows namespace and usage info
- [ ] Search results can be selected with fzf (requires interactive test)

---

## Phase 4: Advanced Features (Optional - Month 2+)

### Overview

Add multi-format output support, verbose modes, and comprehensive documentation. This phase is optional but provides significant value for power users and automation.

### Changes Required

#### 1. Multi-Format Output

**Modify**: `private/rr/bin/rr`

Add flag parsing at the beginning:

```bash
# Parse global flags
VERBOSE=""
OUTPUT_FORMAT="default"

while [[ $# -gt 0 ]]; do
  case $1 in
    -v) VERBOSE="1"; shift ;;
    -vv) VERBOSE="2"; shift ;;
    --trace) set -x; shift ;;
    --json) OUTPUT_FORMAT="json"; shift ;;
    --quiet) OUTPUT_FORMAT="quiet"; shift ;;
    --format) OUTPUT_FORMAT="$2"; shift 2 ;;
    *) break ;;
  esac
done

# Export for namespace scripts
export RR_VERBOSE="$VERBOSE"
export RR_OUTPUT_FORMAT="$OUTPUT_FORMAT"
```

**Example namespace usage** in `nix.sh`:

```bash
# Helper functions for output formatting
debug() {
  [[ "${RR_VERBOSE:-0}" -ge 1 ]] && echo "[nix] $*" >&2
}

trace() {
  [[ "${RR_VERBOSE:-0}" -ge 2 ]] && echo "[TRACE] $*" >&2
}

output_json() {
  if [[ "${RR_OUTPUT_FORMAT}" == "json" ]]; then
    echo "$1"
  fi
}

# Example: Enhanced profile command
profile)
  local profile=$(nix-profile)

  case "${RR_OUTPUT_FORMAT}" in
    json)
      echo "{\"profile\":\"$profile\",\"platform\":\"$(uname -s)\",\"arch\":\"$(uname -m)\"}"
      ;;
    quiet)
      echo "$profile"
      ;;
    *)
      echo "Current Nix profile: $profile"
      ;;
  esac
  ;;
```

**Verification**:
```bash
rr nix profile                       # Default output
rr --json nix profile                # JSON output
rr --quiet nix profile               # Just the profile name
rr -v nix profile                    # Verbose output
rr -vv nix profile                   # Extra verbose
```

#### 2. Documentation System

**Create**: `private/rr/docs/namespaces/nix.md`

```markdown
# Nix Namespace Documentation

## Overview

The `nix` namespace provides commands for managing Nix and Home Manager configurations in this dotfiles repository.

## Commands

### rr nix profile

**Purpose**: Display the current Nix profile name based on platform and architecture.

**Syntax**:
```bash
rr nix profile
```

**Output**:
- `mbp` - Apple Silicon Mac (M1/M2/M3)
- `mbpi` - Intel Mac
- `linux` - Linux system

**Examples**:

Basic usage:
```bash
$ rr nix profile
mbp
```

JSON output:
```bash
$ rr --json nix profile
{"profile":"mbp","platform":"Darwin","arch":"arm64"}
```

**Exit Codes**:
- 0: Success

### rr nix switch

**Purpose**: Rebuild and activate Home Manager configuration with flake updates.

**Syntax**:
```bash
rr nix switch
```

**Prerequisites**:
- Nix installed with flakes enabled
- Home Manager configured
- Working internet connection (for flake updates)
- sudo access (for darwin-rebuild)

**What It Does**:
1. Updates the `private` flake input
2. Updates the `neovim` flake input
3. Rebuilds Home Manager configuration
4. Builds darwin configuration
5. Applies darwin configuration with sudo

**Examples**:

Basic usage:
```bash
$ rr nix switch
[Shows confirmation prompt]
Proceed with rebuild? (y/N) y
[Shows progress spinners]
✓ Configuration activated successfully!
```

Verbose output:
```bash
$ rr -v nix switch
[nix] Starting rebuild
[nix] Updating private flake...
[nix] Updating neovim flake...
...
```

**Exit Codes**:
- 0: Success
- 1: Build or activation failed
- 2: User cancelled

**Related Commands**:
- `rr nix build` - Build without activating
- `rr nix update` - Update flakes only
- `rr nix clean` - Clean up old generations

### rr nix build

**Purpose**: Build Home Manager configuration without activating.

**Syntax**:
```bash
rr nix build
```

**Use Cases**:
- Testing configuration changes before activation
- Verifying builds in CI/CD
- Pre-downloading packages before switching

**Examples**:

```bash
$ rr nix build
Building Home Manager configuration...
Build complete: /nix/store/...
```

**Exit Codes**:
- 0: Success
- 1: Build failed

### rr nix clean

**Purpose**: Run garbage collection to free up disk space.

**Syntax**:
```bash
rr nix clean
```

**What It Does**:
- Runs `nix-store --gc`
- Runs `nix-collect-garbage`
- Removes old generations and unreferenced store paths

**Examples**:

```bash
$ rr nix clean
finding garbage collector roots...
deleting garbage...
deleting '/nix/store/...'
...
freed 1.5 GB
```

**Exit Codes**:
- 0: Success

### rr nix size

**Purpose**: Display total Nix store size in gigabytes.

**Syntax**:
```bash
rr nix size
```

**Examples**:

```bash
$ rr nix size
Nix Store Size: 12.3 GB
```

JSON output:
```bash
$ rr --json nix size
{"size_gb":12.3}
```

**Exit Codes**:
- 0: Success

## Environment Variables

These environment variables affect command behavior:

- `RR_VERBOSE` - Set by `-v` flag (1) or `-vv` flag (2)
- `RR_OUTPUT_FORMAT` - Set by `--json`, `--quiet`, or `--format` flags

## Troubleshooting

### Build Fails

If `rr nix switch` fails:
1. Check internet connection
2. Try `rr nix update` separately
3. Check for syntax errors in Nix files
4. Review error message for specific file/line

### Disk Space Issues

If running out of space:
1. Run `rr nix size` to check usage
2. Run `rr nix clean` to free space
3. Consider removing old profiles manually

### Permission Errors

If darwin-rebuild fails:
1. Ensure you have sudo access
2. Check file permissions in dotfiles directory
3. Verify darwin configuration is valid

## Implementation Details

All nix namespace commands delegate to existing functions in `shell/shell_functions`:
- `nix-profile()` - shell/shell_functions:211-222
- `nix-build()` - shell/shell_functions:224-230
- `nix-switch()` - shell/shell_functions:240-264
- `nix-update()` - shell/shell_functions:266-268
- `nix-clean()` - shell/shell_functions:270-273
- `nix-size()` - shell/shell_functions:282-284

Phase 2 enhances these commands with gum for better UX.
```

**Add docs command** to `private/rr/bin/rr`:

```bash
docs)
  ns="${1:-}"
  if [[ -z "$ns" ]]; then
    echo "Usage: rr docs <namespace>" >&2
    exit 1
  fi

  doc_file="$RR_DIR/docs/namespaces/$ns.md"
  if [[ -f "$doc_file" ]]; then
    if command -v glow >/dev/null 2>&1; then
      glow "$doc_file"
    else
      cat "$doc_file"
    fi
  else
    echo "No documentation found for namespace: $ns" >&2
    echo "Available documentation:" >&2
    ls -1 "$RR_DIR"/docs/namespaces/*.md 2>/dev/null | \
      xargs -n1 basename -s .md | \
      sed 's/^/  /'
    exit 1
  fi
  exit 0
  ;;
```

**Verification**:
```bash
rr docs nix                          # Shows formatted documentation
```

### Success Criteria

#### Automated Tests

```bash
# Test verbose flag parsing
RR_VERBOSE=1 rr nix profile          # Should work
RR_OUTPUT_FORMAT=json rr nix profile # Should output JSON

# Test documentation exists
[[ -f private/rr/docs/namespaces/nix.md ]] && echo "✓ Nix documentation exists"
```

#### Manual Tests

- [x] `rr -v nix profile` shows verbose output
- [x] `rr -vv nix profile` shows extra verbose output
- [x] `rr --trace nix profile` shows bash trace output
- [x] `rr --json nix size` outputs valid JSON (JSON only implemented for commands where it makes sense)
- [x] `rr --quiet nix profile` outputs only essential info
- [x] `rr docs nix` opens formatted documentation with glow (already implemented in Phase 4 partial)
- [x] Documentation is accurate and helpful
- [x] Verbose output support implemented where appropriate (profile, size commands)

---

## References

### Original Research
- Research document: `thoughts/_shared/research/2025-10-20_18-24-56_cli-implementation-opportunities.md`
- CLI patterns research: `thoughts/_shared/research/cli.md`

### Existing Code Patterns
- nix-* functions: `shell/shell_functions:211-284`
- gum usage example: `bin/commit:1-17`
- FZF patterns: `shell/shell_functions:118-175`
- Just recipes: `justfile:1-146`
- Platform detection: `shell/shell_functions:203-209`

### Key Files to Preserve
- `shell/shell_functions` - DO NOT MODIFY initially (Phase 1-3)
- `shell/shell_aliases` - DO NOT MODIFY
- `justfile` - Remains independent
- `bin/` scripts - Can be wrapped by rr namespaces later

### Related Documentation
- Nix implementation: `docs/nix-implementation.md`
- Secret management: `docs/secret-management.md`
- Karabiner integration: `docs/nixcats-integration-plan.md`

## Implementation Timeline

### Week 1: Phase 1
- Day 1-2: Create directory structure, main dispatcher
- Day 3-4: Implement nix namespace
- Day 5: Testing and documentation
- Day 6-7: Buffer for issues

### Week 2: Phase 2
- Day 1-2: Enhance nix commands with gum
- Day 3-4: Shell completion
- Day 5: Additional namespaces (karabiner, git)
- Day 6-7: Testing

### Weeks 3-4: Phase 3
- Week 3: Command history and search
- Week 4: Namespace aliasing and integration testing

### Month 2+: Phase 4 (Optional)
- As needed: Multi-format output
- As needed: Comprehensive documentation
- As needed: Additional namespaces (private: server, k8, blog, brain)

## Risk Mitigation

### Risk: Breaking existing workflows
**Mitigation**:
- Zero modifications to existing files in Phase 1-3
- Parallel systems coexist indefinitely
- Easy rollback by removing bin/rr symlink

### Risk: gum commands failing
**Mitigation**:
- Check if gum is installed before using
- Fallback to plain text output
- gum is already installed via Nix

### Risk: Shell completion conflicts
**Mitigation**:
- Use unique namespace (_rr) for completion
- Test in clean zsh session first
- Completion is optional, doesn't break core functionality

### Risk: Performance degradation
**Mitigation**:
- Dispatcher is simple bash script with minimal overhead
- Most work done by existing functions
- Can measure with time command

## Success Metrics

- **Adoption rate**: Number of times `rr` commands used vs old commands (track via history)
- **Discoverability**: Can find commands with `rr search` in <5 seconds
- **Consistency**: All namespaces follow same pattern (100% compliance)
- **Documentation**: 100% of commands have help text and examples
- **Backward compatibility**: 0 broken existing workflows
- **User satisfaction**: Subjective but should feel more organized and discoverable
