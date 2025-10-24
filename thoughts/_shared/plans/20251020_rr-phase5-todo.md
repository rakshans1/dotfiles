# Phase 5: Namespace Feature Consistency - Implementation Checklist

**Created**: 2025-10-20
**Status**: Ready to implement
**Estimated Time**: 4-7 hours

## Quick Reference

This document provides a quick checklist for implementing Phase 5. See the main implementation plan for full details.

## High Priority (2-3 hours)

### nix.sh: Add quiet/silent support

All nix commands should respect `RR_QUIET` and `RR_SILENT` flags.

- [x] **profile** - Use `rr_stdout` instead of direct `echo`
  ```bash
  profile)
    debug "Getting current Nix profile"
    profile=$(nix-profile)
    trace "Profile value: $profile"
    rr_stdout "$profile"
    ;;
  ```

- [x] **build** - Wrap with quiet/silent conditionals
  ```bash
  build)
    if [[ "${RR_SILENT}" == "true" ]]; then
      nix-build >/dev/null 2>&1
    elif [[ "${RR_QUIET}" == "true" ]]; then
      nix-build >/dev/null
    else
      nix-build
    fi
    ;;
  ```

- [x] **activate** - Same pattern as build
- [x] **switch** - Add quiet/silent redirects around output
- [x] **update** - Add quiet/silent redirects
- [x] **clean** - Add quiet/silent redirects
- [x] **size** - Add quiet/silent redirects (currently only has JSON)

## Medium Priority (1-2 hours)

### Add verbose/debug output

- [x] **karabiner.sh** - Add debug() and trace() helper functions
  ```bash
  # At top of file, after CMD="${1:-}"
  debug() {
    if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
      echo "[karabiner] $*" >&2
    fi
    return 0
  }

  trace() {
    if [[ "${RR_VERBOSE:-0}" -ge 2 ]]; then
      echo "[TRACE] $*" >&2
    fi
    return 0
  }

  # In build command:
  build)
    debug "Building Karabiner configuration"
    trace "Working directory: $(pwd)"
    # ... existing code
    ;;
  ```

- [x] **git.sh** - Add debug() and trace() helper functions (same pattern)

- [x] **nix.sh** - Add verbose to remaining commands
  - [x] build - Add debug messages
  - [x] activate - Add debug messages
  - [x] update - Add debug messages (currently has gum, needs debug too)
  - [x] clean - Add debug messages (currently has gum, needs debug too)

## Low Priority (1-2 hours)

### JSON output evaluation

- [x] Review which commands would benefit from JSON output
- [x] Candidates:
  - `nix profile` - Could output `{"profile":"mbp","platform":"darwin","arch":"arm64"}` (Not implemented - profile is simple enough without JSON)
  - `nix size` - Already has JSON support
  - Others likely don't need JSON

## Testing Checklist

After implementation, test each command with all flag combinations:

### nix namespace
```bash
# Test quiet mode
rr -q nix profile
rr -q nix build
rr -q nix switch

# Test silent mode
rr -s nix profile
rr -s nix switch

# Test verbose mode
rr -v nix profile
rr -v nix build
rr -vv nix switch

# Test combinations
rr -v -q nix profile  # Verbose but quiet (debug goes to stderr)
```

### karabiner namespace
```bash
rr -v kb build        # Should show debug output
rr -vv kb build       # Should show trace output
rr -s kb build        # Should be silent (already works)
```

### git namespace
```bash
rr -v git branch      # Should show debug output
rr -s git branch      # Should be silent (already works)
```

## Implementation Tips

1. **Start with high priority** - These are core functionality gaps
2. **Test incrementally** - Test each command after implementing
3. **Follow existing patterns** - Look at `nix size` for a complete example
4. **Use helper functions** - `rr_stdout`, `debug()`, `trace()` for consistency
5. **Don't break existing behavior** - All changes should be additive

## Success Criteria

✅ All nix commands respect quiet/silent flags
✅ All namespaces have verbose/debug output
✅ No regressions in existing functionality
✅ Consistent implementation patterns across namespaces

## Implementation Complete!

**Date**: 2025-10-20

All high and medium priority tasks have been implemented and tested:

- ✅ All nix.sh commands support quiet/silent flags
- ✅ karabiner.sh and git.sh have verbose/debug output
- ✅ All commands tested with various flag combinations
- ✅ JSON output working correctly for size command
- ✅ Verbose and trace modes working as expected
