# Consolidate debug() Function to lib/common.sh

## Overview

Currently, every namespace in the `rr` CLI dispatcher defines its own `debug()` function with identical implementation. This plan consolidates the debug functionality into `lib/common.sh` as a generic function that accepts the namespace name as a parameter, eliminating code duplication across 6+ namespace files.

## Current State Analysis

### Debug Function Duplication

The same `debug()` function is defined in every namespace:

- `private/rr/namespaces/obsidian.sh:11-16`
- `private/rr/namespaces/brain.sh:18-23`
- `private/rr/namespaces/blog.sh:18-23`
- `private/rr/namespaces/karabiner.sh:11-16`
- `private/rr/namespaces/git.sh:11-16`
- `private/rr/namespaces/nix.sh:15-20`

### Current Pattern (Repeated 6 Times)

```bash
debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[namespace-name] $*" >&2
  fi
  return 0
}
```

### Existing Common Infrastructure

- `lib/common.sh` - Contains shared `trace()` function (generic, no namespace prefix)
- `lib/helpers.sh` - Contains `rr_namespace_setup()` (creates namespace-specific debug via eval)
- All namespaces already source `lib/common.sh`

## Desired End State

### Single Generic Implementation

`lib/common.sh` will contain both `debug()` and `trace()` functions that accept namespace as first parameter:

```bash
# lib/common.sh
debug() {
  local namespace="$1"
  shift
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[$namespace] $*" >&2
  fi
  return 0
}

trace() {
  local namespace="$1"
  shift
  if [[ "${RR_VERBOSE:-0}" -ge 2 ]]; then
    echo "[$namespace:TRACE] $*" >&2
  fi
  return 0
}
```

### Usage in Namespaces

```bash
# namespaces/nix.sh
debug "nix" "Getting current Nix profile"
trace "nix" "Profile value: $profile"
```

### Verification

- All `rr -v namespace command` calls show debug output with namespace prefix
- All `rr -vv namespace command` calls show trace output with namespace prefix
- No duplicated debug function definitions across namespaces
- Existing functionality preserved

## What We're NOT Doing

- NOT changing the behavior of debug/trace output (same format, just consolidated)
- NOT modifying the main `rr` dispatcher
- NOT changing flag handling (`-v`, `-vv`, etc.)
- NOT removing `rr_namespace_setup()` (keeping it for potential future use)

## Implementation Approach

We'll update `lib/common.sh` to add the generic `debug()` function, then update all 6 namespaces to use it instead of their local implementations. This is a straightforward refactoring with no functional changes.

## Phase 1: Update Library Files

### Overview

Add generic `debug()` and update `trace()` functions in `lib/common.sh`, and update `rr_namespace_setup()` in `lib/helpers.sh` to not create debug functions anymore.

### Changes Required

#### 1. lib/common.sh

**File**: `private/rr/lib/common.sh`
**Changes**: Add generic debug function, update trace function

```bash
#!/usr/bin/env bash
# Common helper functions for all rr namespaces
# This file should be sourced by namespace scripts

# debug() - Verbose output (requires -v flag)
# Usage: debug "namespace" "Debug message"
# Output goes to stderr to avoid interfering with command output
debug() {
  local namespace="$1"
  shift
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[$namespace] $*" >&2
  fi
  return 0
}

# trace() - Extra verbose output (requires -vv flag)
# Usage: trace "namespace" "Context information"
# Output goes to stderr to avoid interfering with command output
trace() {
  local namespace="$1"
  shift
  if [[ "${RR_VERBOSE:-0}" -ge 2 ]]; then
    echo "[$namespace:TRACE] $*" >&2
  fi
  return 0
}
```

#### 2. lib/helpers.sh

**File**: `private/rr/lib/helpers.sh`
**Changes**: Update `rr_namespace_setup()` to not create debug function (lines 247-275)

Replace the existing `rr_namespace_setup()` function implementation:

```bash
# rr_namespace_setup - Set up namespace-specific configuration
#
# Reserved for future namespace setup tasks. Currently does not create
# a debug() function - use the generic debug() from lib/common.sh instead.
#
# Usage:
#   rr_namespace_setup "namespace-name"
#
# Note: debug() and trace() are now provided by lib/common.sh
#   Use: debug "namespace" "message"
#   Use: trace "namespace" "message"
#
# This function is kept for potential future namespace setup needs.
rr_namespace_setup() {
  local namespace="$1"

  if [[ -z "$namespace" ]]; then
    echo "Error: rr_namespace_setup requires namespace name" >&2
    return 1
  fi

  return 0
}
```

### Success Criteria

- [x] `lib/common.sh` contains both `debug()` and `trace()` functions
- [x] Both functions accept namespace as first parameter
- [x] `rr_namespace_setup()` no longer creates debug function
- [x] `rr_namespace_setup()` docstring updated to reflect new behavior
- [x] Both files pass syntax check: `bash -n private/rr/lib/common.sh && bash -n private/rr/lib/helpers.sh`

---

## Phase 2: Update Namespace Files

### Overview

Remove local `debug()` definitions and update all debug/trace calls to pass namespace name.

### Changes Required

#### 1. namespaces/nix.sh

**File**: `private/rr/namespaces/nix.sh`
**Changes**:

- Remove lines 15-20 (debug function definition)
- Update all `debug "message"` calls to `debug "nix" "message"`
- Add trace calls where `trace()` is used

**Lines to Remove:**

```bash
# Helper functions for verbose and debug output
debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[nix] $*" >&2
  fi
  return 0
}
```

**Example Updates:**

```bash
# Before:
debug "Getting current Nix profile"
trace "Profile value: $profile"

# After:
debug "nix" "Getting current Nix profile"
trace "nix" "Profile value: $profile"
```

**Occurrences:**

- Line 61: `debug "Getting current Nix profile"`
- Line 68: `debug "Building Home Manager configuration"`
- Line 79: `debug "Activating Home Manager configuration"`
- Line 90: `debug "Starting Nix Home Manager rebuild"`
- Line 205: `debug "Updating flake inputs"`
- Line 229: `debug "Running Nix garbage collection"`
- Line 267: `debug "Calculating Nix store size"`
- Line 64: `trace "Profile value: $profile"`
- Line 69: `trace "Working directory: $(pwd)"`
- Line 80: `trace "Profile: $(nix-profile)"`
- Line 91: `trace "Profile: $(nix-profile)"`
- Line 206: `trace "Working directory: $(pwd)"`
- Line 230: `trace "Checking store paths"`
- Line 269: `trace "Size calculated: ${size_gb} GB"`

#### 2. namespaces/git.sh

**File**: `private/rr/namespaces/git.sh`
**Changes**:

- Remove lines 11-16 (debug function definition)
- Update debug/trace calls to pass "git" as first parameter

**Lines to Remove:**

```bash
# Helper functions for verbose and debug output
debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[git] $*" >&2
  fi
  return 0
}
```

**Occurrences:**

- Line 37: `debug "Opening fuzzy branch selector"`
- Line 38: `trace "Current repository: $(git rev-parse --show-toplevel 2>/dev/null || echo 'not in a git repo')"`

#### 3. namespaces/karabiner.sh

**File**: `private/rr/namespaces/karabiner.sh`
**Changes**:

- Remove lines 11-16 (debug function definition)
- Update debug/trace calls to pass "karabiner" as first parameter

**Lines to Remove:**

```bash
# Helper functions for verbose and debug output
debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[karabiner] $*" >&2
  fi
  return 0
}
```

**Occurrences:**

- Line 34: `debug "Building Karabiner configuration"`
- Line 35: `trace "Working directory: $(pwd)"`
- Line 44: `debug "Karabiner build complete"`

#### 4. namespaces/obsidian.sh

**File**: `private/rr/namespaces/obsidian.sh`
**Changes**:

- Remove lines 11-16 (debug function definition)
- Update debug/trace calls to pass "obsidian" as first parameter

**Lines to Remove:**

```bash
# Helper functions for verbose and debug output
debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[obsidian] $*" >&2
  fi
  return 0
}
```

**Occurrences:**

- Line 45: `debug "Opening daily journal view"`
- Line 46: `trace "Opening: obsidian://adv-uri?vault=brain&commandid=journals%3A%3Aopen-today's-note"`
- Line 59: `debug "Opening weekly journal view"`
- Line 60: `trace "Opening: obsidian://adv-uri?vault=brain&commandid=journals%3A%3Aopen-weekly-note"`
- Line 73: `debug "Opening monthly journal view"`
- Line 74: `trace "Opening: obsidian://adv-uri?vault=brain&commandid=journals%3A%3Aopen-monthly-note"`
- Line 87: `debug "Opening yearly journal view"`
- Line 88: `trace "Opening: obsidian://adv-uri?vault=brain&commandid=journals%3A%3Aopen-yearly-note"`

#### 5. namespaces/brain.sh

**File**: `private/rr/namespaces/brain.sh`
**Changes**:

- Remove lines 18-23 (debug function definition)
- Update debug/trace calls to pass "brain" as first parameter

**Lines to Remove:**

```bash
# Helper function
debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[brain] $*" >&2
  fi
  return 0
}
```

**Occurrences:**

- Line 56: `debug "Building brain: sync + build"`
- Line 57: `trace "Brain directory: $BRAIN_DIR"`
- Line 84: `debug "Deploying brain: sync + build + publish"`
- Line 85: `trace "Brain directory: $BRAIN_DIR"`

#### 6. namespaces/blog.sh

**File**: `private/rr/namespaces/blog.sh`
**Changes**:

- Remove lines 18-23 (debug function definition)
- Update debug/trace calls to pass "blog" as first parameter

**Lines to Remove:**

```bash
# Helper function
debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[blog] $*" >&2
  fi
  return 0
}
```

**Occurrences:**

- Line 56: `debug "Building blog: sync + build"`
- Line 57: `trace "Blog directory: $BLOG_DIR"`
- Line 84: `debug "Deploying blog: sync + build + publish"`
- Line 85: `trace "Blog directory: $BLOG_DIR"`

### Success Criteria

- [x] No namespace file contains a local `debug()` function definition
- [x] All debug calls use format: `debug "namespace" "message"`
- [x] All trace calls use format: `trace "namespace" "message"`
- [x] All files pass syntax check: `bash -n private/rr/namespaces/*.sh`

---

## Phase 3: Update Documentation

### Overview

Update namespace contributor guide to reflect the new generic debug/trace pattern.

### Changes Required

#### 1. namespaces/CONTRIBUTORS.md

**File**: `private/rr/namespaces/CONTRIBUTORS.md`
**Changes**: Update all template code and examples to use generic debug/trace

**Sections to Update:**

1. **"Creating a New Namespace" → Step 1 template** (around line 60)
   - Remove local debug function from template
   - Show usage: `debug "namespace" "message"`

2. **"Feature Consistency Requirements" → Section 1** (around line 180)
   - Update "Required Helper Functions" section
   - Remove function definition, show usage instead

3. **All implementation pattern examples** (around line 250+)
   - Update Pattern 1, 2, 3, 4 to use `debug "namespace" "message"`

4. **"Quick Reference" → Minimal template** (around line 550)
   - Remove debug function definition from minimal template
   - Show usage pattern

**Example Change:**

```bash
# OLD:
debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[namespace] $*" >&2
  fi
  return 0
}

# NEW:
# Debug/trace functions available from lib/common.sh
# Usage: debug "namespace" "message"
#        trace "namespace" "message"
```

### Success Criteria

- [x] Template code uses `debug "namespace" "message"` pattern
- [x] No template shows local debug function definitions
- [x] Documentation clearly explains the generic debug/trace from lib/common.sh

---

## Phase 4: Testing

### Overview

Verify all namespaces work correctly with verbose flags.

### Test Commands

```bash
# Test each namespace with verbose flags
rr -v nix profile          # Should show: [nix] Getting current Nix profile
rr -vv nix profile         # Should show debug + trace output
rr -v git branch           # Should show: [git] Opening fuzzy branch selector
rr -v karabiner build      # Should show: [karabiner] Building Karabiner configuration
rr -v obsidian daily       # Should show: [obsidian] Opening daily journal view
rr -vv obsidian daily      # Should show debug + trace with URL
rr -v brain build          # Should show: [brain] Building brain: sync + build
rr -v blog build           # Should show: [blog] Building blog: sync + build
```

### Success Criteria

- [x] All `rr -v namespace command` show debug output with correct namespace prefix
- [x] All `rr -vv namespace command` show both debug and trace output
- [x] Trace output includes `[namespace:TRACE]` prefix
- [x] No errors or warnings during execution
- [x] Output format matches previous behavior (only prefix format changes for trace)

---

## References

- Current implementation: `private/rr/namespaces/*.sh`
- Common helpers: `private/rr/lib/common.sh`
- Advanced helpers: `private/rr/lib/helpers.sh` (contains `rr_namespace_setup()`)
- Documentation: `private/rr/namespaces/CONTRIBUTORS.md`
- Main architecture: `private/rr/CONTRIBUTORS.md`

## Migration Notes

### For New Namespaces

New namespace implementations should use the generic debug/trace functions:

```bash
#!/usr/bin/env bash
# namespaces/new.sh - New namespace

CMD="${1:-}"
shift || true

# Source common helpers (provides debug and trace functions)
source "$RR_DIR/lib/common.sh"

# NO LONGER NEEDED:
# debug() { ... }

# Use generic functions directly:
debug "new" "Debug message"
trace "new" "Trace message"
```

### rr_namespace_setup() Behavior

The `rr_namespace_setup()` function still exists but no longer creates a debug() function. It's reserved for potential future namespace setup tasks. Namespaces should source `lib/common.sh` and use the generic debug/trace functions instead.
