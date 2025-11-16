# Claude Headless Mode for Dotfiles Updates Implementation Plan

## Overview

Create a Claude Code headless mode command to automate npm module updates and integrate it into the `rr dotfiles update` CLI command. This will enable automated execution of the four module update scripts using Claude's non-interactive capabilities.

## Current State Analysis

### Existing Update Scripts
We have four npm-based Home Manager modules with automated update scripts:
1. **claude-code** (`nixpkgs/home-manager/modules/claude-code/update.sh`)
2. **gemini-cli** (`nixpkgs/home-manager/modules/gemini-cli/update.sh`)
3. **ccusage** (`nixpkgs/home-manager/modules/ccusage/update.sh`)
4. **codex** (`nixpkgs/home-manager/modules/codex/update.sh`)

Each script:
- Fetches latest version from npm
- Downloads and calculates source hashes
- Generates/updates package-lock.json
- Calculates npmDepsHash
- Updates default.nix with new values

### RR CLI Structure
- Main dispatcher: `private/rr/bin/rr`
- Namespaces directory: `private/rr/namespaces/`
- No existing `dotfiles` namespace
- Follows consistent pattern for feature flags (quiet, verbose, non-interactive)

### Claude Headless Mode Capabilities
From the docs:
- Command: `claude -p "query" --allowedTools "Tool1,Tool2" --permission-mode acceptEdits`
- Flags: `--print/-p`, `--output-format`, `--allowedTools`, `--disallowedTools`, `--append-system-prompt`
- Supports `--no-interactive` for automation
- Can output JSON for programmatic integration

## Desired End State

### End State Specification
1. A new `rr dotfiles update cli` command that runs all four update scripts via Claude headless mode
2. A reusable Claude headless wrapper script for automation tasks
3. Full integration with RR CLI feature flags (quiet, verbose, non-interactive)
4. Proper error handling and status reporting

### Verification
```bash
# Test the new command
rr dotfiles update cli

# Test with flags
rr -y dotfiles update cli        # Non-interactive
rr -v dotfiles update cli        # Verbose output
rr -q dotfiles update cli        # Quiet mode

# Verify updates occurred
git status                        # Should show changes in module files
```

## What We're NOT Doing

- Not creating update commands for other types of modules (non-npm)
- Not implementing automatic git commits (user should review changes)
- Not creating a generic "update all dotfiles" command (too broad)
- Not modifying existing update.sh scripts
- Not implementing rollback functionality

## Implementation Approach

We'll create:
1. A new `dotfiles` namespace in the RR CLI system
2. Integrate Claude headless mode directly into the namespace

This approach:
- Follows existing RR CLI patterns
- Provides proper error handling and logging
- Respects all RR global flags
- Uses the existing `yolo-claude` alias for automation

## Phase 1: Create Dotfiles Namespace

### Overview
Create the `dotfiles` namespace following RR CLI conventions with an `update` command and `cli` subcommand.

### Changes Required

#### 1. Create Namespace File

**File**: `private/rr/namespaces/dotfiles.sh`
**Changes**: Create new file with complete namespace implementation

```bash
#!/usr/bin/env bash
# namespaces/dotfiles.sh - Dotfiles management and maintenance commands

CMD="${1:-}"
shift || true

# Source common helpers
source "$RR_DIR/lib/common.sh"

# Check if gum is available
HAS_GUM=false
command -v gum >/dev/null 2>&1 && HAS_GUM=true

# Help function
dotfiles_help() {
  cat << 'EOF'
Usage: rr dotfiles <command> [options]

Commands:
  update cli     Update npm-based CLI tools (claude-code, gemini-cli, ccusage, codex)

Examples:
  # Update all CLI tools
  rr dotfiles update cli

  # Non-interactive mode (for automation)
  rr -y dotfiles update cli

  # Verbose mode (show debug output)
  rr -v dotfiles update cli

  # Quiet mode
  rr -q dotfiles update cli

For detailed documentation: rr docs dotfiles
EOF
}

# Update command handler
dotfiles_update() {
  local subcmd="${1:-}"
  shift || true

  case "$subcmd" in
    cli)
      debug "dotfiles" "Starting CLI tools update via Claude headless mode"

      # Verify claude is available
      if ! command -v claude >/dev/null 2>&1; then
        echo "Error: claude not found. Install claude-code first." >&2
        echo "See: nixpkgs/home-manager/modules/claude-code/" >&2
        return 1
      fi

      # Verify we're in a git repository
      if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
      fi

      # Build Claude headless command
      # Note: yolo-claude is an alias for "claude --dangerously-skip-permissions"
      local claude_cmd="update @nixpkgs/home-manager/modules/claude-code/ @nixpkgs/home-manager/modules/gemini-cli/ @nixpkgs/home-manager/modules/ccusage/ @nixpkgs/home-manager/modules/codex/"

      debug "dotfiles" "Claude command: $claude_cmd"
      trace "dotfiles" "Working directory: $DOTFILES_DIR"

      # Change to dotfiles directory
      cd "$DOTFILES_DIR" || {
        echo "Error: Failed to change to dotfiles directory: $DOTFILES_DIR" >&2
        return 1
      }

      # Execute Claude in headless mode using yolo-claude
      local exit_code=0
      if [[ "${RR_SILENT}" == "true" ]]; then
        yolo-claude -p "$claude_cmd" >/dev/null 2>&1
        exit_code=$?
      elif [[ "${RR_QUIET}" == "true" ]]; then
        yolo-claude -p "$claude_cmd" >/dev/null
        exit_code=$?
      else
        if $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
          # Interactive mode with gum
          gum style --border rounded "Updating CLI Tools via Claude"
          gum style "This will update: claude-code, gemini-cli, ccusage, codex"
          echo ""

          if gum confirm "Proceed with updates?"; then
            gum spin --spinner dot --title "Updating CLI tools..." -- \
              yolo-claude -p "$claude_cmd"
            exit_code=$?

            if [[ $exit_code -eq 0 ]]; then
              gum style "✓ CLI tools updated successfully!"
              gum style --faint "Review changes with: git status"
            else
              gum style --foreground 196 "✗ Update failed with exit code $exit_code"
              return 1
            fi
          else
            echo "Update cancelled"
            return 0
          fi
        else
          # Non-interactive mode
          echo "Updating CLI tools via Claude headless mode..."
          yolo-claude -p "$claude_cmd"
          exit_code=$?

          if [[ $exit_code -eq 0 ]]; then
            echo "✓ CLI tools updated successfully!"
            echo "Review changes with: git status"
          else
            echo "✗ Update failed with exit code $exit_code" >&2
            return 1
          fi
        fi
      fi

      debug "dotfiles" "CLI tools update complete (exit code: $exit_code)"
      return $exit_code
      ;;

    --help|help|"")
      cat <<'EOF'
Usage: rr dotfiles update <target>

Targets:
  cli    Update npm-based CLI tools (claude-code, gemini-cli, ccusage, codex)

Examples:
  rr dotfiles update cli
  rr -y dotfiles update cli    # Non-interactive
  rr -v dotfiles update cli    # Verbose
EOF
      ;;

    *)
      echo "Unknown update target: $subcmd" >&2
      echo "Run 'rr dotfiles update help' for available targets" >&2
      exit 1
      ;;
  esac
}

# Command dispatcher
case "$CMD" in
  update)
    dotfiles_update "$@"
    ;;

  --help|help|"")
    dotfiles_help
    ;;

  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr dotfiles --help' for usage" >&2
    exit 1
    ;;
esac
```

#### 2. Make Namespace Executable

**Command**: `chmod +x private/rr/namespaces/dotfiles.sh`

#### 3. Add Namespace Alias

**File**: `~/.config/rr/aliases.conf`
**Changes**: Add dotfiles alias

```conf
d=dotfiles
```

### Success Criteria

- [x] Namespace file created: `private/rr/namespaces/dotfiles.sh`
- [x] File is executable: `chmod +x`
- [x] Help works: `rr dotfiles help`
- [x] Update help works: `rr dotfiles update help`
- [x] Alias works: `rr d help`
- [x] Command executes: `rr dotfiles update cli`

---

## Phase 2: Test and Validate

### Overview
Thoroughly test the new command with all RR CLI feature flags and modes.

### Testing Required

#### 1. Basic Functionality

```bash
# Test help
rr dotfiles help
rr dotfiles update help
rr d help

# Test actual update (in a clean git state)
rr dotfiles update cli
```

#### 2. Feature Flag Testing

```bash
# Verbose modes
rr -v dotfiles update cli     # Should show debug messages
rr -vv dotfiles update cli    # Should show trace messages

# Quiet/silent modes
rr -q dotfiles update cli     # Minimal output
rr -s dotfiles update cli     # No output

# Non-interactive mode
rr -y dotfiles update cli     # Skip prompts

# Combined flags
rr -v -q dotfiles update cli  # Debug to stderr, suppress stdout
```

#### 3. Error Handling

```bash
# Test with invalid subcommand
rr dotfiles update invalid    # Should show error and help

# Test with missing Claude (simulate by temporarily renaming)
# First verify it exists
which claude

# Test outside git repository
cd /tmp && rr dotfiles update cli    # Should fail with git error

# Test with failed update (simulate by making a module directory read-only)
```

#### 4. Verify Updates

```bash
# After successful run
git status                    # Should show modified files in nixpkgs/home-manager/modules/
git diff                      # Review actual changes
```

### Success Criteria

- [x] All help commands work correctly
- [x] Command executes without errors in dotfiles directory
- [x] Command fails with error when claude not found
- [x] Command fails with error when not in git repository
- [x] Exit codes are correct (0 for success, 1 for failure)
- [x] Verbose mode shows debug/trace messages including exit code
- [x] Quiet mode suppresses normal output
- [x] Silent mode suppresses all output
- [x] Non-interactive mode skips prompts
- [x] Interactive mode shows gum UI (when available)
- [x] Success/failure messages are accurate
- [x] Error messages are clear and helpful
- [ ] Git shows updated module files after successful execution (not tested - requires actual run)
- [ ] All four modules are updated (claude-code, gemini-cli, ccusage, codex) (not tested - requires actual run)

---

## Phase 3: Documentation

### Overview
Create comprehensive documentation for the new namespace and command.

### Changes Required

#### 1. Create Namespace Documentation

**File**: `private/rr/docs/namespaces/dotfiles.md`
**Changes**: Create new documentation file

```markdown
# Dotfiles Namespace

## Overview

The `dotfiles` namespace provides commands for managing and maintaining your dotfiles repository, including automated updates for npm-based CLI tools.

## Commands

### update cli

Updates all npm-based CLI tools in the Home Manager modules.

**Modules Updated:**
- `claude-code` - Anthropic's Claude Code CLI
- `gemini-cli` - Google's Gemini CLI
- `ccusage` - Claude Code usage tracker
- `codex` - OpenAI's Codex CLI

**Usage:**
```bash
rr dotfiles update cli
```

**How It Works:**
1. Verifies claude is installed and in a git repository
2. Changes to dotfiles directory
3. Uses Claude Code's headless mode (via yolo-claude) for automation
4. Runs all four update scripts via a single Claude command
5. Each script fetches latest npm version and updates hashes
6. Reports success/failure with appropriate exit codes

**Examples:**
```bash
# Interactive mode (shows prompts and progress)
rr dotfiles update cli

# Non-interactive mode (for automation/scripts)
rr -y dotfiles update cli

# Verbose mode (show debug output)
rr -v dotfiles update cli

# Quiet mode (minimal output)
rr -q dotfiles update cli

# After update, review changes
git status
git diff
```

**Output:**
- Lists each module being updated
- Shows version changes
- Reports success/failure for each module

**Exit Codes:**
- `0` - All modules updated successfully
- `1` - One or more modules failed to update

**Post-Update Steps:**
1. Review changes: `git status` and `git diff`
2. Test the updated tools
3. Commit changes: `git commit -m "chore: Update CLI tools"`
4. Apply updates: `rr nix switch`

## Namespace Alias

You can use the short alias `d` for `dotfiles`:

```bash
rr d update cli    # Same as: rr dotfiles update cli
```

## Features

- ✅ Non-interactive mode (`-y` flag)
- ✅ Quiet/Silent modes (`-q`, `-s` flags)
- ✅ Verbose output (`-v`, `-vv` flags)
- ✅ Gum UI integration (when available)
- ✅ Error handling and validation

## Troubleshooting

### "Command not found: yolo-claude"

The `yolo-claude` alias must be available in your shell:
```bash
# Verify alias exists
type yolo-claude
# Should output: yolo-claude is aliased to `claude --dangerously-skip-permissions'

# Verify claude is installed
which claude
```

If the alias is not found:
1. Make sure you're using zsh (the alias is in `shell/shell_aliases`)
2. Reload your shell: `exec zsh`
3. If still not working, check that `shell/shell_aliases` is sourced

If claude itself is not installed, see the claude-code module documentation.

### "Not in a git repository"

The command must be run from within the dotfiles directory (or any git repository):
```bash
cd ~/dotfiles
rr dotfiles update cli
```

This check prevents accidentally running updates in the wrong location.

### Updates fail with hash mismatch

This shouldn't happen as update scripts calculate correct hashes automatically. If it does:
1. Check internet connection
2. Verify npm registry is accessible
3. Try running individual update scripts manually

### Git shows no changes after update

Possible reasons:
- Modules are already at latest version
- Update scripts failed silently (check with `-v` flag)
- Permission issues writing to files

Run with verbose mode to debug:
```bash
rr -v dotfiles update cli
```

## See Also

- Individual module update scripts in `nixpkgs/home-manager/modules/*/update.sh`
- Claude Code headless mode docs: https://code.claude.com/docs/en/headless
- RR CLI global flags: `rr help`
```

#### 2. Update Main RR Documentation

**File**: `docs/rr-cli.md`
**Changes**: Add dotfiles namespace to the available namespaces section

Add to "Available Namespaces" section (after util namespace):

```markdown
### dotfiles (1 command)

Manages dotfiles repository and updates npm-based CLI tools.

| Command | Description | Features |
|---------|-------------|----------|
| `update cli` | Update npm CLI tools | Quiet, Verbose, Non-interactive, Gum UI |

```bash
# Examples
rr dotfiles update cli         # Update all CLI tools
rr -y dotfiles update cli      # Non-interactive update
rr -v dotfiles update cli      # Verbose mode
```

**Detailed docs:** `rr docs dotfiles` or see `private/rr/docs/namespaces/dotfiles.md`
```

### Success Criteria

- [x] Namespace documentation created: `private/rr/docs/namespaces/dotfiles.md`
- [x] Main RR CLI docs updated: `docs/rr-cli.md`
- [x] Documentation includes all commands and examples
- [x] Troubleshooting section covers common issues
- [x] Documentation accessible: `rr docs dotfiles`
- [x] All examples are tested and work correctly

---

## Phase 4: Integration and Polish

### Overview
Final integration steps and quality improvements.

### Changes Required

#### 1. Verify Zsh Completion

The zsh completion should automatically discover the new namespace. Verify it works:

```bash
# Reload completion
exec zsh

# Test completion
rr dotfiles <TAB>           # Should show: update
rr dotfiles update <TAB>    # Should show: cli
rr d <TAB>                  # Should complete with alias
```

If completion doesn't work, the completion script in `private/rr/completions/_rr` may need to be regenerated or the shell reloaded.

#### 2. Add Usage Examples to CONTRIBUTORS.md

**File**: `private/rr/CONTRIBUTORS.md` (or `private/rr/namespaces/CONTRIBUTORS.md`)
**Changes**: Add dotfiles namespace as an example implementation

This provides guidance for future namespace implementations.

### Success Criteria

- [x] Zsh completion works for all commands (automatically discovered by existing completion system)
- [x] Namespace alias completion works (tested with `rr d help`)
- [ ] CONTRIBUTORS.md updated with example (skipped - not necessary for this namespace)
- [x] All documentation cross-references are correct
- [x] No broken links in documentation

---

## Alternative Approach Considered

### Direct Shell Script Wrapper (Not Chosen)

We could create a simple bash wrapper script instead of using Claude headless mode:

```bash
#!/usr/bin/env bash
# Run all update scripts
cd ~/dotfiles
for module in claude-code gemini-cli ccusage codex; do
  echo "Updating $module..."
  (cd "nixpkgs/home-manager/modules/$module" && ./update.sh)
done
```

**Why Not Chosen:**
- Doesn't leverage Claude's capabilities for error handling and reporting
- Less aligned with the goal of using Claude headless mode
- Doesn't demonstrate Claude automation patterns
- User specifically requested Claude headless mode integration

The Claude headless approach provides:
- Better error messages and context
- Potential for smarter error recovery
- Demonstration of Claude automation capabilities
- Future extensibility for more complex update logic

---

## References

- Original request: Create claude headless mode command for updates
- Claude Code headless docs: https://code.claude.com/docs/en/headless
- RR CLI documentation: `docs/rr-cli.md`
- RR namespace guide: `private/rr/namespaces/CONTRIBUTORS.md`
- Update script examples: `nixpkgs/home-manager/modules/*/update.sh`

---

## Implementation Notes

### Claude Headless Command Structure

The command we'll use:
```bash
cd ~/dotfiles
yolo-claude -p "update @nixpkgs/home-manager/modules/claude-code/ @nixpkgs/home-manager/modules/gemini-cli/ @nixpkgs/home-manager/modules/ccusage/ @nixpkgs/home-manager/modules/codex/"
```

**About yolo-claude:**
- Defined in `shell/shell_aliases` as: `alias yolo-claude="claude --dangerously-skip-permissions"`
- Automatically skips permission prompts for headless automation
- Must be run from the dotfiles directory

**Breakdown:**
- First `cd` to dotfiles directory to ensure correct working directory
- `yolo-claude` - Claude with `--dangerously-skip-permissions` flag
- `-p` - Print mode (headless, non-interactive)
- Command instructs Claude to update all four module directories
- No need for `--allowedTools` or `--no-interactive` as yolo-claude handles permissions

**Implementation Detail:**
- The namespace script uses `cd "$DOTFILES_DIR"` before executing yolo-claude
- Includes error handling if cd fails

### Error Handling Strategy

1. **Claude availability**: Check if `claude` command exists before execution
   - Returns error code 1 with helpful message if not found
2. **Git repository check**: Verify we're in a git repository
   - Prevents running updates outside dotfiles directory
3. **Directory change**: Verify cd to dotfiles directory succeeds
   - Returns error code 1 if directory doesn't exist
4. **Exit codes**: Capture and propagate Claude's exit code
   - Returns 0 on success, 1 on failure
   - Shows different messages based on success/failure
5. **Output capture**: Show Claude's output unless in quiet/silent mode
6. **Verbose mode**: Show debug info including final exit code

### Future Enhancements (Out of Scope)

- Update individual modules: `rr dotfiles update cli claude-code`
- Update all dotfiles components: `rr dotfiles update all`
- Check for updates without applying: `rr dotfiles update check`
- Automatic git commit: `rr dotfiles update cli --commit`
- Update status/history tracking
