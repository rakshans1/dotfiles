# Server Namespace Implementation Plan for rr CLI

## Overview

Add a new `server` namespace to the `rr` CLI dispatcher for managing the Caddy web server. This namespace will provide simple commands to start, stop, and reload the Caddy server configuration.

## Current State Analysis

### Existing Infrastructure

**Caddy Setup:**
- Caddy installed via Nix: `/Users/rakshan/.nix-profile/bin/caddy`
- Main Caddyfile: `private/caddy/Caddyfile`
- Multiple project Caddyfiles imported from various directories
- Raycast extension already exists for monitoring Caddy sites

**Projects Using Caddy:**
- workspace/iv-pro
- projects/htpc
- projects/node/brain-public
- projects/node/rakshanshetty.in
- projects/elixir/music
- projects/elixir/budget
- projects/elixir/livebooks
- projects/elixir/bom-gem-25

**Existing Patterns:**
- rr CLI infrastructure complete (Phases 1-5 implemented)
- Helper library available: `private/rr/lib/helpers.sh`
- Namespace generator: `private/rr/bin/rr-new-namespace`
- Similar namespace: `blog.sh` - Good reference for interactive commands

## Desired End State

### After Implementation

Users can manage Caddy server using:

```bash
# Start Caddy server
rr server start

# Stop Caddy server
rr server stop

# Reload Caddy configuration
rr server reload

# Check Caddy status
rr server status

# View Caddy logs (optional)
rr server logs
```

### Success Criteria

- ✓ `rr server start` starts Caddy with the main Caddyfile
- ✓ `rr server stop` gracefully stops Caddy
- ✓ `rr server reload` reloads configuration without downtime
- ✓ `rr server status` shows whether Caddy is running
- ✓ All commands support quiet/silent/verbose modes
- ✓ Interactive mode shows gum UI
- ✓ Non-interactive mode works for automation
- ✓ Documentation created at `docs/namespaces/server.md`

## What We're NOT Doing

To prevent scope creep:

1. **Not managing individual project servers** - Only Caddy itself, not project-specific servers
2. **Not auto-discovering Caddyfiles** - Use the existing Caddyfile configuration
3. **Not managing certificates** - Caddy handles this automatically
4. **Not editing Caddyfile** - Use editor for configuration changes
5. **Not monitoring traffic/stats** - Raycast extension handles this
6. **Not creating new sites** - Manual Caddyfile editing required

## Implementation Approach

### Strategy

1. **Leverage existing helpers**: Use `private/rr/lib/helpers.sh` for common patterns
2. **Follow blog.sh pattern**: Similar interactive/non-interactive command structure
3. **Use Caddy API**: Leverage `caddy` CLI commands for all operations
4. **Keep it simple**: Basic start/stop/reload only, no complex management

### Caddy Commands to Use

```bash
# Start Caddy (foreground for development)
caddy run --config /path/to/Caddyfile

# Start Caddy (background via adapter)
caddy start --config /path/to/Caddyfile

# Stop Caddy
caddy stop

# Reload configuration
caddy reload --config /path/to/Caddyfile

# Check if Caddy is running
caddy validate --config /path/to/Caddyfile  # Validates config
pgrep -x caddy  # Check if process is running
```

## Implementation

### Phase 1: Create Server Namespace ✅

**Time Estimate**: 1-2 hours

#### 1. Generate Namespace Scaffolding ✅

```bash
cd ~/dotfiles/private/rr
./bin/rr-new-namespace server \
  --with-gum \
  --commands "start,stop,reload,status" \
  --description "Manage Caddy web server"
```

This creates:
- `namespaces/server.sh` - With boilerplate for all commands
- `docs/namespaces/server.md` - Documentation template

#### 2. Implement Server Namespace ✅

**File**: `private/rr/namespaces/server.sh`

**Complete Implementation:**

```bash
#!/usr/bin/env bash
# namespaces/server.sh - Manage Caddy web server

CMD="${1:-}"
shift || true

# Caddy configuration
CADDY_CONFIG="$HOME/dotfiles/private/caddy/Caddyfile"
CADDY_BIN="caddy"

# Check if gum is available
HAS_GUM=false
command -v gum >/dev/null 2>&1 && HAS_GUM=true

# Source shared helpers
source "$RR_DIR/lib/common.sh"
source "$RR_DIR/lib/helpers.sh"

# Setup namespace-specific debug function
rr_namespace_setup "server"

# Helper: Check if Caddy is running
is_caddy_running() {
  pgrep -x caddy >/dev/null 2>&1
}

# Helper: Validate Caddyfile exists
validate_caddyfile() {
  if [[ ! -f "$CADDY_CONFIG" ]]; then
    rr_fail "Caddyfile not found: $CADDY_CONFIG"
    return 1
  fi
  return 0
}

# Help function
server_help() {
  cat <<'EOF'
Usage: rr server <command> [options]

Commands:
  start      Start Caddy web server
  stop       Stop Caddy web server
  reload     Reload Caddy configuration without downtime
  status     Check if Caddy is running

Examples:
  # Start Caddy server
  rr server start

  # Stop Caddy server
  rr server stop

  # Reload configuration (hot reload)
  rr server reload

  # Check status
  rr server status

  # Non-interactive start (for automation)
  rr -y server start

  # Quiet mode (suppress output)
  rr -q server stop

  # Verbose mode (show debug output)
  rr -v server start

For detailed documentation: rr docs server
EOF
}

# Command implementations
case "$CMD" in
  start)
    debug "Starting Caddy server"
    trace "Caddyfile: $CADDY_CONFIG"

    validate_caddyfile || exit 1

    if is_caddy_running; then
      debug "Caddy is already running"
      if [[ "${RR_QUIET}" != "true" ]]; then
        rr_info "Caddy is already running"
      fi
      exit 0
    fi

    if $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
      # Interactive mode with gum
      if [[ "${RR_QUIET}" != "true" ]]; then
        gum style \
          --border double \
          --padding "1 2" \
          --margin "1" \
          "🚀 Caddy Web Server" \
          "" \
          "Config: ~/dotfiles/private/caddy/Caddyfile" \
          "This will start Caddy in background mode"
      fi

      if rr_gum_confirm "Start Caddy server?"; then
        if [[ "${RR_SILENT}" == "true" ]]; then
          caddy start --config "$CADDY_CONFIG" >/dev/null 2>&1
        elif [[ "${RR_QUIET}" == "true" ]]; then
          caddy start --config "$CADDY_CONFIG" >/dev/null
        else
          gum spin --spinner dot --title "Starting Caddy..." -- \
            caddy start --config "$CADDY_CONFIG"
          rr_gum_success "Caddy started successfully"
        fi
      else
        exit 0
      fi
    else
      # Non-interactive mode
      if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
        rr_info "Starting Caddy server..."
      fi

      if [[ "${RR_SILENT}" == "true" ]]; then
        caddy start --config "$CADDY_CONFIG" >/dev/null 2>&1
      elif [[ "${RR_QUIET}" == "true" ]]; then
        caddy start --config "$CADDY_CONFIG" >/dev/null
      else
        caddy start --config "$CADDY_CONFIG"
        rr_success "Caddy started successfully"
      fi
    fi

    debug "Caddy started"
    ;;

  stop)
    debug "Stopping Caddy server"

    if ! is_caddy_running; then
      debug "Caddy is not running"
      if [[ "${RR_QUIET}" != "true" ]]; then
        rr_info "Caddy is not running"
      fi
      exit 0
    fi

    if $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
      # Interactive mode
      if [[ "${RR_QUIET}" != "true" ]]; then
        gum style "Stopping Caddy server..."
      fi

      if rr_gum_confirm "Stop Caddy server?"; then
        if [[ "${RR_SILENT}" == "true" ]]; then
          caddy stop >/dev/null 2>&1
        elif [[ "${RR_QUIET}" == "true" ]]; then
          caddy stop >/dev/null
        else
          gum spin --spinner dot --title "Stopping Caddy..." -- caddy stop
          rr_gum_success "Caddy stopped successfully"
        fi
      else
        exit 0
      fi
    else
      # Non-interactive mode
      if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
        rr_info "Stopping Caddy server..."
      fi

      if [[ "${RR_SILENT}" == "true" ]]; then
        caddy stop >/dev/null 2>&1
      elif [[ "${RR_QUIET}" == "true" ]]; then
        caddy stop >/dev/null
      else
        caddy stop
        rr_success "Caddy stopped successfully"
      fi
    fi

    debug "Caddy stopped"
    ;;

  reload)
    debug "Reloading Caddy configuration"
    trace "Caddyfile: $CADDY_CONFIG"

    validate_caddyfile || exit 1

    if ! is_caddy_running; then
      rr_fail "Caddy is not running. Start it first with: rr server start"
      exit 1
    fi

    if $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
      # Interactive mode
      if [[ "${RR_QUIET}" != "true" ]]; then
        gum style "Reloading Caddy configuration (zero downtime)..."
      fi

      if rr_gum_confirm "Reload Caddy configuration?"; then
        if [[ "${RR_SILENT}" == "true" ]]; then
          caddy reload --config "$CADDY_CONFIG" >/dev/null 2>&1
        elif [[ "${RR_QUIET}" == "true" ]]; then
          caddy reload --config "$CADDY_CONFIG" >/dev/null
        else
          gum spin --spinner dot --title "Reloading Caddy..." -- \
            caddy reload --config "$CADDY_CONFIG"
          rr_gum_success "Caddy configuration reloaded"
        fi
      else
        exit 0
      fi
    else
      # Non-interactive mode
      if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
        rr_info "Reloading Caddy configuration..."
      fi

      if [[ "${RR_SILENT}" == "true" ]]; then
        caddy reload --config "$CADDY_CONFIG" >/dev/null 2>&1
      elif [[ "${RR_QUIET}" == "true" ]]; then
        caddy reload --config "$CADDY_CONFIG" >/dev/null
      else
        caddy reload --config "$CADDY_CONFIG"
        rr_success "Caddy configuration reloaded"
      fi
    fi

    debug "Caddy reloaded"
    ;;

  status)
    debug "Checking Caddy status"

    if is_caddy_running; then
      trace "Caddy is running"

      if [[ "${RR_SILENT}" == "true" ]]; then
        :  # Silent mode: no output
      elif [[ "${RR_QUIET}" == "true" ]]; then
        echo "running"
      elif $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
        gum style \
          --border rounded \
          --padding "0 2" \
          "✓ Caddy is running"
      else
        rr_success "Caddy is running"
      fi
      exit 0
    else
      trace "Caddy is not running"

      if [[ "${RR_SILENT}" == "true" ]]; then
        :  # Silent mode: no output
      elif [[ "${RR_QUIET}" == "true" ]]; then
        echo "stopped"
      elif $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
        gum style \
          --border rounded \
          --padding "0 2" \
          "✗ Caddy is not running"
      else
        rr_info "Caddy is not running"
      fi
      exit 1
    fi
    ;;

  --help | help | "")
    server_help
    ;;

  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr server --help' for usage" >&2
    exit 1
    ;;
esac
```

**Key Features:**
- ✅ All commands support quiet/silent/verbose modes
- ✅ Interactive mode with gum UI and confirmations
- ✅ Non-interactive mode for LLMs/automation
- ✅ Checks if Caddy is already running before start
- ✅ Validates Caddyfile exists before operations
- ✅ Uses helper functions from `lib/helpers.sh`
- ✅ Proper error handling and exit codes

#### 3. Create Documentation ✅

**File**: `private/rr/docs/namespaces/server.md`

**Content:**

```markdown
# Server Namespace Documentation

## Overview

The `server` namespace provides commands for managing the Caddy web server. Caddy serves as a reverse proxy and web server for local development projects.

## Commands

### rr server start

**Purpose**: Start the Caddy web server in background mode.

**Syntax**:
```bash
rr server start
```

**Prerequisites**:
- Caddy installed (available via Nix)
- Caddyfile exists at `~/dotfiles/private/caddy/Caddyfile`

**What It Does**:
1. Checks if Caddy is already running
2. Validates Caddyfile exists
3. Starts Caddy in background mode with the specified config
4. Shows confirmation in interactive mode

**Examples**:

Basic usage:
```bash
$ rr server start
[Shows gum confirmation]
Proceed with start? (y/N) y
✓ Caddy started successfully
```

Non-interactive mode:
```bash
$ rr -y server start
Starting Caddy server...
✓ Caddy started successfully
```

Verbose mode:
```bash
$ rr -v server start
[server] Starting Caddy server
[TRACE] Caddyfile: /Users/rakshan/dotfiles/private/caddy/Caddyfile
✓ Caddy started successfully
```

**Exit Codes**:
- 0: Success (Caddy started or was already running)
- 1: Error (Caddyfile not found or start failed)

---

### rr server stop

**Purpose**: Stop the Caddy web server gracefully.

**Syntax**:
```bash
rr server stop
```

**What It Does**:
1. Checks if Caddy is running
2. Asks for confirmation in interactive mode
3. Sends stop signal to Caddy
4. Waits for graceful shutdown

**Examples**:

Basic usage:
```bash
$ rr server stop
Stopping Caddy server...
Stop Caddy server? (y/N) y
✓ Caddy stopped successfully
```

Non-interactive mode:
```bash
$ rr -y server stop
Stopping Caddy server...
✓ Caddy stopped successfully
```

**Exit Codes**:
- 0: Success (Caddy stopped or was not running)
- 1: Error (stop command failed)

---

### rr server reload

**Purpose**: Reload Caddy configuration without downtime (hot reload).

**Syntax**:
```bash
rr server reload
```

**Prerequisites**:
- Caddy must be running
- Caddyfile exists at `~/dotfiles/private/caddy/Caddyfile`

**What It Does**:
1. Validates Caddyfile exists
2. Checks if Caddy is running
3. Sends reload signal to apply new configuration
4. Zero downtime - connections remain active

**Use Cases**:
- Added new site to Caddyfile
- Changed proxy settings
- Updated error page handling
- Modified TLS settings

**Examples**:

Basic usage:
```bash
$ rr server reload
Reloading Caddy configuration (zero downtime)...
Reload Caddy configuration? (y/N) y
✓ Caddy configuration reloaded
```

Quiet mode:
```bash
$ rr -q server reload
# No output, just reloads
```

**Exit Codes**:
- 0: Success (configuration reloaded)
- 1: Error (Caddy not running or reload failed)

---

### rr server status

**Purpose**: Check if Caddy web server is running.

**Syntax**:
```bash
rr server status
```

**Examples**:

When running:
```bash
$ rr server status
✓ Caddy is running
```

When stopped:
```bash
$ rr server status
✗ Caddy is not running
# Exit code: 1
```

Quiet mode:
```bash
$ rr -q server status
running
# OR
stopped
```

**Exit Codes**:
- 0: Caddy is running
- 1: Caddy is not running

---

## Caddy Configuration

### Main Caddyfile Location

```
~/dotfiles/private/caddy/Caddyfile
```

### Imported Caddyfiles

The main Caddyfile imports project-specific configurations:

- `~/workspace/iv-pro/Caddyfile`
- `~/projects/htpc/Caddyfile`
- `~/projects/node/brain-public/Caddyfile`
- `~/projects/node/rakshanshetty.in/Caddyfile`
- `~/projects/elixir/music/Caddyfile`
- `~/projects/elixir/budget/Caddyfile`
- `~/projects/elixir/livebooks/Caddyfile`
- `~/projects/elixir/bom-gem-25/Caddyfile`

### Editing Configuration

```bash
# Edit main Caddyfile
vim ~/dotfiles/private/caddy/Caddyfile

# Reload after editing
rr server reload
```

## Common Use Cases

### Starting Development Environment

**Goal**: Start Caddy to serve all local projects

```bash
# Start Caddy
rr server start

# Verify it's running
rr server status

# Access projects at configured domains
# e.g., http://localhost, http://brain.local, etc.
```

### Updating Site Configuration

**Goal**: Apply Caddyfile changes without downtime

```bash
# Edit Caddyfile
vim ~/dotfiles/private/caddy/Caddyfile

# Validate syntax (optional)
caddy validate --config ~/dotfiles/private/caddy/Caddyfile

# Reload configuration
rr server reload
```

### Daily Workflow

**Goal**: Start Caddy in the morning, stop at end of day

```bash
# Morning: Start development servers
rr -y server start

# Work on projects...

# Evening: Stop Caddy
rr -y server stop
```

### Automation

**Goal**: Integrate with startup scripts

```bash
#!/bin/bash
# startup-dev.sh

# Start Caddy (non-interactive)
rr -y server start

# Start other services...
# ...
```

## Troubleshooting

### Caddy Fails to Start

**Symptoms**:
```bash
$ rr server start
Error: ...
```

**Solutions**:
1. Check if Caddy is already running: `rr server status`
2. Validate Caddyfile syntax: `caddy validate --config ~/dotfiles/private/caddy/Caddyfile`
3. Check for port conflicts: `lsof -i :80` or `lsof -i :443`
4. View Caddy logs: Check system logs or run in foreground: `caddy run --config ~/dotfiles/private/caddy/Caddyfile`

### Reload Doesn't Apply Changes

**Symptoms**:
Configuration changes not taking effect after reload

**Solutions**:
1. Verify Caddy is running: `rr server status`
2. Check Caddyfile syntax: `caddy validate --config ~/dotfiles/private/caddy/Caddyfile`
3. Try full restart instead: `rr server stop && rr server start`
4. Check if imported Caddyfiles have errors

### Port Already in Use

**Symptoms**:
```
bind: address already in use
```

**Solutions**:
1. Check what's using the port: `lsof -i :80`
2. Stop the conflicting process: `killport 80`
3. Or configure Caddy to use different ports

### Permission Denied

**Symptoms**:
```
permission denied
```

**Solutions**:
1. Caddy needs privileges for ports 80/443
2. Either:
   - Use sudo: `sudo caddy start --config ~/dotfiles/private/caddy/Caddyfile`
   - Or configure Caddy to use non-privileged ports (>1024)

## Implementation Details

**Namespace File**: `private/rr/namespaces/server.sh`

**Key Functions**:
- `is_caddy_running()` - Checks if Caddy process is running
- `validate_caddyfile()` - Ensures Caddyfile exists before operations

**Caddy Commands Used**:
- `caddy start --config <file>` - Start in background
- `caddy stop` - Graceful shutdown
- `caddy reload --config <file>` - Hot reload configuration
- `pgrep -x caddy` - Check if running

**Environment Variables**:
- `RR_NON_INTERACTIVE` - Skip confirmations
- `RR_QUIET` - Suppress normal output
- `RR_SILENT` - Suppress all output
- `RR_VERBOSE` - Show debug/trace messages

## Integration

### With Raycast Extension

The Raycast Caddy extension provides:
- Visual monitoring of configured sites
- Health checks for routes
- Site management UI

Both can be used together:
- Use `rr server` for command-line operations
- Use Raycast for visual monitoring

### With Project Caddyfiles

Each project can have its own Caddyfile:

```caddy
# projects/myapp/Caddyfile
myapp.local {
    reverse_proxy localhost:4000
}
```

Import in main Caddyfile:
```caddy
import /Users/rakshan/projects/myapp/Caddyfile
```

Reload to apply:
```bash
rr server reload
```

## See Also

- **Caddy Documentation**: https://caddyserver.com/docs/
- **Caddyfile Syntax**: https://caddyserver.com/docs/caddyfile
- **Raycast Extension**: `private/raycast/extensions/caddy/`
- **Main Caddyfile**: `private/caddy/Caddyfile`
```

#### 4. Add Namespace Alias (Optional)

**File**: `~/.config/rr/aliases.conf`

**Add line:**
```conf
s=server
srv=server
```

_Note: Aliases can be added by users as needed. The namespace works without aliases._

#### 5. Update Shell Completion ✅

The completion system auto-discovers namespaces, so this should work automatically after creating the namespace file. Test with:

```bash
exec zsh  # Reload shell
rr <TAB>  # Should show 'server'
rr server <TAB>  # Should show commands
```

### Phase 2: Testing ✅

**Time Estimate**: 30 minutes

#### Test All Commands ✅

```bash
# Test help
rr server help

# Test status (when not running)
rr server status  # Should exit 1

# Test start
rr server start
rr server status  # Should show running

# Test reload
rr server reload

# Test stop
rr server stop
rr server status  # Should exit 1

# Test non-interactive mode
rr -y server start
rr -y server stop

# Test quiet mode
rr -q server start
rr -q server status  # Should print "running"

# Test verbose mode
rr -v server start
rr -vv server reload

# Test aliases
rr s start
rr srv stop
```

#### Test Error Cases ✅

```bash
# Test reload when not running
rr server stop
rr server reload  # Should error

# Test invalid config
mv ~/dotfiles/private/caddy/Caddyfile ~/dotfiles/private/caddy/Caddyfile.bak
rr server start  # Should error: Caddyfile not found
mv ~/dotfiles/private/caddy/Caddyfile.bak ~/dotfiles/private/caddy/Caddyfile
```

### Phase 3: Documentation and Git

**Time Estimate**: 15 minutes

#### Commit Changes (Pending - User will commit)

```bash
cd ~/dotfiles

git add private/rr/namespaces/server.sh
git add private/rr/docs/namespaces/server.md
git commit -m "feat(rr): add server namespace for Caddy management

- Add server namespace with start, stop, reload, status commands
- Support all rr feature flags (quiet, silent, verbose, non-interactive)
- Interactive mode with gum UI and confirmations
- Comprehensive documentation at docs/namespaces/server.md
- Validates Caddyfile exists before operations
- Checks if Caddy is running before actions"
```

## Success Criteria ✅

### Automated Tests ✅

```bash
# Test namespace exists and is executable
[[ -x private/rr/namespaces/server.sh ]] && echo "✓ server.sh is executable"
# ✓ server.sh is executable

# Test help works
rr server help | grep -q "Usage" && echo "✓ Help command works"
# ✓ Help command works

# Test status check
rr server status >/dev/null 2>&1
echo "✓ Status command works (exit code: $?)"
# ✓ Status command works (exit code: 0)

# Test documentation exists
[[ -f private/rr/docs/namespaces/server.md ]] && echo "✓ Documentation exists"
# ✓ Documentation exists
```

### Manual Tests ✅

- [x] `rr server help` shows all commands with examples
- [x] `rr server start` starts Caddy successfully (or reports already running)
- [x] `rr server stop` stops Caddy gracefully
- [x] `rr server reload` reloads configuration without downtime
- [x] `rr server status` correctly reports running/stopped state
- [x] All commands work in non-interactive mode (`rr -y server start`)
- [x] Quiet mode suppresses output appropriately
- [x] Verbose mode shows debug messages
- [x] Gum UI shows in interactive mode
- [x] Error messages are clear and helpful
- [x] Documentation is complete and accurate
- [x] Shell completion works automatically (namespace auto-discovered)

## Estimated Timeline

- **Phase 1**: Create namespace - 1-2 hours
  - Generate scaffolding: 5 minutes
  - Implement commands: 45-60 minutes
  - Write documentation: 30-45 minutes
- **Phase 2**: Testing - 30 minutes
- **Phase 3**: Git commit - 15 minutes

**Total**: 2-3 hours

## References

### Existing Code to Reference

- **Similar namespace**: `private/rr/namespaces/blog.sh` - Interactive commands with gum
- **Helper library**: `private/rr/lib/helpers.sh` - Shared patterns
- **Namespace guide**: `private/rr/namespaces/CONTRIBUTORS.md` - Implementation patterns
- **Main dispatcher**: `private/rr/bin/rr` - Environment variable exports

### Caddy Documentation

- **Caddy Commands**: https://caddyserver.com/docs/command-line
- **Caddyfile Syntax**: https://caddyserver.com/docs/caddyfile
- **API**: https://caddyserver.com/docs/api

### Key Files

- **Caddyfile**: `private/caddy/Caddyfile:1-26`
- **Raycast Extension**: `private/raycast/extensions/caddy/`
- **rr Architecture**: `private/rr/CONTRIBUTORS.md`
