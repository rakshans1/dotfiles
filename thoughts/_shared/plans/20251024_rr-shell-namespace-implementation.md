# Shell Namespace Implementation Plan

## Overview

Create a new `shell` namespace in the `rr` CLI dispatcher with a single `reload` command that replaces the existing `reload_zsh` alias. This follows the established namespace patterns and provides a cleaner, more discoverable interface for shell environment management.

## Current State Analysis

**Existing Implementation:**
- `reload_zsh` alias defined in `shell/shell_aliases:31`
- Functionality: `source ~/.zshrc && echo 'Shell config reloaded from ~/.zshrc'`
- Works but not discoverable through `rr` system

**rr CLI Architecture:**
- Mature namespace system in `private/rr/`
- Consistent patterns for namespace implementation
- Support for quiet/silent/verbose modes
- Built-in help and discovery features

## Desired End State

After implementation:
- New namespace: `rr shell reload` works identically to current `reload_zsh`
- Old `reload_zsh` alias removed from `shell/shell_aliases`
- Command discoverable via `rr help`, `rr search reload`, etc.
- Full support for all `rr` global flags (quiet, verbose, silent, etc.)

### Verification Steps:
1. `rr shell help` shows available commands
2. `rr shell reload` successfully reloads shell configuration
3. `rr -v shell reload` shows debug output
4. `rr -s shell reload` runs silently
5. `reload_zsh` command no longer exists (removed from aliases)

## What We're NOT Doing

- Not adding gum UI (unnecessary for simple reload command)
- Not adding JSON output (no structured data to return)
- Not adding interactive confirmations (reload is non-destructive)
- Not creating detailed documentation file (can add later if namespace grows)
- Not wrapping other shell commands beyond reload at this time

## Implementation Approach

Follow the minimal namespace pattern from `git.sh`:
- Self-contained command implementation
- Essential feature support only (quiet/silent/verbose)
- Clean help text with examples
- Proper error handling

---

## Phase 1: Create Shell Namespace

### Overview

Create the `shell` namespace file with the `reload` command, following the minimal pattern established in `git.sh` and documented in `private/rr/namespaces/CLAUDE.md`.

### Changes Required:

#### 1. Create namespaces/shell.sh

**File**: `private/rr/namespaces/shell.sh`
**Action**: Create new file

```bash
#!/usr/bin/env bash
# namespaces/shell.sh - Shell environment utilities

CMD="${1:-}"
shift || true

# Source common helpers
source "$RR_DIR/lib/common.sh"

shell_help() {
  cat <<'EOF'
Usage: rr shell <command>

Commands:
  reload     Reload shell configuration (sources ~/.zshrc)

Examples:
  rr shell reload
  rr -v shell reload    # Verbose mode
  rr -s shell reload    # Silent mode

Note: This reloads your shell configuration without starting a new shell session.
EOF
}

case "$CMD" in
reload)
  debug "shell" "Reloading shell configuration"
  trace "shell" "Sourcing ~/.zshrc"

  if [[ "${RR_SILENT}" == "true" ]]; then
    source ~/.zshrc >/dev/null 2>&1
  elif [[ "${RR_QUIET}" == "true" ]]; then
    source ~/.zshrc >/dev/null
  else
    source ~/.zshrc && echo 'Shell config reloaded from ~/.zshrc'
  fi
  ;;
--help | help | "")
  shell_help
  ;;
*)
  echo "Unknown command: $CMD" >&2
  echo "Run 'rr shell --help' for usage" >&2
  exit 1
  ;;
esac
```

**Implementation Notes:**
- Uses `debug()` and `trace()` from `lib/common.sh` for verbose output
- Implements quiet/silent/normal output modes following established pattern
- Simple case statement dispatcher (no gum UI needed)
- Help function follows standard format

### Success Criteria:

- [x] File created at `private/rr/namespaces/shell.sh`
- [x] File is executable: `chmod +x private/rr/namespaces/shell.sh`
- [x] Help works: `rr shell help`
- [x] Help shows with no args: `rr shell`
- [x] Command executes: `rr shell reload`
- [x] Verbose mode works: `rr -v shell reload` (shows debug message)
- [x] Trace mode works: `rr -vv shell reload` (shows trace message)
- [x] Quiet mode works: `rr -q shell reload` (suppresses success message)
- [x] Silent mode works: `rr -s shell reload` (no output at all)
- [x] Error handling: `rr shell invalid` shows error message and exits with code 1
- [x] Command appears in: `rr help` (lists shell namespace)
- [x] Command appears in: `rr search reload`
- [x] Command works with: `rr which reload`

---

## Phase 2: Remove Old Alias

### Overview

Remove the deprecated `reload_zsh` alias from `shell/shell_aliases` now that the functionality is available through the cleaner `rr shell reload` interface.

### Changes Required:

#### 1. Remove reload_zsh from shell/shell_aliases

**File**: `shell/shell_aliases`
**Action**: Delete line 31

**Current line to remove:**
```bash
alias reload_zsh="source ~/.zshrc && echo 'Shell config reloaded from ~/.zshrc'"
```

**Context (lines around it):**
```bash
# Line 30: # zshrc config
# Line 31: alias reload_zsh="source ~/.zshrc && echo 'Shell config reloaded from ~/.zshrc'"  ← DELETE THIS
# Line 32: (blank line)
# Line 33: alias yolo-claude="claude --dangerously-skip-permissions"
```

### Success Criteria:

- [x] Line 31 removed from `shell/shell_aliases`
- [x] File still has valid bash syntax (no syntax errors)
- [x] Section comment "# zshrc config" on line 30 can optionally be removed (no longer needed)
- [x] Other aliases remain intact (lines 1-30, 32-37)
- [x] Shell can still be sourced: `source ~/.zshrc` works without errors
- [x] Old command no longer works: `reload_zsh` returns "command not found" (will work after new shell session)
- [x] New command works: `rr shell reload` successfully reloads shell

---

## Testing Plan

### Manual Testing Sequence

After implementation, run these tests in order:

```bash
# Phase 1 Tests
rr shell help                    # Should show help text
rr shell                         # Should show help text (empty command)
rr shell reload                  # Should reload and show success message
rr -v shell reload               # Should show: [shell] Reloading shell configuration
rr -vv shell reload              # Should show debug + trace messages
rr -q shell reload               # Should reload silently (no success message)
rr -s shell reload               # Should be completely silent
rr shell invalid                 # Should show error message
rr help | grep shell             # Should list shell namespace
rr search reload                 # Should find shell:reload
rr which reload                  # Should show shell namespace

# Phase 2 Tests (after removing alias)
reload_zsh                       # Should fail: command not found
rr shell reload                  # Should still work

# Integration Tests
rr shell reload && echo $PATH    # Environment should be reloaded
type reload_zsh                  # Should show "not found"
type rr                          # Should show function or alias
```

### Expected Outcomes

**Phase 1:**
- All `rr shell` commands work correctly
- Verbose modes show appropriate debug output
- Quiet/silent modes suppress output as expected
- Help and discovery features work

**Phase 2:**
- Old `reload_zsh` command no longer exists
- New `rr shell reload` works identically
- Shell environment reloads successfully
- No regressions in other shell aliases

---

## Migration Notes

### For Users

**Before:**
```bash
reload_zsh    # Old way
```

**After:**
```bash
rr shell reload    # New way
```

**Optional Alias:**
If you want a shorter command, add to `~/.config/rr/aliases.conf`:
```conf
sh=shell
```

Then use: `rr sh reload`

### Backward Compatibility

- **Breaking change**: Yes, `reload_zsh` will be removed
- **Migration path**: Simple - use `rr shell reload` instead
- **Discoverability**: Much better with `rr help`, `rr search`, etc.
- **Impact**: Low - this is a personal dotfiles repo, single user

---

## Future Enhancements

Potential additions to the `shell` namespace (not in this plan):

1. **`rr shell path`** - Show current PATH with formatting
2. **`rr shell env`** - Display key environment variables
3. **`rr shell history`** - Advanced shell history search
4. **`rr shell profile`** - Show which shell profile is active
5. **`rr shell benchmark`** - Time shell startup

These can be added incrementally as namespace documentation is created.

---

## References

- Namespace template: `private/rr/namespaces/git.sh` (minimal example)
- Architecture guide: `private/rr/namespaces/CLAUDE.md`
- Common helpers: `private/rr/lib/common.sh`
- Existing alias: `shell/shell_aliases:31`
- Related implementation: `private/rr/bin/rr` (main dispatcher)
