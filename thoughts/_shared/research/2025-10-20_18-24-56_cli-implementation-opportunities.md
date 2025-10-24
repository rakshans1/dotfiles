---
date: 2025-10-20T18:24:56+05:30
researcher: rakshans1
git_commit: d8a4b4cd50c4e5d9f0c4b43444f4740c5b3a9749
branch: main
repository: dotfiles
topic: "CLI Implementation Opportunities Based on Research Document"
tags: [research, codebase, cli, shell, automation, namespace, fzf, gum, just]
status: complete
last_updated: 2025-10-20
last_updated_by: Claude Code
---

# Research: CLI Implementation Opportunities in Dotfiles

## Research Question

Based on the CLI tool development research document (`thoughts/_shared/research/cli.md`), what CLI patterns and features can be implemented in this dotfiles repository to improve command-line workflows?

## Summary

This dotfiles repository already implements several advanced CLI patterns including:
- **Strong foundation**: FZF integration (6+ patterns), namespace prefixing (nix-*, git-*, k8-*), Just task runner with 146-line justfile
- **Installed but underutilized**: gum (TUI toolkit) installed but minimal usage, glow for markdown rendering
- **Modern tooling**: Nix-based declarative configuration, SOPS secrets, platform detection

**Key opportunities identified**:
1. **Unified CLI dispatcher** - Create `rr` (or similar) main script to unify scattered commands under namespaced structure
2. **Enhanced command history** - Custom history tracking with fzf integration beyond default zsh history
3. **Namespace aliasing system** - Formalize aliases for namespaces (e.g., `rr b` → `rr brain`)
4. **Interactive workflows with gum** - Leverage installed gum for confirmations, prompts, and styled output
5. **Multi-format output** - Add JSON/table/quiet modes for scriptability
6. **LLM-friendly documentation** - Structured command documentation with examples
7. **Advanced help system** - Multi-level help (`rr help`, `rr blog --help`, `rr docs blog`)

## Detailed Findings

### 1. Existing CLI Infrastructure

#### 1.1 Namespace Pattern Already in Use

**nix-* namespace** (`shell/shell_functions:211-284`)
```bash
nix-profile()  # Auto-detect platform profile
nix-build()    # Build Home Manager configuration
nix-activate() # Activate built configuration
nix-switch()   # Complete rebuild and switch
nix-update()   # Update flake inputs
nix-clean()    # Garbage collection
nix-size()     # Check Nix store size
```

**git-* namespace** (`shell/shell_functions:143-148`)
```bash
git-branch()   # Fuzzy branch search with commit preview (used by gco())
```

**k8-* namespace** (`private/private_functions:6-15`)
```bash
k8-exec()      # Execute bash in pod
k8-logs()      # Tail pod logs
```

**server-* namespace** (`private/private_functions:17-27`)
```bash
server-start()
server-stop()
server-reload()
```

**Key insight**: The namespace pattern exists but is **informal** - no central dispatcher, inconsistent implementation, scattered across multiple files.

#### 1.2 FZF Integration (Heavily Used)

**Tmux Session Switcher** (`shell/shell_functions:118`)
- Lists all sessions with fuzzy search
- Creates new session on no selection
- Seamless attach/switch behavior

**File Preview Function** (`shell/shell_functions:127-135`)
- Uses bat for syntax-highlighted previews
- Fallback chain for highlighting
- Binary file detection

**Git Branch Selector** (`shell/shell_functions:143-148`)
- Sorted by commit date
- Preview shows commit history
- Works with remote branches

**Man Page Search** (`shell/shell_functions:169-175`)
- Interactive man page discovery
- Custom prompt styling
- Fallback to standard man with args

**Package Installation** (`bin/add:17-22`)
- Multi-select mode
- Preview shows package details
- Colored output
- Pipes to install command

**Key insight**: FZF is **deeply integrated** and proven successful - can be model for other interactive workflows.

#### 1.3 Just Task Runner

**Main Justfile** (`justfile:1-146`)
- 25+ recipes for dotfiles management
- Compound recipes (check-format, fix-format)
- Multi-line bash scripts with heredocs
- Emoji for visual feedback
- Tool availability checks
- Graceful degradation

**Pattern: Check/Fix Workflows**
```bash
check-format: shell-check-format nix-check-format

fix-format:
    @echo "📝 Fixing all formatting..."
    @just shell-fix-format
    @just nix-fix-format
    @echo "✅ All formatting fixed!"
```

**Pattern: File Discovery**
```bash
shell-ls:
  find . \( -name '*.sh' -o -path './bin/*' \) -type f -not -type l -print
```

**Key insight**: Just provides excellent **self-documenting** command organization and will remain independent of the `rr` dispatcher.

#### 1.4 Interactive TUI Tools Installed

**Installed via Nix** (`nixpkgs/home-manager/modules/common.nix:77-79`):
```nix
glow  # Markdown renderer - USED in cat() function
gum   # TUI toolkit - INSTALLED but minimal usage
vhs   # Terminal recording
```

**gum usage**: Only found in `bin/commit:1-17` for interactive git commits:
```bash
TYPE=$(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")
SCOPE=$(gum input --placeholder "scope")
SUMMARY=$(gum input --value "$TYPE$SCOPE: " --placeholder "Summary of this change")
DESCRIPTION=$(gum write --placeholder "Details of this change (CTRL+D to finish)")
gum confirm "Commit changes?" && git commit -m "$SUMMARY" -m "$DESCRIPTION"
```

**Key insight**: gum is **installed but underutilized** - massive opportunity for enhancing interactive workflows.

#### 1.5 Current Command Organization

**14 custom bin scripts** (`bin/`):
- Browser/link management: `open-arc-space`, `open-link`, `open-link-arc`, `open-path`
- Git helpers: `commit`, `add`
- System utilities: `bluetooth-connect`, `ssh-key`, `colordump`, `gif`, `hello`
- Nix: `setup-nix`

**30+ shell functions** (`shell/shell_functions`):
- Development workflow: `dotfiles()`, `t()`, `mkd()`
- File operations: `extract()`, `list()`, `p()`
- Git utilities: `gco()` (uses `git-branch()` helper)
- Nix management: `nix-*` functions (7 functions)
- Enhanced wrappers: `cat()`, `man()`, `copy()`

**25+ shell aliases** (`shell/shell_aliases`):
- Editor shortcuts: `nvim=rvim`, `v=rvim`, `vim=nvim`
- System utilities: `ls=exa`, `top=btm`, `x+=chmod +x`
- Workflow: `r=just`, `:q=exit`, `:c=clear`
- AI tools: `yolo-claude`, `yolo-codex`

**Key insight**: Commands are **scattered** across bin/, functions, aliases, and justfile - unified access would improve discoverability.

### 2. Gaps and Opportunities

#### 2.1 No Unified CLI Dispatcher

**Gap**: No central entry point like the proposed `rr` script in research document.

**Current state**:
- Commands invoked directly: `nix-switch`, `just check-format`, `gco`, etc.
- No consistent structure: some prefixed, some aliased, some in justfile
- Discoverability requires knowing exact command names
- No auto-completion across all custom commands

**Opportunity**: Create unified dispatcher that:
```bash
# Unified access pattern
rr nix switch          # Instead of: nix-switch
rr blog deploy         # Instead of: cd private/raycast/scripts && ./blog.sh deploy

# With aliasing
rr n switch           # rr nix switch
rr b deploy           # rr blog deploy
```

**Implementation location**: Create `private/rr/` directory structure with:
- `private/rr/bin/rr` - Main dispatcher script (symlinked to `~/dotfiles/bin/rr`)
- `private/rr/namespaces/` - Namespace scripts
- `private/rr/completions/` - Shell completion files
- `private/rr/docs/` - Documentation files
- Namespace aliasing config file

#### 2.2 Basic Command History (No Custom Tracking)

**Current state**: Standard zsh history via oh-my-zsh

**Gap**: No custom command history tracking with:
- Timestamp and duration tracking
- Exit code recording
- Metadata for analysis
- FZF integration for `rr history`
- `rr last` to re-run last command

**Opportunity**: Implement custom history system:
```bash
# History file format
# 2025-10-20T10:30:45Z|rr nix switch|0|45.3s
# 2025-10-20T10:35:12Z|rr blog deploy|0|12.1s

# Usage
rr history     # FZF browse with metadata
rr last        # Re-run last command
```

**Implementation**: Hook into zsh `preexec` and `precmd` hooks to capture command execution.

#### 2.3 No Namespace Aliasing System

**Current state**:
- Some single-letter aliases exist (`r=just`, `v=rvim`, `c=cursor`)
- But no systematic namespace aliasing
- Private Raycast scripts exist for `blog`, `brain`, `blob` but not integrated

**Gap**: No formalized alias system like:
```bash
rr b search    # rr brain search
rr bl deploy   # rr blog deploy
rr s start     # rr server start
```

**Opportunity**: Implement alias config file:
```bash
# ~/.config/rr/aliases.conf
b=brain
bl=blog
n=nix
g=git
k=k8
s=server
```

**Implementation**: Main `rr` script resolves aliases before loading namespaces.

#### 2.4 Minimal gum Usage

**Current state**:
- gum installed (`common.nix:78`)
- Only used in `bin/commit` for git commits
- Research document shows 10+ gum usage patterns

**Gap**: Missing interactive experiences like:
- Confirmation dialogs for destructive operations
- Styled output for important messages
- Interactive forms for complex inputs
- Table output for status commands
- Progress spinners for long operations

**Opportunity**: Enhance commands with gum:

**Example 1: Nix rebuild with confirmation**
```bash
function nix-switch() {
  gum style --border double --padding "1 2" \
    "Nix Home Manager Rebuild" \
    "" \
    "Profile: $(nix-profile)" \
    "This will update flakes and rebuild configuration"

  if ! gum confirm "Proceed with rebuild?"; then
    echo "Cancelled"
    return 0
  fi

  gum spin --spinner dot --title "Updating private flake..." -- \
    nix flake update private

  # ... rest of implementation
}
```

**Example 2: Server status with tables**
```bash
rr server status --format table

# Output using gum table
gum table --columns "Service,Status,Port,Uptime" \
  --data "Blog,Running,3000,2h 15m" \
  --data "API,Stopped,-,-" \
  --data "Cache,Running,6379,5h 23m"
```

**Example 3: File selection with styling**
```bash
# Instead of plain fzf, add gum styling
files=$(gum filter --placeholder "Select files..." < <(fd --type f))
```

#### 2.5 No Multi-Format Output

**Current state**: Commands output plain text only

**Gap**: No support for:
- JSON output for scripting (`--json`)
- Quiet mode for cron jobs (`--quiet`)
- Table format for readability (`--format table`)
- Verbose/debug modes (`-v`, `-vv`, `--trace`)

**Opportunity**: Add output format support:

```bash
# JSON output for scripting
rr nix status --json
{
  "profile": "mbp",
  "generation": 142,
  "last_updated": "2025-10-20T10:30:45Z",
  "packages": 247
}

# Table output for humans
rr nix status --format table
Profile     Generation  Last Updated         Packages
mbp         142         2025-10-20 10:30     247

# Quiet mode (only errors)
rr nix switch --quiet

# Verbose mode
rr -v nix switch
[DEBUG] Resolved namespace: nix
[DEBUG] Command: switch
[DEBUG] Updating private flake...
[DEBUG] Executing: nix flake update private
...

# Trace mode (full bash execution trace)
rr --trace nix switch
+ nix-profile
+ is_mac
+ [[ Darwin == Darwin ]]
...
```

**Implementation**: Environment variables `RR_OUTPUT_FORMAT`, `RR_VERBOSE`, `RR_TRACE` passed to namespace scripts.

#### 2.6 Scattered Documentation

**Current state**:
- Comments in shell functions
- Justfile recipes have descriptions
- No structured help system
- No LLM-friendly documentation format

**Gap**: Missing multi-level help:
```bash
rr help                    # List all namespaces
rr nix --help              # Show nix namespace commands with examples
rr docs nix                # Full documentation with glow
rr examples                # Common workflow examples
rr search "rebuild"        # Search commands by keyword
rr which switch            # Find which namespace contains 'switch'
```

**Opportunity**: Create structured documentation system:

**File structure**:
```
docs/
├── README.md              # Overview
├── namespaces/
│   ├── nix.md            # Detailed nix namespace docs
│   ├── blog.md           # Blog namespace docs
│   ├── brain.md          # Brain namespace docs
│   └── [others].md       # Other namespace docs
├── examples/
│   ├── getting-started.md
│   ├── common-workflows.md
│   └── troubleshooting.md
└── api/
    └── generated.md       # Auto-generated from code
```

**LLM-friendly format** (per research document):
```markdown
## Command: rr nix switch

### Purpose
Rebuild and activate Home Manager configuration with flake updates

### Syntax
rr nix switch [OPTIONS]

### Parameters
- `-v, --verbose`: Show detailed output
- `--dry-run`: Show what would be done without executing

### Prerequisites
- Nix installed with flakes enabled
- Home Manager configured
- Git working directory clean (recommended)

### Examples

#### Basic Usage
```bash
rr nix switch
```
Expected output:
```
Updating private flake...
Updating neovim flake...
Switching home-manager configuration...
✅ Configuration activated
```

#### With Verbose Output
```bash
rr -v nix switch
```

### Exit Codes
- 0: Success
- 1: Build failed
- 2: Activation failed

### Related Commands
- rr nix build - Build without activating
- rr nix clean - Clean Nix store
- rr nix update - Update flake inputs only
```

#### 2.7 No Smart Search System

**Gap**: Can't search across all commands by keyword or description

**Opportunity**: Implement search that indexes:
- Command names (function names in namespace files)
- Help text and descriptions
- Justfile recipes
- Aliases
- Comments and documentation

```bash
# Search for "rebuild" across all namespaces
rr search rebuild

# Output with FZF preview
nix:switch      - Rebuild and activate Home Manager
nix:build       - Build without activating
blog:deploy     - Deploy blog to production
```

**Implementation**: Grep through namespace files and help text, pipe to fzf with preview showing command details.

### 3. Existing Patterns to Preserve

#### 3.1 Platform Detection Pattern

**Current implementation** (`shell/shell_functions:203-222`):
```bash
function is_mac() {
  [[ $(uname -s) == 'Darwin' ]]
}

function is_linux() {
  [[ $(uname -s) == 'Linux' ]]
}

function nix-profile() {
  local profile
  if is_mac && [[ $(uname -m) == 'arm64' ]]; then
    profile="mbp"
  elif is_mac; then
    profile="mbpi"
  elif is_linux; then
    profile="linux"
  fi
  echo $profile
}
```

**Why preserve**: Proven pattern for cross-platform compatibility, used throughout the codebase.

**Integration with new dispatcher**: Export as environment variable for namespace scripts:
```bash
export RR_PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
export RR_ARCH=$(uname -m)
export RR_NIX_PROFILE=$(nix-profile)
```

#### 3.2 FZF Integration Pattern

**Current implementation** - Multiple successful patterns:
1. **Tmux session switching** - List + preview + action
2. **Git branch selection** - Sorted by relevance + commit history preview
3. **Man page search** - Search all + interactive selection
4. **Package installation** - Multi-select + preview + batch action

**Why preserve**: FZF integration is **battle-tested** and users are familiar with it.

**Integration with new dispatcher**: Make FZF the default for interactive selections:
```bash
# Built-in FZF helper for namespace scripts
rr_fzf() {
  fzf --layout=reverse \
      --border \
      --preview-window=right:60% \
      "$@"
}

# Export for namespace scripts
export -f rr_fzf
```

#### 3.3 Just Recipe Pattern

**Current implementation** - Well-organized task runner with:
- Compound recipes that call other recipes
- File discovery patterns
- Check/fix workflow duality
- Tool availability checks
- Visual feedback with emojis

**Why preserve**: Just is perfect for **project-level automation** with clear documentation.

**Integration with new dispatcher**: Keep justfile independent - no need to wrap it in `rr` dispatcher. Just recipes are already well-organized and self-documenting with the `r` alias for quick access.

#### 3.4 Nix-Based Package Management

**Current implementation**: All CLI tools installed via Nix/Home Manager for reproducibility.

**Why preserve**:
- Declarative configuration
- Cross-platform consistency
- Version pinning via flake.lock
- Atomic updates and rollbacks

**Integration with new dispatcher**: The `rr` script itself does NOT need to be installed via Nix. It will be automatically available through the `bin/` directory which is already in PATH. The symlink `bin/rr -> ../private/rr/bin/rr` ensures the script is executable and accessible from anywhere.

### 4. Implementation Recommendations

#### Priority 1: Core Infrastructure (Week 1)

**1.1 Create Main Dispatcher** (`private/rr/bin/rr`)
```bash
#!/usr/bin/env bash
# Main rr dispatcher

RR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$(cd "$RR_DIR/../.." && pwd)"
NAMESPACE="${1}"
shift

# Source helper functions from main dotfiles
source "$DOTFILES_DIR/shell/shell_functions"

# Handle special commands
case "$NAMESPACE" in
  help|--help|-h)
    echo "Usage: rr <namespace> <command> [args]"
    echo ""
    echo "Available namespaces:"
    for ns in "$RR_DIR"/namespaces/*.sh; do
      basename "$ns" .sh
    done
    exit 0
    ;;
  *)
    # Load namespace
    NAMESPACE_FILE="$RR_DIR/namespaces/$NAMESPACE.sh"
    if [[ ! -f "$NAMESPACE_FILE" ]]; then
      echo "Error: Unknown namespace '$NAMESPACE'" >&2
      exit 1
    fi
    source "$NAMESPACE_FILE"
    ;;
esac
```

**Symlink to bin**: Create symlink `bin/rr -> ../private/rr/bin/rr` for PATH access

**1.2 Migrate Existing Namespaces**

Create `private/rr/namespaces/nix.sh` from current `nix-*` functions:
```bash
#!/usr/bin/env bash
# namespaces/nix.sh

CMD="${1}"
shift

case "$CMD" in
  profile) nix-profile "$@" ;;
  build) nix-build "$@" ;;
  switch) nix-switch "$@" ;;
  update) nix-update "$@" ;;
  clean) nix-clean "$@" ;;
  size) nix-size "$@" ;;
  --help|help|"")
    cat << 'EOF'
Usage: rr nix <command> [options]

Commands:
  profile    Show current Nix profile (mbp/linux)
  build      Build Home Manager configuration
  switch     Build and activate configuration
  update     Update flake inputs
  clean      Run garbage collection
  size       Show Nix store size

Examples:
  rr nix switch
  rr nix update
  rr -v nix switch    # Verbose output

For detailed docs: rr docs nix
EOF
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr nix --help' for usage"
    exit 1
    ;;
esac
```

**1.3 Shell Completion**

Create `private/rr/completions/rr.zsh`:
```bash
#compdef rr

_rr() {
  local -a namespaces commands
  namespaces=(${(f)"$(ls ~/dotfiles/private/rr/namespaces/*.sh | xargs -n1 basename -s .sh)"})

  if (( CURRENT == 2 )); then
    # Complete namespace
    _describe 'namespace' namespaces
  elif (( CURRENT == 3 )); then
    # Complete command for namespace
    local namespace=$words[2]
    commands=(${(f)"$(grep '^[a-z_]*()' ~/dotfiles/private/rr/namespaces/$namespace.sh | sed 's/() {.*//')"})
    _describe 'command' commands
  fi
}

_rr
```

Add to `zsh.nix:214-220`:
```nix
initExtra = ''
  # ... existing init

  # rr completion
  fpath=(~/dotfiles/private/rr/completions $fpath)
  autoload -Uz compinit && compinit
'';
```

#### Priority 2: Enhanced UX (Week 2)

**2.1 Add gum to Interactive Workflows**

Enhance `nix-switch` with gum:
```bash
function nix-switch() {
  # Show summary
  gum style --border double --padding "1 2" --margin "1" \
    --border-foreground 212 \
    "🔨 Nix Home Manager Rebuild" \
    "" \
    "Profile: $(gum style --foreground 212 "$(nix-profile)")" \
    "This will update flakes and rebuild your configuration"

  # Confirm
  gum confirm "Proceed with rebuild?" || return 0

  # Execute with spinners
  gum spin --spinner dot --title "Updating private flake..." -- \
    nix flake update private

  gum spin --spinner dot --title "Updating neovim flake..." -- \
    nix flake update neovim

  gum spin --spinner dot --title "Building configuration..." -- \
    home-manager switch --flake ".#$(nix-profile)"

  # Success message
  gum style --foreground 212 "✓ Configuration activated successfully!"
}
```

**2.2 Implement Output Formats**

Add to main `rr` dispatcher:
```bash
# Parse global flags
VERBOSE=""
OUTPUT_FORMAT="default"

while [[ $# -gt 0 ]]; do
  case $1 in
    -v) VERBOSE="1"; shift ;;
    -vv) VERBOSE="2"; shift ;;
    --json) OUTPUT_FORMAT="json"; shift ;;
    --quiet) OUTPUT_FORMAT="quiet"; shift ;;
    *) break ;;
  esac
done

# Export for namespace scripts
export RR_VERBOSE="$VERBOSE"
export RR_OUTPUT_FORMAT="$OUTPUT_FORMAT"
```

Namespace scripts can then use:
```bash
debug() {
  [[ "$RR_VERBOSE" -ge 1 ]] && echo "[DEBUG] $*" >&2
}

output_json() {
  [[ "$RR_OUTPUT_FORMAT" == "json" ]] && echo "$1"
}

# Usage
debug "Starting nix-switch"
output_json '{"status":"success","generation":142}'
```

**2.3 Add Command History Tracking**

Create history file: `~/.config/rr/history`

Add to `rr` dispatcher (at end):
```bash
# Record command
HISTORY_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/rr/history"
mkdir -p "$(dirname "$HISTORY_FILE")"
echo "$(date -Iseconds)|rr $ORIGINAL_NAMESPACE $*|$EXIT_CODE|${DURATION}s" >> "$HISTORY_FILE"
```

Add `rr history` command:
```bash
case "$NAMESPACE" in
  history)
    cat "$HISTORY_FILE" | \
      fzf --tac --no-sort \
          --preview 'echo {}' \
          --preview-window down:3 \
          --bind 'enter:execute(eval {2})'
    exit 0
    ;;
  last)
    last_cmd=$(tail -1 "$HISTORY_FILE" | cut -d'|' -f2)
    eval "$last_cmd"
    exit $?
    ;;
esac
```

#### Priority 3: Documentation System (Week 3)

**3.1 Create Documentation Structure**

```bash
mkdir -p docs/{namespaces,examples,api}
```

**3.2 Generate Documentation**

Create `rr generate-docs`:
```bash
case "$NAMESPACE" in
  generate-docs)
    echo "# CLI Documentation" > "$RR_DIR/docs/api/generated.md"
    echo "" >> "$RR_DIR/docs/api/generated.md"

    for ns in "$RR_DIR"/namespaces/*.sh; do
      namespace=$(basename "$ns" .sh)
      echo "## Namespace: $namespace" >> "$RR_DIR/docs/api/generated.md"
      grep '^[a-z_]*()' "$ns" | sed 's/() {.*//' >> "$RR_DIR/docs/api/generated.md"
      echo "" >> "$RR_DIR/docs/api/generated.md"
    done

    gum style --foreground 212 "✓ Documentation generated at private/rr/docs/api/generated.md"
    exit 0
    ;;
  docs)
    doc_file="$RR_DIR/docs/namespaces/$1.md"
    if [[ -f "$doc_file" ]]; then
      glow "$doc_file"
    else
      echo "No documentation found for: $1" >&2
      exit 1
    fi
    exit 0
    ;;
esac
```

**3.3 Write First Documentation**

Create `private/rr/docs/namespaces/nix.md` using LLM-friendly template from research document.

#### Priority 4: Advanced Features (Week 4)

**4.1 Namespace Aliasing**

Create `~/.config/rr/aliases.conf`:
```
n=nix
g=git
b=blog
br=brain
s=server
k=k8
```

Add to `rr` dispatcher:
```bash
# Load aliases
ALIAS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/rr/aliases.conf"
if [[ -f "$ALIAS_FILE" ]]; then
  while IFS='=' read -r alias namespace; do
    [[ "$NAMESPACE" == "$alias" ]] && NAMESPACE="$namespace" && break
  done < "$ALIAS_FILE"
fi
```

**4.2 Smart Search**

```bash
case "$NAMESPACE" in
  search)
    keyword="$1"
    {
      # Search namespace files
      for ns in "$RR_DIR"/namespaces/*.sh; do
        namespace=$(basename "$ns" .sh)
        grep -n "^[a-z_]*() {" "$ns" | \
          awk -F: -v ns="$namespace" '{print ns":"$1":"$2}'
      done

      # Search bin scripts
      for bin in "$DOTFILES_DIR"/bin/*; do
        [[ -f "$bin" && -x "$bin" ]] && \
          echo "bin::$(basename "$bin")"
      done
    } | \
    grep -i "$keyword" | \
    fzf --preview 'rr which {1}' \
        --delimiter ':' \
        --preview-window right:60%
    exit 0
    ;;
esac
```

### 5. Migration Path

**Goal**: Gradually deprecate `shell/shell_functions` by migrating appropriate functions into `rr` namespaces. The long-term vision is to have a clean, organized command structure under `rr` while keeping only truly shell-specific utilities (like `extract()`, `mkd()`, etc.) in `shell_functions`.

**⚠️ CRITICAL PRINCIPLE: 100% Backward Compatibility**

**We will NOT touch or modify existing files during migration.** This is the most important rule:

1. **Never modify `shell/shell_functions` during migration** - Keep all existing functions working exactly as they are
2. **Never modify `shell/shell_aliases`** - All aliases continue to work
3. **Never modify `private/private_functions`** - Private functions remain untouched
4. **Add new, don't change existing** - Create `rr` namespaces as new functionality alongside existing commands
5. **Delete only when proven** - Only remove old functions after `rr` replacement is tested and stable

**Migration Philosophy**:
- **Additive approach**: Build `rr` namespaces as a parallel system
- **Gradual adoption**: Users (including yourself) naturally switch to `rr` over time
- **No forced migration**: Old commands work indefinitely until YOU decide to remove them
- **Safety first**: If something breaks, old commands are still there as fallback

**How This Works in Practice**:

```bash
# Week 1: Add rr namespace - OLD STILL WORKS
# shell/shell_functions - UNCHANGED, nix-switch() still exists
# private/rr/namespaces/nix.sh - NEW FILE with rr nix switch

# Both work:
nix-switch              # Old way - still works perfectly
rr nix switch           # New way - now available

# Week 4: After proving rr works - STILL NO CHANGES TO OLD FILES
# shell/shell_functions - STILL UNCHANGED
# You just use rr nix switch in your daily work

# Month 2: When you're confident - FIRST TIME WE TOUCH OLD FILE
# shell/shell_functions - Add deprecation notice to nix-switch()
function nix-switch() {
  echo "⚠️ Note: Consider using 'rr nix switch' instead" >&2
  rr nix switch "$@"
}

# Month 3+: When ready to clean up - DELETE OLD CODE
# shell/shell_functions - Remove nix-switch() entirely
# Only after YOU are 100% comfortable with rr nix switch
```

**Migration Strategy**:
- **Migrate to `rr`**: Functions that represent discrete commands/operations (nix-*, server-*, k8-*, etc.)
- **Keep in shell_functions**: General-purpose shell utilities used by other scripts (is_mac(), extract(), copy(), etc.)
- **Keep as aliases**: Simple one-liner shortcuts (ls=exa, top=btm, etc.)

#### Phase 1: Parallel Systems (Weeks 1-2) - **NO MODIFICATIONS TO EXISTING FILES**
- **DO NOT TOUCH**: `shell/shell_functions` remains completely unchanged
- **DO NOT TOUCH**: `shell/shell_aliases` remains completely unchanged
- **DO NOT TOUCH**: `private/private_functions` remains completely unchanged
- **CREATE NEW**: `private/rr/` directory structure with namespaces
- **RESULT**: Both systems work side-by-side
  - `nix-switch` continues to work (from shell_functions)
  - `rr nix switch` now also works (from rr namespace)
- Users can try `rr` commands without any risk
- Zero breaking changes, 100% backward compatible

**Example migration targets (Week 1-2)**:
```bash
# Migrate these to rr namespaces:
nix-profile()    → rr nix profile
nix-build()      → rr nix build
nix-switch()     → rr nix switch
nix-update()     → rr nix update
nix-clean()      → rr nix clean
nix-size()       → rr nix size
karabiner-build() → rr karabiner build (or rr kb build)

# Keep these as shell utilities:
is_mac()         - Platform detection helper
is_linux()       - Platform detection helper
extract()        - Archive extraction utility
mkd()            - Make and enter directory
copy()           - Cross-platform clipboard
cat()            - Smart cat wrapper (glow/bat)
man()            - FZF man page search
p()              - FZF file preview
t()              - Tmux session manager
dotfiles()       - Tmux dotfiles session
```

#### Phase 2: Soft Deprecation (Weeks 3-4) - **FIRST TIME WE MODIFY EXISTING FILES**
- **OPTIONAL STEP**: Only do this when YOU are comfortable with `rr` commands
- **MINIMAL MODIFICATION**: Add deprecation notices to functions in `shell/shell_functions`
- **STILL BACKWARD COMPATIBLE**: Old commands still work, just show a notice
```bash
# BEFORE (Week 1-2): Original function in shell/shell_functions
function nix-switch() {
  (
    set -e
    # ... original implementation
  )
}

# AFTER (Week 3-4): Modified to call rr with notice
function nix-switch() {
  echo "⚠️  Note: Consider using 'rr nix switch' instead" >&2
  rr nix switch "$@"
}
```
- Update muscle memory gradually
- Both approaches still work perfectly

**Example migration targets (Week 3-4)**:
```bash
# Migrate work/private-specific functions:
server-start()   → rr server start
server-stop()    → rr server stop
server-reload()  → rr server reload
k8-exec()        → rr k8 exec
k8-logs()        → rr k8 logs

# Migrate development helpers:
gco()            → Keep as-is (git wrapper, widely used)
git-branch()     → Keep as helper for gco()
```

#### Phase 3: Full Migration (Month 2+) - **MODIFY WITH STRONGER DEPRECATION**
- **PREREQUISITE**: You must be using `rr` commands exclusively in your daily workflow
- **MODIFICATION**: All logic already in namespace files, strengthen deprecation notices
- **STILL BACKWARD COMPATIBLE**: Old commands still work (call rr under the hood)
```bash
# shell/shell_functions - Modified functions
function nix-switch() {
  echo "⚠️  DEPRECATED: This command is deprecated. Use: rr nix switch" >&2
  echo "⚠️  The old function will be removed in the future." >&2
  rr nix switch "$@"
}

function karabiner-build() {
  echo "⚠️  DEPRECATED: This command is deprecated. Use: rr kb build" >&2
  echo "⚠️  The old function will be removed in the future." >&2
  rr kb build "$@"
}
```
- Add TODO comments for eventual removal:
```bash
# TODO: Remove nix-switch() after Month 3 - replaced by rr nix switch
# TODO: Remove karabiner-build() after Month 3 - replaced by rr kb build
```
- Document migration in shell_functions header
- Old commands still work, just with stronger warnings

#### Phase 4: Cleanup (Month 3+) - **DELETE DEPRECATED FUNCTIONS**
- **PREREQUISITE**: You haven't used old commands in weeks/months
- **ACTION**: Finally remove deprecated function wrappers from `shell_functions`
- **SAFE TO DELETE**: Because you've been using `rr` exclusively
- Keep only general-purpose utilities in `shell_functions`:
  - Platform detection: `is_mac()`, `is_linux()`
  - File operations: `extract()`, `mkd()`, `list()`
  - Shell wrappers: `cat()`, `man()`, `copy()`, `p()`
  - Dev environment: `t()`, `dotfiles()`, `gco()`, `git-branch()`
- Update all documentation and examples
- Final `shell_functions` should be ~100-150 lines (currently 285)

**What gets deleted**:
```bash
# DELETE from shell/shell_functions:
nix-profile()
nix-build()
nix-switch()
nix-update()
nix-clean()
nix-size()
karabiner-build()

# DELETE from private/private_functions:
server-start()
server-stop()
server-reload()
k8-exec()
k8-logs()
```

**What remains**:
```bash
# KEEP in shell/shell_functions:
is_mac()
is_linux()
extract()
mkd()
list()
cat()
man()
copy()
p()
t()
dotfiles()
gco()
git-branch()
```

**Migration Decision Matrix**:

| Function Type | Keep in shell_functions | Migrate to rr |
|---------------|-------------------------|---------------|
| Platform detection (is_mac, is_linux) | ✅ Yes | ❌ No |
| File utilities (extract, mkd, list) | ✅ Yes | ❌ No |
| Shell wrappers (cat, man, copy) | ✅ Yes | ❌ No |
| Development helpers (t, dotfiles, p) | ✅ Yes | ❌ No |
| Git wrappers (gco, git-branch) | ✅ Yes | ❌ No |
| Nix commands (nix-*) | ❌ No | ✅ Yes |
| Service control (server-*) | ❌ No | ✅ Yes |
| Infrastructure (k8-*) | ❌ No | ✅ Yes |
| Project-specific (karabiner-build) | ❌ No | ✅ Yes |
| Work-specific (in private_functions) | ❌ No | ✅ Yes |

**Benefits of Migration**:
1. **Better discoverability**: `rr help` shows all available commands
2. **Consistent interface**: All commands follow same pattern
3. **Auto-completion**: Shell completion works across all namespaces
4. **Documentation**: Each namespace has help and docs
5. **Organization**: Related commands grouped together
6. **Searchability**: `rr search <keyword>` finds commands
7. **History tracking**: Custom history for rr commands
8. **Cleaner shell_functions**: Only essential utilities remain

### 6. Directory Structure Proposal

```
~/dotfiles/
├── bin/
│   ├── rr -> ../private/rr/bin/rr  # Symlink to private rr (NEW)
│   └── [existing bins]              # Keep existing
├── private/                         # Private submodule
│   ├── rr/                          # NEW rr implementation
│   │   ├── CONTRIBUTORS.md          # LLM-friendly directory documentation
│   │   ├── AGENTS.md -> CONTRIBUTORS.md    # Symlink for AI agents
│   │   ├── CLAUDE.md -> CONTRIBUTORS.md    # Symlink for Claude
│   │   ├── bin/
│   │   │   ├── CONTRIBUTORS.md      # bin/ specific documentation
│   │   │   ├── AGENTS.md -> CONTRIBUTORS.md
│   │   │   ├── CLAUDE.md -> CONTRIBUTORS.md
│   │   │   └── rr                   # Main dispatcher script
│   │   ├── namespaces/
│   │   │   ├── CONTRIBUTORS.md      # Namespace implementation guide
│   │   │   ├── AGENTS.md -> CONTRIBUTORS.md
│   │   │   ├── CLAUDE.md -> CONTRIBUTORS.md
│   │   │   ├── nix.sh              # Migrated from nix-* functions
│   │   │   ├── blog.sh             # Wraps private/raycast/scripts/blog.sh
│   │   │   ├── brain.sh            # Wraps private/raycast/scripts/brain.sh
│   │   │   ├── server.sh           # Migrated from private_functions
│   │   │   └── k8.sh               # Migrated from private_functions
│   │   ├── completions/
│   │   │   ├── CONTRIBUTORS.md      # Shell completion guide
│   │   │   ├── AGENTS.md -> CONTRIBUTORS.md
│   │   │   ├── CLAUDE.md -> CONTRIBUTORS.md
│   │   │   ├── rr.bash
│   │   │   ├── rr.zsh
│   │   │   └── rr.fish
│   │   ├── docs/
│   │   │   ├── CONTRIBUTORS.md      # Documentation structure guide
│   │   │   ├── AGENTS.md -> CONTRIBUTORS.md
│   │   │   ├── CLAUDE.md -> CONTRIBUTORS.md
│   │   │   ├── README.md
│   │   │   ├── namespaces/
│   │   │   │   ├── nix.md
│   │   │   │   ├── blog.md
│   │   │   │   ├── brain.md
│   │   │   │   └── [others].md
│   │   │   ├── examples/
│   │   │   │   ├── getting-started.md
│   │   │   │   ├── common-workflows.md
│   │   │   │   └── troubleshooting.md
│   │   │   └── api/
│   │   │       └── generated.md    # Auto-generated
│   │   └── config/
│   │       ├── CONTRIBUTORS.md      # Configuration guide
│   │       ├── AGENTS.md -> CONTRIBUTORS.md
│   │       ├── CLAUDE.md -> CONTRIBUTORS.md
│   │       └── aliases.conf        # Namespace aliases (copied to ~/.config/rr/)
│   ├── raycast/                     # Existing
│   ├── caddy/                       # Existing
│   └── [other private files]        # Existing
├── shell/
│   ├── shell_aliases                # Keep, gradually deprecate
│   └── shell_functions              # Keep, gradually migrate
└── [existing structure]
```

**Key points:**
- All `rr` implementation lives in `private/rr/` (within private submodule)
- Symlink `bin/rr` points to `private/rr/bin/rr` for PATH access
- Keeps private/work-specific namespaces in private submodule
- Configuration file `private/rr/config/aliases.conf` copied to `~/.config/rr/aliases.conf` on setup

**LLM-Friendly Navigation:**
Every directory should contain documentation files to help LLMs (and AI agents) understand the codebase:
- `CONTRIBUTORS.md` - Primary documentation file explaining directory purpose, structure, and usage
- `AGENTS.md` - Symlink to `CONTRIBUTORS.md`
- `CLAUDE.md` - Symlink to `CONTRIBUTORS.md`

This ensures LLMs can quickly understand context at any directory level, regardless of which filename they look for. Each `CONTRIBUTORS.md` should include:
- **Purpose**: What this directory contains and why it exists
- **Structure**: Key files and subdirectories
- **Usage**: How to use/modify code in this directory
- **Conventions**: Naming patterns, coding standards, architectural decisions
- **Examples**: Common operations and workflows

**Example CONTRIBUTORS.md template** (for `private/rr/namespaces/`):
```markdown
# Contributors Guide: rr Namespaces

This directory contains namespace implementations for the `rr` CLI dispatcher.

## Purpose

Namespace scripts organize related commands under a common prefix (e.g., `rr nix switch`, `rr blog deploy`). Each namespace is a self-contained shell script that handles command routing and execution.

## Structure

```
namespaces/
├── CONTRIBUTORS.md          # This file
├── AGENTS.md -> CONTRIBUTORS.md
├── CLAUDE.md -> CONTRIBUTORS.md
├── nix.sh                   # Nix/Home Manager commands
├── blog.sh                  # Blog management commands
├── brain.sh                 # Brain/note management
├── server.sh                # Server control commands
└── k8.sh                    # Kubernetes utilities
```

## Creating a New Namespace

1. Create `<namespace>.sh` in this directory
2. Follow this template:

```bash
#!/usr/bin/env bash
# namespaces/<namespace>.sh - Description

CMD="${1}"
shift

case "$CMD" in
  command1) command1_impl "$@" ;;
  command2) command2_impl "$@" ;;
  --help|help|"")
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
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr <namespace> --help' for usage"
    exit 1
    ;;
esac
```

3. Implement command functions above the case statement
4. Add help text for all commands
5. Test: `rr <namespace> help` should show all commands

## Conventions

- **Naming**: Lowercase with hyphens for multi-word namespaces (e.g., `dev-env.sh`)
- **Functions**: Define helper functions before the case statement
- **Help**: Always provide `--help`, `help`, and empty command handlers
- **Exit codes**: 0 for success, 1 for errors, 2 for usage errors
- **Environment**: Access `$RR_VERBOSE`, `$RR_OUTPUT_FORMAT` from main dispatcher
- **Dependencies**: Source `$DOTFILES_DIR/shell/shell_functions` for shared utilities

## Available Environment Variables

From main `rr` dispatcher:
- `$RR_DIR` - Path to `private/rr/` directory
- `$DOTFILES_DIR` - Path to main dotfiles directory
- `$RR_VERBOSE` - Verbosity level (0, 1, 2)
- `$RR_OUTPUT_FORMAT` - Output format (default, json, quiet, table)
- `$RR_PLATFORM` - Platform (darwin, linux)
- `$RR_ARCH` - Architecture (arm64, x86_64)

## Examples

See existing namespaces:
- `nix.sh` - Complete example with multiple commands
- `blog.sh` - Wrapper around existing Raycast script
- `server.sh` - Service management pattern
```

### 7. Concrete Next Steps

#### Immediate (This Week)
1. ✅ Complete this research document
2. Create directory structure for `private/rr/`
3. Create `CONTRIBUTORS.md` files in each directory with symlinks to `AGENTS.md` and `CLAUDE.md`
4. Create `private/rr/bin/rr` skeleton script
5. Create symlink `bin/rr -> ../private/rr/bin/rr`
6. Migrate `nix-*` functions to `private/rr/namespaces/nix.sh`
7. Test: `rr nix switch` should work identically to `nix-switch`

#### Short Term (Week 2)
1. Add gum to `nix-switch` for better UX
2. Create shell completion for `rr` in `private/rr/completions/rr.zsh`
3. Migrate `blog`, `brain` scripts to `private/rr/namespaces/`
4. Implement `rr help` and `rr <namespace> --help`

#### Medium Term (Weeks 3-4)
1. Create documentation structure in `private/rr/docs/`
2. Write LLM-friendly docs for nix namespace
3. Implement command history tracking
4. Add namespace aliasing system with `private/rr/config/aliases.conf`
5. Migrate server/k8 namespaces from private_functions

#### Long Term (Month 2+)
1. Implement smart search (`rr search`)
2. Add multi-format output (JSON, table, quiet)
3. Create comprehensive examples documentation
4. Build auto-documentation generation
5. Enhance with additional namespaces as needed

## Code References

### Existing Patterns
- `shell/shell_functions:211-284` - nix-* namespace pattern
- `shell/shell_functions:143-148` - git-branch with fzf
- `shell/shell_functions:169-175` - man with fzf search
- `shell/shell_functions:118` - tmux session switcher with fzf
- `bin/add:17-22` - package installation with fzf multi-select
- `bin/commit:1-17` - gum interactive git commits
- `justfile:1-146` - task runner with 25+ recipes
- `nixpkgs/home-manager/modules/common.nix:77-79` - CLI tools installation

### Tool Installations
- `nixpkgs/home-manager/modules/common.nix:78` - gum installed
- `nixpkgs/home-manager/modules/common.nix:77` - glow installed
- `nixpkgs/home-manager/modules/fzf.nix:1-17` - fzf configuration
- `nixpkgs/home-manager/modules/bat.nix:1-11` - bat configuration
- `nixpkgs/home-manager/modules/common.nix:53` - just installed

### Configuration
- `nixpkgs/home-manager/modules/zsh.nix:133-142` - Sources shell files
- `nixpkgs/home-manager/modules/zsh.nix:214-217` - just completion
- `shell/shell_aliases:1-50` - Current aliases
- `private/private_functions:1-58` - Private functions

## Architecture Insights

### What's Working Well
1. **FZF integration** - Deeply integrated and proven successful across 6+ patterns
2. **Just task runner** - Excellent self-documenting organization for project tasks
3. **Nix-based tooling** - Declarative, reproducible, cross-platform package management
4. **Namespace prefixing** - Informal but effective (nix-*, git-*, k8-*, server-*)
5. **Platform detection** - Simple, reusable pattern with `is_mac()`, `is_linux()`

### Opportunities for Improvement
1. **Scattered commands** - No unified access point, discoverability is hard
2. **Underutilized gum** - Installed but only used in one script
3. **No help system** - Beyond command-specific --help flags
4. **Plain text output only** - No JSON/table/quiet modes for scripting
5. **Informal namespacing** - Works but inconsistent implementation
6. **No command history** - Beyond default zsh history
7. **Documentation gaps** - Comments in code, but no structured docs

### Design Patterns to Adopt
1. **Dispatcher pattern** - Central `rr` script with namespace routing
2. **Namespace isolation** - Each namespace in separate file with consistent structure
3. **Wrapper functions** - Keep existing functions as thin wrappers during migration
4. **Progressive enhancement** - Add features without breaking existing workflows
5. **Configuration-driven** - Aliases, help text, docs from config files
6. **Multi-format output** - Environment variables for output format selection
7. **LLM-friendly docs** - Structured markdown with metadata, examples, exit codes

### Success Metrics
- **Discoverability**: Time to find a command (measure with user testing)
- **Consistency**: All commands follow same structure (measurable via code review)
- **Documentation**: % of commands with structured docs (track in CI)
- **Adoption**: % of command invocations using `rr` vs direct calls (track via history)
- **UX improvement**: User satisfaction with gum enhancements (survey)

## Related Research

This research builds upon:
- `thoughts/_shared/research/cli.md` - Original CLI development research with TUI tool reference
- Research document proposes aspirational `rr` CLI structure
- This document provides concrete implementation path for this dotfiles repository
- Identifies what's already implemented vs what's missing
- Provides actionable roadmap with priorities and timelines
