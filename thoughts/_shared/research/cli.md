# CLI Tool Development Research Brief

## Project Overview

Creating a simple command-line tool with namespace support, shell completion, and help commands without being tied to a specific programming language.

## Feature Checklist

### Core Features

- ✅ Namespace-based command structure (`rr <namespace> <command>`)
- ✅ Namespace aliasing (`rr b` → `rr brain`)
- ✅ Shell completion (bash/zsh/fish)
- ✅ Multi-level help system (`rr help`, `rr blog --help`)

### Discovery & Navigation

- ✅ Command history with fzf (`rr history`, `rr last`)
- ✅ Smart search across namespaces (`rr search <keyword>`)
- ✅ Command location finder (`rr which <command>`)

### Developer Experience

- ✅ Verbose modes (`-v`, `-vv`, `--trace`)
- ✅ Debug output with timing information
- ✅ Multiple output formats (`--json`, `--quiet`, `--format table`)

### Documentation

- ✅ Enhanced help with examples
- ✅ Full documentation system (`rr docs <namespace>`)
- ✅ Examples cookbook (`rr examples`)
- ✅ Auto-generated docs (`rr generate-docs`)
- ✅ LLM-friendly documentation format

## Requirements

### Core Requirements

- Command structure: `rr <namespace> <command> [args]`
- Example usage:
  - `rr blog start`
  - `rr blog stop`
  - `rr brain search`
  - `rr server up`
- Built-in help system:
  - `rr help` - Show all namespaces
  - `rr blog --help` - Show namespace-specific help with examples
  - `rr docs <namespace>` - Open full documentation
  - `rr examples` - Show cookbook of common patterns
- Shell completion support (bash/zsh/fish)
- Easy to manage and extend
- Prefer using existing tools like `just` and `gum`
- Command history with fzf for quick re-runs
- Smart search across namespaces
- Verbose and debug modes for troubleshooting
- LLM-friendly documentation format

### Design Goals

- Language agnostic (use shell scripts as glue)
- Each namespace isolated in separate files
- Maintainable and simple structure
- Can integrate with external tools (`just`, `gum`, etc.)
- Support namespace aliasing for quick access (e.g., `rr b` → `rr brain`)

## Proposed Solution Architecture

### Directory Structure

```
rr (main dispatcher script)
├── namespaces/
│   ├── blog.sh
│   ├── brain.sh
│   └── server.sh
└── completions/
    ├── rr.bash
    ├── rr.zsh
    └── rr.fish
```

### Key Components

#### 1. Main Dispatcher

- Single entry point script (`rr`)
- Sources namespace files dynamically
- Handles help and error messages
- Passes arguments to namespace handlers

#### 2. Namespace Files

- Self-contained shell scripts
- Define commands using case statements
- Include namespace-specific help
- Can call `just` recipes, other CLIs, or custom logic

#### 3. Shell Completion

- Dynamic completion based on available namespaces
- Context-aware command completion
- Multi-level completion support

## CLI/TUI Tools Reference

### Interactive Selectors & Pickers

| Tool          | Description                  | Use Case                                   |
| ------------- | ---------------------------- | ------------------------------------------ |
| **fzf**       | Fuzzy finder                 | Interactive file/option selection          |
| **skim (sk)** | Rust-based fuzzy finder      | fzf alternative with different features    |
| **peco**      | Simple interactive filtering | Simpler than fzf, good for basic selection |
| **percol**    | Python interactive grep      | Filtering command output                   |
| **huh**       | TUI forms and prompts        | Complex form-based input                   |

### TUI Builders & Prompts

| Tool          | Description              | Language | Use Case                           |
| ------------- | ------------------------ | -------- | ---------------------------------- |
| **gum**       | Shell script TUI toolkit | Any      | Prompts, input, styling in scripts |
| **bubbletea** | TUI framework            | Go       | Building full TUI applications     |
| **inquirer**  | Interactive CLI prompts  | Multiple | Form-based CLI interactions        |
| **survey**    | CLI prompt library       | Go       | User input in Go programs          |
| **dialoguer** | Command-line prompts     | Rust     | Interactive Rust CLIs              |

### Progress & Spinners

| Tool         | Description          | Use Case                        |
| ------------ | -------------------- | ------------------------------- |
| **progress** | Simple progress bars | Visual feedback for operations  |
| **pv**       | Pipe Viewer          | Monitor data flow through pipes |
| **tqdm**     | Python progress bar  | Long-running script feedback    |
| **gum spin** | Spinner component    | Loading indicators              |

### Text Styling & Formatting

| Tool         | Description                   | Use Case                      |
| ------------ | ----------------------------- | ----------------------------- |
| **bat**      | Cat with syntax highlighting  | Display code/config files     |
| **rich-cli** | Beautiful terminal formatting | Styled output in Python       |
| **mdcat**    | Markdown renderer             | Display markdown in terminal  |
| **glow**     | Markdown renderer with paging | Beautiful markdown help files |

### Dashboard & Display

| Tool        | Description             | Language | Use Case                      |
| ----------- | ----------------------- | -------- | ----------------------------- |
| **termui**  | Terminal dashboard      | Go       | System monitoring dashboards  |
| **blessed** | TUI library             | Node.js  | Full terminal UIs             |
| **ncurses** | Traditional TUI library | C        | Classic terminal interfaces   |
| **tview**   | Rich TUI framework      | Go       | Complex terminal applications |

### File/Directory Navigation

| Tool       | Description                 | Use Case                  |
| ---------- | --------------------------- | ------------------------- |
| **ranger** | Terminal file manager       | VI-style file navigation  |
| **nnn**    | Fast file manager           | Lightweight file browsing |
| **broot**  | Better tree with navigation | Directory exploration     |
| **walk**   | Terminal navigator          | Fuzzy search navigation   |

### Menus & Selection

| Tool      | Description               | Use Case             |
| --------- | ------------------------- | -------------------- |
| **rofi**  | Application launcher/menu | Desktop integration  |
| **dmenu** | Dynamic menu              | X11 menu system      |
| **smenu** | Selection filter          | Terminal menus       |
| **pick**  | Fuzzy select from stdin   | Pipe-based selection |

### Notification & Display

| Tool            | Description           | Use Case                      |
| --------------- | --------------------- | ----------------------------- |
| **notify-send** | Desktop notifications | System notifications from CLI |
| **figlet**      | ASCII art text        | Command headers/branding      |
| **lolcat**      | Rainbow text coloring | Fun output styling            |
| **boxes**       | ASCII art boxes       | Framing text output           |

## Recommended Tool Combinations

### Essential Stack

- **gum** - Prompts, inputs, confirmation dialogs
- **fzf** - Fuzzy selection from lists
- **bat** - Displaying file contents with syntax highlighting

### Enhanced Stack

Add these for richer experiences:

- **glow** - Displaying markdown help documentation
- **pv** - Progress indicators for long operations
- **figlet** - Styled command headers

### Example Integration

```bash
# fzf for selection
selected=$(ls | fzf --prompt="Choose file: ")

# gum for confirmation
gum confirm "Process $selected?" && process_file "$selected"

# bat for display
bat --style=numbers "$selected"

# glow for help
glow docs/help.md
```

### Alias Implementation Patterns

**Pattern 1: Simple Case Statement**

```bash
# In main rr script
NAMESPACE="${1}"

# Resolve aliases
case "$NAMESPACE" in
    b) NAMESPACE="brain" ;;
    iv) NAMESPACE="invideo" ;;
    s) NAMESPACE="server" ;;
    bl) NAMESPACE="blog" ;;
esac
```

**Pattern 2: Config File Based**

```bash
# Load aliases from config
ALIAS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/rr/aliases.conf"
if [[ -f "$ALIAS_FILE" ]]; then
    # Parse aliases (format: alias=namespace)
    while IFS='=' read -r alias namespace; do
        [[ "$NAMESPACE" == "$alias" ]] && NAMESPACE="$namespace" && break
    done < "$ALIAS_FILE"
fi
```

**Pattern 3: Associative Array (Bash 4+)**

```bash
declare -A ALIASES=(
    [b]="brain"
    [iv]="invideo"
    [s]="server"
    [bl]="blog"
)

NAMESPACE="${ALIASES[$NAMESPACE]:-$NAMESPACE}"
```

### Complete Feature Integration Example

Here's how multiple features work together:

```bash
#!/usr/bin/env bash
# Main rr script with all features

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HISTORY_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/rr/history"
VERBOSE=""
TRACE=""
OUTPUT_FORMAT="default"

# Parse global flags
while [[ $# -gt 0 ]]; do
    case $1 in
        -v) VERBOSE="1"; shift ;;
        -vv) VERBOSE="2"; shift ;;
        --trace) TRACE="1"; shift ;;
        --json) OUTPUT_FORMAT="json"; shift ;;
        --quiet) OUTPUT_FORMAT="quiet"; shift ;;
        --format) OUTPUT_FORMAT="$2"; shift 2 ;;
        *) break ;;
    esac
done

NAMESPACE="${1}"
shift

# Debug helper
debug() {
    [[ "$VERBOSE" == "1" ]] && echo "[DEBUG] $*" >&2
}

trace() {
    [[ "$VERBOSE" == "2" ]] && echo "[TRACE] $*" >&2
}

# Enable bash trace if requested
[[ "$TRACE" == "1" ]] && set -x

# Special commands
case "$NAMESPACE" in
    history)
        # Show command history with fzf
        selected=$(tac "$HISTORY_FILE" | \
                   fzf --no-sort \
                       --preview 'echo {}' \
                       --preview-window down:3)
        [[ -n "$selected" ]] && eval "rr ${selected#*|}"
        exit 0
        ;;
    last)
        # Re-run last command
        last_cmd=$(tail -1 "$HISTORY_FILE" | cut -d'|' -f2)
        debug "Re-running: $last_cmd"
        eval "$last_cmd"
        exit $?
        ;;
    search)
        # Search for commands across namespaces
        keyword="$1"
        for ns in "$SCRIPT_DIR"/namespaces/*.sh; do
            grep -n "^[a-z_]*() {" "$ns" | \
            grep -i "$keyword" | \
            sed "s|$SCRIPT_DIR/namespaces/||;s|.sh:|:|"
        done | fzf --preview 'rr which {1}'
        exit 0
        ;;
    which)
        # Show which namespace contains a command
        cmd="$1"
        grep -l "^${cmd}()" "$SCRIPT_DIR"/namespaces/*.sh | \
        sed "s|$SCRIPT_DIR/namespaces/||;s|.sh||"
        exit 0
        ;;
    docs)
        # Show documentation with glow
        ns="$1"
        [[ -f "docs/namespaces/${ns}.md" ]] && \
            glow "docs/namespaces/${ns}.md" || \
            echo "No documentation found for namespace: $ns"
        exit 0
        ;;
    examples)
        # Show examples
        glow docs/examples/
        exit 0
        ;;
    generate-docs)
        # Auto-generate documentation
        echo "# CLI Documentation"
        echo ""
        for ns in "$SCRIPT_DIR"/namespaces/*.sh; do
            basename=$(basename "$ns" .sh)
            echo "## Namespace: $basename"
            grep "^[a-z_]*() {" "$ns" | sed 's/() {.*//'
            echo ""
        done
        exit 0
        ;;
esac

# Load aliases
ALIAS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/rr/aliases.conf"
if [[ -f "$ALIAS_FILE" ]]; then
    while IFS='=' read -r alias namespace_full; do
        [[ "$NAMESPACE" == "$alias" ]] && NAMESPACE="$namespace_full" && break
    done < "$ALIAS_FILE"
fi

debug "Resolved namespace: $NAMESPACE"

# Load namespace
NAMESPACE_FILE="$SCRIPT_DIR/namespaces/$NAMESPACE.sh"
if [[ ! -f "$NAMESPACE_FILE" ]]; then
    echo "Error: Unknown namespace '$NAMESPACE'" >&2
    exit 1
fi

trace "Loading: $NAMESPACE_FILE"

# Export environment for namespace scripts
export RR_VERBOSE="$VERBOSE"
export RR_TRACE="$TRACE"
export RR_OUTPUT_FORMAT="$OUTPUT_FORMAT"

# Record start time
START_TIME=$(date +%s)

# Execute namespace
source "$NAMESPACE_FILE"

# Record to history
EXIT_CODE=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "$(date -Iseconds)|rr $NAMESPACE $*|$EXIT_CODE|${DURATION}s" >> "$HISTORY_FILE"

trace "Execution time: ${DURATION}s"
trace "Exit code: $EXIT_CODE"

exit $EXIT_CODE
```

### Example Namespace Using All Features

```bash
#!/usr/bin/env bash
# namespaces/blog.sh - Example with all features

CMD="${1}"
shift

# Use environment variables from main script
VERBOSE="${RR_VERBOSE:-0}"
OUTPUT_FORMAT="${RR_OUTPUT_FORMAT:-default}"

# Helper functions
debug() {
    [[ "$VERBOSE" -ge 1 ]] && echo "[blog] $*" >&2
}

output_json() {
    local status=$1
    local data=$2
    echo "{\"command\":\"blog $CMD\",\"status\":\"$status\",\"data\":$data}"
}

output_table() {
    local header=$1
    shift
    echo "$header"
    printf '%s\n' "$@" | column -t
}

blog_help() {
    cat << 'EOF'
Usage: rr blog <command> [options]

Commands:
  start [--port PORT]    Start the blog server (default: 3000)
  stop                   Stop the blog server
  build                  Build the blog for production
  deploy                 Deploy to production
  status                 Show server status

Options:
  --port PORT           Server port (default: 3000)
  --host HOST           Host address (default: localhost)
  -h, --help            Show this help

Examples:
  # Start server on default port
  rr blog start

  # Start on custom port
  rr blog start --port 8080

  # Check status with JSON output
  rr --json blog status

  # Deploy with verbose output
  rr -v blog deploy

For detailed documentation: rr docs blog
EOF
}

blog_start() {
    local port=3000
    local host="localhost"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --port) port="$2"; shift 2 ;;
            --host) host="$2"; shift 2 ;;
            *) echo "Unknown option: $1"; blog_help; return 1 ;;
        esac
    done

    debug "Starting blog server on $host:$port"

    # Check if port is in use
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        if [[ "$OUTPUT_FORMAT" == "json" ]]; then
            output_json "error" '{"message":"Port already in use","port":'$port'}'
        else
            echo "Error: Port $port is already in use" >&2
        fi
        return 1
    fi

    # Start the server (example using just)
    debug "Executing: just blog-start --port $port --host $host"

    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        output_json "success" '{"message":"Server started","port":'$port',"host":"'$host'"}'
    elif [[ "$OUTPUT_FORMAT" == "quiet" ]]; then
        # Suppress output in quiet mode
        just blog-start --port "$port" --host "$host" >/dev/null 2>&1
    else
        gum style --border double --padding "1 2" \
            "Blog server starting..." \
            "" \
            "URL: http://$host:$port" \
            "Press Ctrl+C to stop"
        just blog-start --port "$port" --host "$host"
    fi
}

blog_status() {
    debug "Checking blog server status"

    local pid=$(pgrep -f "blog-server" | head -1)
    local uptime=""

    if [[ -n "$pid" ]]; then
        uptime=$(ps -p "$pid" -o etime= | tr -d ' ')

        if [[ "$OUTPUT_FORMAT" == "json" ]]; then
            output_json "success" '{"status":"running","pid":'$pid',"uptime":"'$uptime'"}'
        elif [[ "$OUTPUT_FORMAT" == "table" ]]; then
            gum table --columns "Status,PID,Uptime" \
                      --data "Running,$pid,$uptime"
        else
            echo "Blog server is running"
            echo "  PID: $pid"
            echo "  Uptime: $uptime"
        fi
    else
        if [[ "$OUTPUT_FORMAT" == "json" ]]; then
            output_json "success" '{"status":"stopped"}'
        else
            echo "Blog server is not running"
        fi
    fi
}

blog_deploy() {
    debug "Starting deployment process"

    if ! gum confirm "Deploy to production?"; then
        echo "Deployment cancelled"
        return 0
    fi

    debug "Building blog"
    rr blog build || return 1

    debug "Deploying to production"
    just blog-deploy

    if [[ $? -eq 0 ]]; then
        [[ "$OUTPUT_FORMAT" != "quiet" ]] && \
            gum style --foreground 212 "✓ Deployment successful!"
        return 0
    else
        echo "Deployment failed" >&2
        return 1
    fi
}

# Command dispatcher
case "$CMD" in
    start) blog_start "$@" ;;
    stop) debug "Stopping blog"; just blog-stop ;;
    build) debug "Building blog"; just blog-build ;;
    deploy) blog_deploy "$@" ;;
    status) blog_status ;;
    --help|help|"") blog_help ;;
    *)
        echo "Unknown command: $CMD" >&2
        blog_help
        exit 1
        ;;
esac
```

## Implementation Considerations

### Command History

- **Storage location**: `~/.config/rr/history` or `~/.rr_history`
- **Format options**:
  - Simple text: One command per line with timestamp
  - JSON: Structured with metadata (timestamp, exit code, duration)
  - SQLite: Queryable database for advanced features
- **History entry structure**:
  ```
  2025-10-20T10:30:45Z|rr blog start|0|2.3s
  2025-10-20T10:35:12Z|rr brain search "cli tools"|0|0.5s
  ```
- **Implementation with fzf**:
  ```bash
  rr history() {
      selected=$(tail -100 ~/.rr_history | \
                 fzf --tac --no-sort \
                     --preview 'echo {}' \
                     --preview-window down:3:wrap)
      # Execute selected command
  }
  ```
- **`rr last` implementation**: Simply read last line from history and execute
- **History management**:
  - Maximum entries (default 1000)
  - History pruning/rotation
  - Option to exclude commands from history

### Smart Search

- **Search implementation approaches**:
  1. **Grep-based**: Search through namespace files for function names and comments
  2. **Index-based**: Pre-build search index for faster lookups
  3. **Metadata-based**: Each namespace declares its commands in a manifest
- **Search sources**:
  - Command names (function names in namespace files)
  - Help text and descriptions
  - Command aliases
  - Comments and documentation
- **Integration with fzf**:
  ```bash
  rr search <keyword> | fzf --preview 'rr which {}'
  ```
- **Output format**:
  ```
  blog:start     - Start the blog server
  blog:deploy    - Deploy blog to production
  server:start   - Start the development server
  ```

### Verbose & Debug Modes

- **Implementation using flags**:
  - Parse `-v`, `-vv`, `--trace` before namespace
  - Set environment variables: `RR_VERBOSE=1`, `RR_TRACE=1`
  - Namespace scripts check these variables
- **Output helpers**:

  ```bash
  debug() {
      [[ -n "$RR_VERBOSE" ]] && echo "[DEBUG] $*" >&2
  }

  trace() {
      [[ -n "$RR_TRACE" ]] && echo "[TRACE] $*" >&2
  }
  ```

- **What to show at each level**:
  - **Normal**: Only final output
  - **-v (verbose)**: Show major steps and commands
  - **-vv (extra verbose)**: Include timing, env vars, file reads
  - **--trace**: Full bash execution trace (`set -x`)

### Enhanced Documentation System

- **Documentation structure**:
  ```
  docs/
  ├── README.md              # Main documentation
  ├── namespaces/
  │   ├── blog.md           # Namespace-specific docs
  │   ├── brain.md
  │   └── server.md
  ├── examples/
  │   ├── getting-started.md
  │   └── common-workflows.md
  └── api/
      └── generated.md       # Auto-generated from code
  ```
- **LLM-friendly documentation format**:

  ```markdown
  ## Command: rr blog start

  ### Description

  Starts the blog development server on port 3000

  ### Syntax

  rr blog start [--port PORT] [--host HOST]

  ### Parameters

  - `--port`: Server port (default: 3000)
  - `--host`: Host address (default: localhost)

  ### Examples

  # Start with defaults

  rr blog start

  # Start on custom port

  rr blog start --port 8080

  # Start on all interfaces

  rr blog start --host 0.0.0.0

  ### Output

  Server starting on http://localhost:3000
  Press Ctrl+C to stop

  ### Exit Codes

  - 0: Success
  - 1: Port already in use
  - 2: Invalid configuration

  ### Related Commands

  - rr blog stop - Stop the server
  - rr blog restart - Restart the server
  ```

- **Documentation generation**:
  - Parse namespace files for functions
  - Extract comments as documentation
  - Generate help text automatically
  - Include usage examples from test files

### Output Formatting

- **Format detection**:
  - Check for `--json`, `--quiet`, `--format` flags
  - Set environment variable for namespace scripts
- **JSON output structure**:
  ```json
  {
    "command": "rr blog status",
    "namespace": "blog",
    "timestamp": "2025-10-20T10:30:45Z",
    "exit_code": 0,
    "output": {
      "status": "running",
      "port": 3000,
      "uptime": "2h 15m"
    }
  }
  ```
- **Table output using gum**:
  ```bash
  gum table --columns "Name,Status,Port" \
            --data "Blog,Running,3000" \
            --data "API,Stopped,-"
  ```
- **Quiet mode**: Suppress all output except errors and final result

### Namespace Aliasing

- Support short aliases for frequently used namespaces
- Examples:
  - `rr b` → `rr brain`
  - `rr iv` → `rr invideo`
  - `rr s` → `rr server`
- Implementation approaches:
  - **Config file**: Store aliases in `~/.config/rr/aliases.conf`
  - **Inline mapping**: Define aliases in main `rr` script
  - **Symlinks**: Create symlinked namespace files (e.g., `b.sh` → `brain.sh`)
- Alias resolution should happen before namespace lookup
- Shell completion should include both full names and aliases
- Consider alias conflicts and priority rules
- `rr alias list` - Show all configured aliases
- `rr alias add <short> <full>` - Add new alias dynamically

### Shell Completion

- Must be loaded in shell config (`.bashrc`, `.zshrc`)
- Needs to discover namespaces dynamically
- Should support nested command completion
- Consider using `complete` (bash) or `compdef` (zsh)
- **Alias completion requirements:**
  - Tab completion should suggest both aliases and full namespace names
  - After selecting an alias, subsequent completions should show commands for the resolved namespace
  - Example: `rr b <TAB>` should show brain commands (search, add, list, etc.)
  - Completion script needs access to alias mappings

### Error Handling

- Clear error messages for unknown namespaces
- Helpful suggestions when commands fail
- Consistent exit codes

### Documentation

- Built-in `--help` at all levels
- Optional markdown help files (viewable with `glow`)
- Auto-generated completion documentation

### Extensibility

- Easy to add new namespaces (just add a `.sh` file)
- Can mix different tools per namespace
- Support for plugins or extensions

## Research Topics for Further Investigation

1. **Command History Management**
   - Best storage formats (text, JSON, SQLite)
   - History size limits and rotation strategies
   - Privacy considerations (sensitive data in commands)
   - Cross-session history synchronization
   - Integration patterns with fzf for history selection

2. **Smart Search & Command Discovery**
   - Indexing strategies for fast search
   - Fuzzy matching algorithms
   - Search ranking and relevance
   - Caching search results
   - Real-time vs pre-indexed search trade-offs

3. **LLM-Friendly Documentation**
   - Best documentation structure for AI consumption
   - Schema.org or structured data formats
   - Auto-generating examples from usage
   - Documentation versioning
   - Embedding documentation in tool vs separate files

4. **Namespace Aliasing Systems**
   - Best practices for alias management
   - Config file vs hardcoded aliases
   - Dynamic alias registration
   - Alias collision detection and resolution
   - Making aliases work with shell completion

5. **Advanced Shell Completion**
   - Multi-level completion strategies
   - Dynamic completion generation
   - Cross-shell compatibility

6. **Tool Integration Patterns**
   - Best practices for combining gum + fzf
   - Error handling when tools aren't installed
   - Fallback strategies

7. **TUI Framework Comparison**
   - When to use gum vs bubbletea vs blessed
   - Performance considerations
   - Feature matrix comparison

8. **Configuration Management**
   - Config file formats for CLI tools
   - Environment variable handling
   - XDG Base Directory compliance

9. **Distribution & Installation**
   - Package managers (brew, apt, etc.)
   - Single-binary distribution
   - Update mechanisms

10. **Testing Strategies**
    - Testing shell scripts
    - Integration testing for CLI tools
    - Completion testing

## Additional Questions to Explore

- How to handle alias conflicts with actual namespace names?
- Should aliases be user-specific or system-wide?
- How to handle namespace conflicts or collisions?
- Best format for storing command history (text vs JSON vs SQLite)?
- How to prevent sensitive data (passwords, tokens) from being stored in history?
- Should search be real-time or use a pre-built index?
- How to rank search results by relevance?
- What's the best way to auto-generate documentation from code?
- How to structure documentation for optimal LLM understanding?
- Should verbose output go to stderr or stdout?
- How to handle output formatting when piping to other commands?
- What's the performance impact of JSON output vs plain text?
- How to validate JSON output schemas?
- Best practices for CLI tool versioning?
- How to implement plugin systems in shell scripts?
- Performance optimization for shell script dispatchers?
- How to add telemetry or analytics (if needed)?
- Cross-platform compatibility considerations (Linux/Mac/Windows)?
- How to implement auto-update mechanisms?
- Best practices for logging in CLI tools?

## LLM-Friendly Documentation Guidelines

To make documentation easily consumable by LLMs (Claude, GPT, etc.), follow these principles:

### Structure and Format

- **Use consistent markdown formatting** with clear headers (H2 for commands, H3 for subsections)
- **Provide complete context** in each section - avoid assuming prior knowledge
- **Use code blocks with language tags** for all examples
- **Include both success and failure examples** to show edge cases

### Command Documentation Template

```markdown
## Command: rr <namespace> <command>

### Purpose

One-line description of what the command does

### Syntax

rr <namespace> <command> [OPTIONS] [ARGUMENTS]

### Parameters

- `--flag`: Description (type: string, default: value)
- `argument`: Description (required/optional)

### Prerequisites

- List of required tools or setup
- Environment variables needed
- Permissions required

### Examples

#### Basic Usage

[code block with basic example]
Expected output:
[code block showing output]

#### Advanced Usage

[code block with advanced example]
Expected output:
[code block showing output]

#### Error Cases

[code block showing wrong usage]
Error output:
[code block showing error message]

### Exit Codes

- 0: Success
- 1: General error
- 2: Specific error type

### Output Format

Description of output structure, especially for --json

### Related Commands

- rr namespace other-command - Description
- rr other-namespace command - Description

### Notes

- Important caveats
- Performance considerations
- Known limitations
```

### Best Practices for LLM Consumption

1. **Explicit over implicit**: Don't use phrases like "as mentioned above" - repeat context
2. **Self-contained examples**: Each example should work independently
3. **Show don't tell**: Include actual command output, not just descriptions
4. **Error scenarios**: Document common errors and their solutions
5. **Type information**: Specify types for all parameters (string, number, boolean, path)
6. **Default values**: Always state defaults explicitly
7. **Dependencies**: List all required tools and versions
8. **Versioning**: Include version info if behavior changes between versions

### Metadata for Better Discovery

Include YAML frontmatter in documentation:

```yaml
---
command: rr blog start
namespace: blog
category: server
tags: [development, http, server]
requires: [node, npm]
version: 1.0.0
---
```

### Interactive Documentation Features

- **Searchable**: Include keywords in descriptions
- **Examples library**: Maintain separate examples file with real-world scenarios
- **Troubleshooting guide**: Common issues and solutions
- **Quick reference**: Cheat sheet format for common operations

## References & Resources to Investigate

- Charm CLI tools documentation (gum, glow, etc.)
- fzf advanced usage and integration patterns
- Shell completion scripting guides
- CLI design patterns and best practices
- Tool alternatives and comparisons
- Performance benchmarks of various TUI tools
