---
date: 2025-10-20T22:56:54+05:30
researcher: Rakshan Shetty
git_commit: d8a4b4cd50c4e5d9f0c4b43444f4740c5b3a9749
branch: main
repository: dotfiles
topic: "Common Patterns and Generalization Opportunities in rr CLI Dispatcher"
tags: [research, rr, cli, patterns, automation, templates, implemented]
status: implemented
implementation_date: 2025-10-20
last_updated: 2025-10-20
last_updated_by: Rakshan Shetty
last_updated_note: "All phases implemented - helper library, generators, and documentation"
---

# Research: Common Patterns and Generalization Opportunities in rr CLI Dispatcher

## ✅ Implementation Summary

**Status**: All phases implemented on 2025-10-20

**What was built**:
1. ✅ **Shared Helper Library** (`private/rr/lib/`)
   - `common.sh` - trace() helper (18 lines saved across 3 namespaces)
   - `helpers.sh` - 15 advanced helpers for all common patterns

2. ✅ **Code Snippets Documentation** (`private/rr/docs/snippets.md`)
   - 200+ lines of ready-to-use patterns
   - Examples for all 6 command patterns
   - Gum UI patterns with fallbacks

3. ✅ **Namespace Generator** (`private/rr/bin/rr-new-namespace`)
   - Auto-generates namespace files with all boilerplate
   - Supports --with-gum, --commands, --description flags
   - Automatically calls documentation generator

4. ✅ **Documentation Generator** (`private/rr/bin/rr-gen-docs`)
   - Extracts commands from namespace files
   - Generates complete 8-section documentation template
   - Adds [TODO] markers for custom content

**Impact**: Ready to add 5-10+ namespaces with:
- Consistent patterns across all namespaces
- ~150 lines of boilerplate automated per namespace
- ~1.5 hours saved per namespace (from 2 hours → 30 minutes)
- Zero pattern divergence risk

**Next step**: Add new namespaces with `rr-new-namespace <name>`

---

## Research Question

What common patterns, helpers, and generalization methods can be identified in the `private/rr/` implementation to make it easier to add new namespaces?

## Summary

The rr CLI dispatcher implementation exhibits **extremely high pattern consistency** across all three existing namespaces (nix, git, karabiner), with ~60-70% of code being identical boilerplate. Analysis reveals 10 major extractable patterns.

**Context**: Planning to add many more namespaces in the future (5-10+ expected).

**Key Finding (YAGNI + Future Growth)**: While we only have 3 namespaces now, **investing in the right abstractions early prevents future inconsistency** when scaling to 10+ namespaces.

**Phased Recommendation Based on Growth**:

### Phase 1 (Now - 3 namespaces)
✅ **Create code snippets reference** (1-2 hours)
✅ **Extract `trace()` to shared helper** (30 min) - 100% identical, trivial win

### Phase 2 (At 4-5 namespaces)
🔄 **Create shared helper library** (4-6 hours)
- Extract `rr_exec_quiet()` - Used in every namespace
- Extract `rr_gum_spin()` - Standardize gum usage
- Leave complex patterns (interactive/non-interactive) inline for now

### Phase 3 (At 7-8 namespaces)
🔄 **Add namespace generator** (3-4 hours)
- ROI break-even at this point
- Ensures consistency for new namespaces
- Reduces onboarding time for contributors

### Phase 4 (At 10+ namespaces)
🔄 **Add documentation generator** (2-3 hours)
- Automate the tedious parts
- Maintain consistency across large namespace set

**Rationale**: With growth planned, early investment in shared helpers pays off by preventing divergence. But we do it incrementally, validating each abstraction before the next.

---

## Quick Action Summary

**Immediate Next Steps** (2-3 hours total):

1. ✅ **Create `private/rr/docs/snippets.md`** (1-2 hours)
   - Copy-paste patterns for all common operations
   - Quick reference better than searching CONTRIBUTORS.md
   - Helps maintain consistency across future namespaces

2. ✅ **Extract `trace()` to `private/rr/lib/common.sh`** (30 min)
   - 100% identical across all 3 namespaces
   - Trivial migration, zero downside
   - Sets pattern for future shared helpers
   - Prevents `trace()` divergence in namespaces 4-10

**Later Steps** (triggered by growth):
- 📊 At 4-5 namespaces: Build full helper library
- 📊 At 7-8 namespaces: Create namespace generator
- 📊 At 10+ namespaces: Add documentation generator

**Why This Approach**:
- ✅ Avoids premature optimization
- ✅ Invests strategically for planned growth
- ✅ Validates patterns before automating
- ✅ Low initial cost, high future value

---

## Detailed Findings

### 1. Namespace Boilerplate Patterns (100% Repetition)

#### Pattern 1.1: Common Header Template

**Found in**: All namespace files
- `private/rr/namespaces/git.sh:1-5`
- `private/rr/namespaces/nix.sh:1-5`
- `private/rr/namespaces/karabiner.sh:1-5`

**Code Pattern**:
```bash
#!/usr/bin/env bash
# namespaces/<name>.sh - Brief description

CMD="${1:-}"
shift || true
```

**Analysis**:
- 100% identical across all files
- Only variable: namespace name and description in comment
- Total: 5 lines of identical boilerplate per namespace

**Generalization Opportunity**: Template variable substitution

---

#### Pattern 1.2: debug() Helper Function

**Found in**: All namespace files
- `private/rr/namespaces/git.sh:8-13`
- `private/rr/namespaces/nix.sh:12-17`
- `private/rr/namespaces/karabiner.sh:8-13`

**Code Pattern**:
```bash
debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[<namespace>] $*" >&2
  fi
  return 0
}
```

**Analysis**:
- 100% identical except namespace name in echo statement
- Always returns 0 to allow use in conditionals
- Outputs to stderr
- Total: 6 lines per namespace

**Current Usage**:
- nix.sh: 8 debug() calls across 7 commands
- git.sh: 2 debug() calls
- karabiner.sh: 3 debug() calls

**Generalization Opportunity**: Could be sourced from shared library with namespace name as parameter

---

#### Pattern 1.3: trace() Helper Function

**Found in**: All namespace files (completely identical)
- `private/rr/namespaces/git.sh:15-20`
- `private/rr/namespaces/nix.sh:19-24`
- `private/rr/namespaces/karabiner.sh:15-20`

**Code Pattern**:
```bash
trace() {
  if [[ "${RR_VERBOSE:-0}" -ge 2 ]]; then
    echo "[TRACE] $*" >&2
  fi
  return 0
}
```

**Analysis**:
- 100% identical across all files
- Uses fixed `[TRACE]` prefix (not namespace-specific)
- Total: 6 lines per namespace

**Current Usage**:
- nix.sh: 6 trace() calls with context info (profile, working directory, etc.)
- git.sh: 1 trace() call
- karabiner.sh: 1 trace() call

**Generalization Opportunity**: Perfect candidate for shared library (zero customization needed)

---

#### Pattern 1.4: Help Function Structure

**Found in**: All namespace files
- `private/rr/namespaces/git.sh:22-37`
- `private/rr/namespaces/nix.sh:29-60`
- `private/rr/namespaces/karabiner.sh:22-34`

**Code Pattern**:
```bash
<namespace>_help() {
  cat <<'EOF'
Usage: rr <namespace> <command> [options]

Commands:
  command1    Description of command1
  command2    Description of command2

Examples:
  rr <namespace> command1
  rr <namespace> command2 --option

For detailed documentation: rr docs <namespace>
EOF
}
```

**Analysis**:
- 100% consistent structure across all files
- Uses heredoc with single quotes (`<<'EOF'`)
- Consistent sections: Usage, Commands, Examples, Documentation reference
- Always ends with "For detailed docs: rr docs <namespace>"
- Variable content: number of commands and their descriptions

**Generalization Opportunity**: Template generator with command list as input

---

#### Pattern 1.5: Case Statement Dispatcher Structure

**Found in**: All namespace files
- `private/rr/namespaces/git.sh:39-62`
- `private/rr/namespaces/nix.sh:63-307`
- `private/rr/namespaces/karabiner.sh:36-58`

**Code Pattern**:
```bash
case "$CMD" in
  command1)
    # Command implementation
    ;;
  command2)
    # Command implementation
    ;;
  --help | help | "")
    <namespace>_help
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr <namespace> --help' for usage" >&2
    exit 1
    ;;
esac
```

**Analysis**:
- 100% identical help and error handlers
- Help accepts three forms: `--help`, `help`, empty string
- Unknown command handler always the same (error to stderr, exit 1)
- Only variable: command implementations

**Generalization Opportunity**: Template with command stubs

---

### 2. Quiet/Silent/Verbose Handling Patterns

#### Pattern 2.1: Three-Way Conditional (Simple Command)

**Found in**: 5+ occurrences across namespaces
- `private/rr/namespaces/git.sh:46-52` (git branch)
- `private/rr/namespaces/nix.sh:74-80` (nix build)
- `private/rr/namespaces/nix.sh:85-91` (nix activate)
- `private/rr/namespaces/karabiner.sh:41-47` (karabiner build)

**Code Pattern**:
```bash
if [[ "${RR_SILENT}" == "true" ]]; then
  underlying-command >/dev/null 2>&1
elif [[ "${RR_QUIET}" == "true" ]]; then
  underlying-command >/dev/null
else
  underlying-command
fi
```

**Analysis**:
- Exact same pattern in 5+ locations
- Silent: `>/dev/null 2>&1` (suppress stdout and stderr)
- Quiet: `>/dev/null` (suppress stdout only)
- Normal: No redirection
- Total: 7 lines per usage

**Generalization Opportunity**: Helper function `rr_exec_quiet()`

**Proposed Helper**:
```bash
# In shared library
rr_exec_quiet() {
  local cmd="$*"
  if [[ "${RR_SILENT}" == "true" ]]; then
    eval "$cmd" >/dev/null 2>&1
  elif [[ "${RR_QUIET}" == "true" ]]; then
    eval "$cmd" >/dev/null
  else
    eval "$cmd"
  fi
}

# Usage in namespace
rr_exec_quiet nix-build
```

---

#### Pattern 2.2: Interactive/Non-Interactive Guard

**Found in**: 3 major occurrences in nix.sh
- `private/rr/namespaces/nix.sh:97-206` (switch command)
- `private/rr/namespaces/nix.sh:211-230` (update command)
- `private/rr/namespaces/nix.sh:235-268` (clean command)

**Code Pattern**:
```bash
if $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
  # Interactive mode with gum UI
  if [[ "${RR_QUIET}" != "true" ]]; then
    gum style --border double --padding "1 2" "Message"
  fi

  if gum confirm "Proceed?"; then
    # Execute with quiet/silent handling
    if [[ "${RR_SILENT}" == "true" ]]; then
      command >/dev/null 2>&1
    elif [[ "${RR_QUIET}" == "true" ]]; then
      command >/dev/null
    else
      gum spin --spinner dot --title "Working..." -- command
    fi
  else
    [[ "${RR_QUIET}" != "true" ]] && echo "Cancelled"
    exit 0
  fi
else
  # Non-interactive mode
  if [[ "${RR_SILENT}" == "true" ]]; then
    command >/dev/null 2>&1
  elif [[ "${RR_QUIET}" == "true" ]]; then
    command >/dev/null
  else
    echo "Working..."
    command
    echo "✓ Done!"
  fi
fi
```

**Analysis**:
- Complex pattern with nested conditionals
- Two-level branching: interactive/non-interactive, then quiet/silent/normal
- **Code duplication**: quiet/silent/normal pattern appears in BOTH branches
- Total: ~30-40 lines per usage

**Generalization Opportunity**: Helper function `rr_exec_interactive()`

**Proposed Helper**:
```bash
# In shared library
rr_exec_interactive() {
  local message="$1"
  local command="$2"
  local confirm_prompt="${3:-Proceed?}"

  if $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
    # Interactive mode
    [[ "${RR_QUIET}" != "true" ]] && gum style "$message"

    if gum confirm "$confirm_prompt"; then
      if [[ "${RR_SILENT}" == "true" ]]; then
        eval "$command" >/dev/null 2>&1
      elif [[ "${RR_QUIET}" == "true" ]]; then
        eval "$command" >/dev/null
      else
        gum spin --spinner dot --title "Working..." -- $command
      fi
    else
      [[ "${RR_QUIET}" != "true" ]] && echo "Cancelled"
      exit 0
    fi
  else
    # Non-interactive mode
    rr_exec_quiet "$command"
  fi
}

# Usage in namespace
rr_exec_interactive "About to rebuild Nix configuration" "nix-switch" "Proceed with rebuild?"
```

---

### 3. Gum UI Patterns

#### Pattern 3.1: HAS_GUM Detection

**Found in**: nix.sh only
- `private/rr/namespaces/nix.sh:7-9`

**Code Pattern**:
```bash
# Check if gum is available
HAS_GUM=false
command -v gum >/dev/null 2>&1 && HAS_GUM=true
```

**Analysis**:
- Three lines: comment + initialize false + check and set
- Uses `command -v` (POSIX-compliant)
- Boolean variable for later conditionals
- git.sh and karabiner.sh don't use gum, so omit this

**Generalization Opportunity**: Include in namespace template when gum features are needed

---

#### Pattern 3.2: Gum Confirm with Cancellation

**Found in**: 2 occurrences in nix.sh
- `private/rr/namespaces/nix.sh:115-118`
- `private/rr/namespaces/nix.sh:245-256`

**Code Pattern**:
```bash
if gum confirm "Proceed with rebuild?"; then
  # Execute operation
else
  [[ "${RR_QUIET}" != "true" ]] && echo "Cancelled"
  exit 0
fi
```

**Analysis**:
- Consistent cancellation message (unless quiet)
- Always exits with 0 (user choice, not error)
- Respects quiet mode

**Generalization Opportunity**: Already proposed in `rr_exec_interactive()` helper above

---

#### Pattern 3.3: Gum Spin Usage

**Found in**: Multiple occurrences in nix.sh
- `private/rr/namespaces/nix.sh:174-184` (multiple spins in sequence)
- `private/rr/namespaces/nix.sh:217-218`

**Code Pattern**:
```bash
gum spin --spinner dot --title "Updating flake inputs..." -- nix-update
```

**Or multiple spins:**
```bash
gum spin --spinner dot --title "Updating private flake..." -- \
  nix flake update private

gum spin --spinner dot --title "Switching configuration..." -- \
  home-manager switch --flake ".#$profile"
```

**Analysis**:
- Always uses `--spinner dot`
- Always includes descriptive `--title`
- NO color parameters (theme via environment variables)
- Often followed by success message

**Generalization Opportunity**: Helper for consistent spinner usage

**Proposed Helper**:
```bash
# In shared library
rr_gum_spin() {
  local title="$1"
  shift
  local cmd="$*"

  if $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
    gum spin --spinner dot --title "$title" -- $cmd
  else
    echo "$title"
    eval "$cmd"
  fi
}

# Usage
rr_gum_spin "Updating flake inputs..." nix-update
```

---

### 4. JSON Output Pattern

**Found in**: 1 occurrence (but important pattern)
- `private/rr/namespaces/nix.sh:275-297` (size command)

**Code Pattern**:
```bash
case "${RR_OUTPUT_FORMAT}" in
  json)
    # JSON output - not suppressed by quiet/silent
    echo "{\"size_gb\":${size_gb}}"
    ;;
  *)
    # Default output - respects quiet/silent flags
    if [[ "${RR_SILENT}" == "true" ]]; then
      :  # No output
    elif [[ "${RR_QUIET}" == "true" ]]; then
      echo "${size_gb}"  # Just the value
    elif $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]] && [[ "${RR_VERBOSE:-0}" -eq 0 ]]; then
      gum style --border rounded --padding "0 2" "Nix Store Size: ${size_gb} GB"
    else
      echo "Nix Store Size: ${size_gb} GB"
    fi
    ;;
esac
```

**Analysis**:
- Case statement on `RR_OUTPUT_FORMAT`
- JSON path: No quiet/silent suppression
- Default path: Four-way branch (silent/quiet/gum/plain)
- Silent uses null command `:` instead of empty if

**Generalization Opportunity**: Helper function for formatted output

**Proposed Helper**:
```bash
# In shared library
rr_output_format() {
  local key="$1"
  local value="$2"
  local format_string="${3:-$key: $value}"  # Default format

  case "${RR_OUTPUT_FORMAT}" in
    json)
      echo "{\"$key\":\"$value\"}"
      ;;
    *)
      if [[ "${RR_SILENT}" == "true" ]]; then
        :
      elif [[ "${RR_QUIET}" == "true" ]]; then
        echo "$value"
      else
        echo "$format_string"
      fi
      ;;
  esac
}

# Usage
size=$(nix-size)
rr_output_format "size_gb" "$size" "Nix Store Size: $size GB"
```

---

### 5. Documentation Template (100% Consistent)

#### Documentation Structure Pattern

**Found in**: All namespace documentation files
- `private/rr/docs/namespaces/git.md` (459 lines)
- `private/rr/docs/namespaces/karabiner.md` (331 lines)
- `private/rr/docs/namespaces/nix.md` (322 lines)

**8-Section Template**:
```markdown
# <Namespace> Namespace Documentation

## Overview
[2-3 sentences describing the namespace purpose]

## Commands

### rr <namespace> <command>

**Purpose**: [One-line description]

**Syntax**:
```bash
rr <namespace> <command>
```

**Prerequisites**:
- Requirement 1
- Requirement 2

**Examples**:

Basic usage:
```bash
$ rr <namespace> <command>
[output]
```

**Exit Codes**:
- 0: Success
- 1: Error description

---

## [Integration/Technical Details Section]
[Namespace-specific architecture, features, etc.]

---

## Common Use Cases

### [Use Case Title]

**Goal**: [What user wants to achieve]

[Solution with code examples]

---

## Troubleshooting

### [Problem Title]

**Symptoms**:
```
[error messages or behavior]
```

**Solution**: [Step-by-step fix]

---

## Implementation Details

[Code references with file:line numbers]

---

## See Also

- [External links]
- `command --help` - References
- Related files
```

**Analysis**:
- 100% consistent structure across all three files
- Total: 1,112 lines of documentation
- Consistent formatting conventions:
  - All commands in code blocks
  - File references with `file:line` format
  - Bold for labels: `**Purpose**:`, `**Syntax**:`
  - Horizontal rules (`---`) between sections

**Generalization Opportunity**: Documentation template generator

---

## Code References

### Namespace Files
- `private/rr/namespaces/nix.sh:1-308` - Complete nix namespace (7 commands)
- `private/rr/namespaces/git.sh:1-63` - Complete git namespace (1 command)
- `private/rr/namespaces/karabiner.sh:1-59` - Complete karabiner namespace (1 command)

### Main Dispatcher
- `bin/rr:1-384` - Main dispatcher with global flag parsing
- `bin/rr:76-78` - Sources shell_functions
- `bin/rr:356-371` - Exports environment and helper functions

### Documentation
- `private/rr/docs/namespaces/nix.md:1-322` - Nix namespace docs
- `private/rr/docs/namespaces/git.md:1-459` - Git namespace docs
- `private/rr/docs/namespaces/karabiner.md:1-331` - Karabiner namespace docs

### Architecture Documentation
- `private/rr/CONTRIBUTORS.md:1-799` - Complete rr architecture guide
- `private/rr/namespaces/CONTRIBUTORS.md:1-798` - Namespace implementation guide
- `private/rr/bin/CONTRIBUTORS.md` - Dispatcher guide (symlink to main)

### Existing Research
- `thoughts/_shared/plans/20251020_rr-cli-dispatcher-implementation.md` - Implementation plan (Phases 1-5)
- `thoughts/_shared/plans/20251020_rr-phase5-todo.md` - Phase 5 checklist
- `thoughts/_shared/research/2025-10-20_18-24-56_cli-implementation-opportunities.md` - CLI opportunities analysis
- `thoughts/_shared/research/cli.md` - CLI development reference

---

## Architecture Insights

### 1. Current Boilerplate Burden

**Quantitative Analysis**:
- **Header boilerplate**: 5 lines (shebang, CMD parsing)
- **Helper functions**: 12 lines (debug + trace)
- **Help function**: 10-30 lines (depending on commands)
- **Case structure**: 8 lines (help handler + error handler)
- **Per-command overhead**: 7-40 lines (quiet/silent/verbose handling)

**Total for minimal namespace** (1 command): ~50-70 lines
**Total for complex namespace** (7 commands like nix): ~300 lines

**Code Reuse Analysis**:
- ~35 lines are 100% identical boilerplate
- ~20 lines are 90% identical (only namespace name differs)
- ~50-250 lines are pattern-based (quiet/silent, gum UI)

**Conclusion**: 60-70% of code follows extractable patterns

---

### 2. Pattern Hierarchy

Patterns organized by frequency and impact:

**Tier 1: Universal (100% usage)**
1. Common header (5 lines × 3 files = 15 lines)
2. debug() helper (6 lines × 3 files = 18 lines)
3. trace() helper (6 lines × 3 files = 18 lines)
4. Help function structure (10-30 lines × 3 files = 60-90 lines)
5. Case statement structure (8 lines × 3 files = 24 lines)

**Total Tier 1 boilerplate**: ~135-165 lines across all namespaces

**Tier 2: Common (50-80% usage)**
1. Three-way quiet/silent pattern (7 lines × 5 occurrences = 35 lines)
2. Interactive/non-interactive guard (30-40 lines × 3 occurrences = 90-120 lines)
3. Gum confirm pattern (5 lines × 2 occurrences = 10 lines)

**Total Tier 2 boilerplate**: ~135-165 lines

**Tier 3: Specialized (10-30% usage)**
1. HAS_GUM detection (3 lines × 1 file = 3 lines)
2. Gum spin pattern (1-3 lines × 6 occurrences = 6-18 lines)
3. JSON output pattern (20 lines × 1 occurrence = 20 lines)

**Total Tier 3 boilerplate**: ~29-41 lines

**Grand Total Extractable**: ~299-371 lines of boilerplate (out of ~470 total namespace lines)
**Percentage**: ~64-79% boilerplate

---

### 3. Design Philosophy Analysis

Based on existing implementation and documentation:

**1. Backward Compatibility** (Critical)
- Old commands (e.g., `nix-switch`) continue to work
- New commands (e.g., `rr nix switch`) work identically
- Both call same underlying functions from `shell/shell_functions`
- Zero breaking changes during migration

**2. Feature Consistency** (Current Focus - Phase 5)
- All namespaces implement quiet/silent/verbose modes
- All commands have debug/trace logging
- Interactive commands support non-interactive mode
- Documentation follows identical structure

**3. LLM-Friendly Design** (Core Requirement)
- Non-interactive mode (`-y`, `--yes`, `--non-interactive`)
- Plain text output without fancy styling in non-interactive mode
- Structured output (JSON) where applicable
- Maintains identical functionality across modes

**4. Progressive Enhancement**
- Basic commands work without gum (fallback to plain echo)
- Interactive features enhance UX when available
- Graceful degradation on systems without gum

---

### 4. Integration Points

**With shell_functions**:
- All existing functions sourced and available
- Examples: `nix-profile()`, `nix-switch()`, `karabiner-build()`, `git-branch()`
- 30+ utility functions accessible

**With main dispatcher**:
- Environment variables exported: `RR_DIR`, `DOTFILES_DIR`, flags
- Helper functions exported: `rr_stdout()`, `rr_stderr()`, `rr_info()`, etc.
- Global flag parsing happens before namespace loading

**With external tools**:
- gum: Interactive TUI (confirm, spin, style)
- fzf: Fuzzy finding (git branch selector)
- bat: Syntax highlighting (previews)
- glow: Markdown rendering (documentation)

---

## Recommendations (YAGNI Applied)

### Current Reality Check

**What we have**:
- 3 namespaces (nix, git, karabiner)
- 9 total commands
- Comprehensive template in CONTRIBUTORS.md (lines 332-406)
- System working well, no evidence of pain points

**YAGNI Principle**: Don't build infrastructure until you actually need it. The "Rule of Three" says you can generalize after doing something three times, but only if you're **feeling pain**.

**Are we feeling pain?** No.
- Creating namespaces: Infrequent (3 total over time)
- Maintenance: Easy with only 3 files
- Bugs from inconsistency: None observed
- Template clarity: CONTRIBUTORS.md is comprehensive

---

### ✅ Immediate Action: Create Code Snippets Reference

**Why this makes sense**:
- Low cost (1-2 hours)
- Immediate value (better than searching CONTRIBUTORS.md)
- Just documentation, not infrastructure
- Helps maintain consistency without premature abstraction

**Content**: Quick reference for copy-paste patterns

```markdown
# rr Namespace Code Snippets

Quick reference for common patterns when implementing namespaces.

## Basic Command with Quiet/Silent Support

```bash
command)
  debug "Executing command"

  if [[ "${RR_SILENT}" == "true" ]]; then
    underlying-command >/dev/null 2>&1
  elif [[ "${RR_QUIET}" == "true" ]]; then
    underlying-command >/dev/null
  else
    underlying-command
  fi
  ;;
```

## Interactive Command with Gum

```bash
command)
  debug "Executing interactive command"

  if $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
    # Interactive mode
    if [[ "${RR_QUIET}" != "true" ]]; then
      gum style --border rounded "About to run command"
    fi

    if gum confirm "Proceed?"; then
      gum spin --spinner dot --title "Working..." -- underlying-command
      gum style "✓ Done!"
    else
      [[ "${RR_QUIET}" != "true" ]] && echo "Cancelled"
      exit 0
    fi
  else
    # Non-interactive mode
    if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
      echo "Working..."
    fi
    underlying-command
    if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
      echo "✓ Done!"
    fi
  fi
  ;;
```

## Command with JSON Output

```bash
command)
  debug "Getting value"
  result=$(get-value)
  trace "Result: $result"

  case "${RR_OUTPUT_FORMAT}" in
    json)
      echo "{\"value\":\"$result\"}"
      ;;
    *)
      if [[ "${RR_SILENT}" == "true" ]]; then
        :
      elif [[ "${RR_QUIET}" == "true" ]]; then
        echo "$result"
      else
        echo "Value: $result"
      fi
      ;;
  esac
  ;;
```

[... more patterns ...]
```

**Estimated time**: 1-2 hours
**Value**: High (immediate usability, low cost)

---

### ⏸️ Defer: Automation Tools (Revisit When Needed)

The following tools have been **analyzed but deferred** per YAGNI:

#### 1. Namespace Generator Script

**Why defer**:
- Only created 3 namespaces total
- Frequency is low (infrequent additions)
- CONTRIBUTORS.md template is comprehensive
- Automation complexity > current pain

**When to build**: After creating 7-10 namespaces, or namespace creation becomes frequent

**Estimated ROI**:
- Development: 3-4 hours
- Saves: ~1 hour per namespace
- Break-even: 3-4 new namespaces
- **Not worth it yet** with 3 total

---

#### 2. Shared Helper Library

**Why defer**:
- `rr_exec_quiet()`: Saves 7 lines × 5 uses = 35 lines total
- `rr_exec_interactive()`: Used only in nix.sh (pattern not universal)
- `trace()`: 6 lines, completely identical, but trivial to copy-paste
- Total savings: ~150 lines across 3 files (not significant)

**Concerns**:
- Adds indirection (harder to understand for newcomers)
- eval() in helpers can be tricky to debug
- Pattern still evolving (nix.sh needs complex patterns, git/karabiner don't)
- May constrain future pattern evolution

**When to build**:
- After 5+ namespaces all using same complex patterns
- When pattern bugs require fixes in multiple places
- When patterns are stable and unchanging

**Estimated ROI**:
- Development: 4-6 hours (library + migration + testing)
- Saves: ~50 lines per namespace
- Break-even: 5-6 namespaces after library creation
- **Not worth it yet** with only 3 namespaces

---

#### 3. Documentation Generator

**Why defer**:
- Only 3 documentation files exist
- Documentation is written infrequently
- Template in CONTRIBUTORS.md is clear
- Custom sections (Integration, Use Cases) vary significantly

**When to build**: After 8-10 namespaces, or documentation becomes burdensome

**Estimated ROI**:
- Development: 2-3 hours
- Saves: ~30 minutes per namespace docs
- Break-even: 4-6 new namespaces
- **Not worth it yet**

---

### Decision Framework: When to Revisit Generalization

**Trigger conditions** (any one of these):

1. **Volume**: 5+ namespaces exist
2. **Frequency**: Adding 2+ namespaces per month
3. **Pain**: Inconsistencies causing actual bugs
4. **Time**: Namespace creation taking > 3 hours
5. **Maintenance**: Pattern changes requiring updates across multiple files

**Until then**: Use existing templates in CONTRIBUTORS.md and copy-paste patterns

---

## Pragmatic Roadmap (Accounting for Future Growth)

Given the plan to add many more namespaces, here's a phased approach that balances YAGNI with strategic investment:

### Phase 1: Immediate (Now - 3 namespaces) - 2-3 hours

**Goal**: Low-hanging fruit and documentation

✅ **Priority 1: Create `private/rr/docs/snippets.md`** (1-2 hours)
- Document all common patterns
- Provide copy-paste examples
- Add to CONTRIBUTORS.md references
- **Value**: Immediate - helps maintain consistency when adding namespaces 4-10

✅ **Priority 2: Extract `trace()` helper** (30 min)
- Create `private/rr/lib/common.sh` with just `trace()`
- Update existing 3 namespaces to source it
- **Why now**:
  - 100% identical across all files (zero customization)
  - Trivial to implement and migrate
  - Establishes the pattern for future helpers
  - No downside, pure win

**Implementation**:
```bash
# private/rr/lib/common.sh
#!/usr/bin/env bash
# Common helpers for all rr namespaces

trace() {
  if [[ "${RR_VERBOSE:-0}" -ge 2 ]]; then
    echo "[TRACE] $*" >&2
  fi
  return 0
}
```

**Migration**: Update 3 namespaces to source this file

---

### Phase 2: Early Growth (At 4-5 namespaces) - 4-6 hours

**Trigger**: After adding 1-2 more namespaces

🔄 **Build shared helper library** (`private/rr/lib/helpers.sh`)

**Extract these patterns**:
1. ✅ `rr_exec_quiet()` - Used in every namespace (7 lines → 1 line)
2. ✅ `rr_gum_spin()` - Standardize gum spinner usage
3. ✅ `debug()` generator - Like `trace()`, but needs namespace parameter
4. ⏸️ Skip `rr_exec_interactive()` for now - Only used in nix.sh, pattern may evolve

**Why at 4-5 namespaces**:
- Pattern usage is validated across multiple namespaces
- Savings become meaningful (35+ lines per namespace)
- Early enough to prevent divergence in future namespaces
- Late enough to know patterns are stable

**Migration strategy**:
- Migrate existing 4-5 namespaces in one go
- All future namespaces use helpers from day 1
- Document migration in CONTRIBUTORS.md

---

### Phase 3: Scaling Up (At 7-8 namespaces) - 3-4 hours

**Trigger**: When adding namespaces becomes routine

🔄 **Create namespace generator** (`private/rr/bin/rr-new-namespace`)

**Features**:
- Generate namespace file with helpers pre-sourced
- Generate documentation template
- Add namespace to completions
- Create basic test structure

**Why at 7-8 namespaces**:
- ROI break-even point reached
- Patterns are proven stable
- Onboarding new contributors easier
- Consistency enforcement automated

**Template will include**:
- Header boilerplate
- Helper library sourcing
- debug() setup
- Standard case structure
- Help function template

---

### Phase 4: Mature System (At 10+ namespaces) - 2-3 hours

**Trigger**: Documentation maintenance becomes burdensome

🔄 **Add documentation generator** (`private/rr/bin/rr-gen-docs`)

**Features**:
- Auto-extract commands from namespace file
- Generate complete 8-section template
- Insert [TODO] markers for custom content

**Why at 10+ namespaces**:
- Large enough set that consistency is critical
- Template is well-proven across many namespaces
- Automation saves significant time
- Reduces documentation drift

---

### Decision Gates

**Before each phase, validate**:
1. ✅ **Pattern stability**: Has pattern changed in last 3 namespaces?
2. ✅ **Real pain**: Are we actually experiencing friction?
3. ✅ **ROI positive**: Does time saved > time invested?
4. ✅ **No regrets**: Could we maintain manually if needed?

**Exit criteria (stop automating)**:
- Namespaces become highly specialized (patterns diverge)
- Automation creates more complexity than it saves
- Team prefers copy-paste over abstraction

---

### ROI Calculation with Growth

**Current state**: 3 namespaces (nix, git, karabiner)

**Potential future namespaces** (examples):
- `docker` - Docker container management (ps, exec, logs, restart)
- `tmux` - Tmux session management (ls, attach, new, kill)
- `brew` - Homebrew management (update, cleanup, info)
- `npm` - Node package management (run, test, build)
- `yarn` - Yarn package management
- `ssh` - SSH connection management
- `db` - Database utilities (postgres, mysql connections)
- `k8s` - Kubernetes operations
- `aws` - AWS CLI shortcuts
- `blog` - Blog management (from existing research)

**Growth scenario**: Adding 7 more namespaces = 10 total

**Without helpers** (manual approach):
- Time per namespace: ~2 hours (implementation + docs)
- Boilerplate per namespace: ~150 lines
- Total for 7 new: 14 hours, 1,050 lines boilerplate
- Risk: Pattern divergence across 10 files

**With phased automation**:

**Phase 1 (Now - Snippets + trace helper)**:
- Investment: 2-3 hours
- Benefit: Consistent trace() across all future namespaces
- Per-namespace savings: 15 minutes (faster lookup + no trace divergence)
- Payback: After namespace #4-5

**Phase 2 (At 5 namespaces - Helper library)**:
- Investment: 4-6 hours (one-time)
- Benefit: 50 lines saved per namespace
- Per-namespace savings: 45 minutes
- Payback: After 6-8 namespaces total
- By namespace #10: Saved ~3 hours total

**Phase 3 (At 8 namespaces - Generator)**:
- Investment: 3-4 hours (one-time)
- Benefit: Automated boilerplate generation
- Per-namespace savings: 1 hour
- Payback: After 11-12 namespaces total

**Total ROI by namespace #10**:
- Investment: ~9-13 hours (phases 1-2)
- Time saved: ~8-10 hours (from faster creation)
- Consistency value: Priceless (no divergence across 10 namespaces)
- **Net**: Roughly break-even on time, huge win on consistency

**Key insight**: The real value isn't time savings—it's **preventing inconsistency** across a growing namespace set. With 10 namespaces, manual maintenance risks pattern drift.

---

## Current State Assessment

**What's working well**:
- ✅ CONTRIBUTORS.md has excellent templates
- ✅ Patterns are well-documented and consistent
- ✅ 3 namespaces are maintainable
- ✅ No evidence of bugs from inconsistency
- ✅ Clean, understandable code

**What's NOT a problem yet** (but will be with growth):
- ⚠️ Namespace creation time (acceptable for 3, will add up with 10+)
- ⚠️ Pattern consistency (easy with 3, harder with 10+)
- ⚠️ Maintenance burden (3 files easy, 10+ files harder)
- ⚠️ Onboarding contributors (copy-paste works now, automation helps later)

**Growth Considerations**:
- 📈 Planning to add 5-10+ namespaces
- 🎯 Early investment in `trace()` helper sets pattern
- 🔄 Incremental automation as we grow
- ✅ Validate each abstraction before building the next

**Revised Conclusion**:
- **Now**: Extract trivial wins (`trace()`), create snippets doc
- **Soon (4-5 namespaces)**: Build shared helper library
- **Later (7-8 namespaces)**: Add namespace generator
- **Eventually (10+ namespaces)**: Add documentation generator

Balance YAGNI with strategic investment for planned growth.

---

## Value of This Research

Even though we're **deferring automation**, this pattern analysis provides immediate value:

**1. Documentation Reference**
- Comprehensive catalog of all patterns
- Quick lookup when adding new namespaces
- Understanding of existing implementation choices

**2. Decision Framework**
- Clear triggers for when to generalize
- ROI analysis for each automation option
- Prevents premature optimization

**3. Future Planning**
- Complete specifications ready when needed
- No need to re-analyze patterns later
- Foundation for future improvements

**4. Consistency Awareness**
- Shows what patterns are stable
- Highlights which patterns vary
- Guides copy-paste decisions

---

## Related Research

This research builds on previous work documented in:
- `thoughts/_shared/plans/20251020_rr-cli-dispatcher-implementation.md` - Overall implementation (Phases 1-4 complete)
- `thoughts/_shared/plans/20251020_rr-phase5-todo.md` - Phase 5 feature consistency (current focus)
- `thoughts/_shared/research/2025-10-20_18-24-56_cli-implementation-opportunities.md` - Initial CLI analysis

The patterns identified here provide a foundation for the future, while YAGNI principles keep us focused on what's needed today.
