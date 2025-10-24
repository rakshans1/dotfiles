# Obsidian Namespace Implementation Plan for rr CLI

## Overview

Add an `obsidian` namespace to the `rr` CLI dispatcher with alias `o`, implementing commands to open Obsidian journal views (daily, weekly, monthly, yearly). This provides an alternative CLI interface alongside existing Karabiner keyboard shortcuts for better discoverability and consistency with the `rr` CLI philosophy.

## Current State Analysis

### Existing Obsidian Integration in Karabiner

**Location**: `config/karabiner/rules.ts:333-343`

```typescript
n: {
  d: open(
    "'obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-day'",
  ),
  w: open(
    "'obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-week'",
  ),
  m: open(
    "'obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-month'",
  ),
  alone: app("Obsidian"),
},
```

**Current Shortcuts**:
- **Hyper+n+d**: Opens daily journal view using Advanced URI
- **Hyper+n+w**: Opens weekly journal view using Advanced URI
- **Hyper+n+m**: Opens monthly journal view using Advanced URI
- **Hyper+n alone**: Opens Obsidian app

**Advanced URI Plugin**:
- Commands use `obsidian://adv-uri` protocol
- Vault: `brain`
- Commands from the Journals plugin: `journals:journal:calendar:open-{day,week,month}`

### rr CLI Architecture

**Existing Infrastructure** (from `20251020_rr-cli-dispatcher-implementation.md`):
- Main dispatcher: `private/rr/bin/rr` (384 lines)
- 3 existing namespaces: `nix`, `git`, `karabiner`
- Namespace aliasing support via `~/.config/rr/aliases.conf`
- Global flags: `-y` (non-interactive), `-q` (quiet), `-s` (silent), `-v/-vv` (verbose)
- Shell completion for zsh
- Documentation system with `rr docs <namespace>`

**Pattern Library** (from `20251020_rr-namespace-patterns-generalization.md`):
- Shared helpers in `private/rr/lib/common.sh` (trace function)
- Code snippets reference in `private/rr/docs/snippets.md`
- Namespace generator: `private/rr/bin/rr-new-namespace`
- Documentation generator: `private/rr/bin/rr-gen-docs`

## Desired End State

### After Implementation

Users can:
```bash
# Open Obsidian journal views from command line
rr obsidian daily           # Open today's daily note
rr o daily                  # Using alias
rr obsidian weekly          # Open this week's view
rr o weekly                 # Using alias
rr obsidian monthly         # Open this month's view
rr o monthly                # Using alias
rr obsidian yearly          # Open this year's view
rr o yearly                 # Using alias

# Get help
rr obsidian --help          # Show all commands
rr docs obsidian            # View full documentation
```

### Verification

After implementation is complete:
```bash
# Test all commands work
rr obsidian daily           # Should open daily journal view in Obsidian
rr o weekly                 # Should open weekly journal view
rr obsidian monthly         # Should open monthly journal view
rr o yearly                 # Should open yearly journal view

# Test help and docs
rr obsidian --help          # Should list all commands
rr docs obsidian            # Should show formatted documentation

# Test alias completion
rr o<TAB>                   # Should show: obsidian (after new shell)
```

## What We're NOT Doing

To prevent scope creep:

1. **Not implementing note creation** - Only journal navigation commands
2. **Not wrapping all Obsidian operations** - Just journal views (daily, weekly, monthly, yearly)
3. **Not adding search or vault management** - Keep it focused on journal navigation
4. **Not modifying Obsidian settings** - Commands use existing Advanced URI setup
5. **Not changing Karabiner configuration** - Keyboard shortcuts remain unchanged, CLI provides alternative access
6. **Not implementing other Advanced URI commands** - Only the four journal commands

## Implementation Approach

### Strategy

1. **Use namespace generator** - Leverage `rr-new-namespace` to create boilerplate
2. **Follow existing patterns** - Match structure of `git` and `karabiner` namespaces (simple, non-interactive)
3. **Reuse open() utility** - Call the existing `open` command with Advanced URI
4. **Incremental testing** - Test each command individually
5. **Coexist with Karabiner** - CLI commands work alongside existing keyboard shortcuts

### Critical Design Decisions

**Q: Should we implement both monthly and yearly?**
A: Yes, implement all four time ranges: `daily`, `weekly`, `monthly`, `yearly`. Note: Will need to verify if Journals plugin supports `open-year` command ID.

**Q: Interactive or non-interactive commands?**
A: Non-interactive (like `git` and `karabiner` namespaces). These are simple link-opening commands that don't need confirmation.

**Q: Should we wrap in gum UI?**
A: No. Simple commands that just open URLs. Follow the pattern of `git branch` and `karabiner build` - straightforward execution.

**Q: JSON output support?**
A: No. These commands don't return data, they trigger UI actions.

---

## Phase 1: Obsidian Namespace Implementation

### Overview

Create the `obsidian` namespace with four commands (daily, weekly, monthly, yearly), add namespace alias, and optionally generate documentation.

### Changes Required

#### 1. Create Obsidian Namespace Using Generator

**Action**: Use the namespace generator to create boilerplate

```bash
cd ~/dotfiles
private/rr/bin/rr-new-namespace obsidian \
  --description "Obsidian journal navigation" \
  --commands "daily,weekly,monthly,yearly"
```

This will create:
- `private/rr/namespaces/obsidian.sh` - Namespace implementation
- `private/rr/docs/namespaces/obsidian.md` - Documentation template

**Verification**:
```bash
# Check files were created
ls -la private/rr/namespaces/obsidian.sh
ls -la private/rr/docs/namespaces/obsidian.md

# Verify basic structure
rr obsidian --help
```

---

#### 2. Implement Command Logic

**File**: `private/rr/namespaces/obsidian.sh`

**Replace the generated command stubs** with actual implementations:

```bash
#!/usr/bin/env bash
# namespaces/obsidian.sh - Obsidian journal navigation

CMD="${1:-}"
shift || true

# Source shared helpers
if [[ -f "$RR_DIR/lib/common.sh" ]]; then
  source "$RR_DIR/lib/common.sh"
fi

debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[obsidian] $*" >&2
  fi
  return 0
}

obsidian_help() {
  cat <<'EOF'
Usage: rr obsidian <command>

Commands:
  daily      Open today's daily note in Obsidian
  weekly     Open this week's journal view in Obsidian
  monthly    Open this month's journal view in Obsidian
  yearly     Open this year's journal view in Obsidian

Examples:
  rr obsidian daily
  rr o daily             # Using alias
  rr obsidian weekly
  rr o monthly           # Using alias
  rr obsidian yearly

Note: These commands use Obsidian's Advanced URI plugin with the
      Journals plugin to open calendar views.

For detailed documentation: rr docs obsidian
EOF
}

# Command dispatcher
case "$CMD" in
  daily)
    debug "Opening daily journal view"
    trace "Opening: obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-day"

    if [[ "${RR_SILENT}" == "true" ]]; then
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-day" >/dev/null 2>&1
    elif [[ "${RR_QUIET}" == "true" ]]; then
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-day" >/dev/null
    else
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-day"
      echo "✓ Opened daily journal view"
    fi
    ;;

  weekly)
    debug "Opening weekly journal view"
    trace "Opening: obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-week"

    if [[ "${RR_SILENT}" == "true" ]]; then
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-week" >/dev/null 2>&1
    elif [[ "${RR_QUIET}" == "true" ]]; then
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-week" >/dev/null
    else
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-week"
      echo "✓ Opened weekly journal view"
    fi
    ;;

  monthly)
    debug "Opening monthly journal view"
    trace "Opening: obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-month"

    if [[ "${RR_SILENT}" == "true" ]]; then
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-month" >/dev/null 2>&1
    elif [[ "${RR_QUIET}" == "true" ]]; then
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-month" >/dev/null
    else
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-month"
      echo "✓ Opened monthly journal view"
    fi
    ;;

  yearly)
    debug "Opening yearly journal view"
    trace "Opening: obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-year"

    if [[ "${RR_SILENT}" == "true" ]]; then
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-year" >/dev/null 2>&1
    elif [[ "${RR_QUIET}" == "true" ]]; then
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-year" >/dev/null
    else
      open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-year"
      echo "✓ Opened yearly journal view"
    fi
    ;;

  --help | help | "")
    obsidian_help
    ;;

  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr obsidian --help' for usage" >&2
    exit 1
    ;;
esac
```

**Implementation Notes**:
- **Assumption**: The `open` command works on macOS to open `obsidian://` URLs
- **Assumption**: The yearly journal command ID is `journals:journal:calendar:open-year` (not `open-month`) - this needs testing
- **Pattern**: Follows exact same quiet/silent/verbose pattern as `karabiner build` and `git branch`
- **No gum**: Simple commands, no need for spinners or confirmations

**Verification**:
```bash
# Test each command
rr obsidian daily           # Should open daily view
rr obsidian weekly          # Should open weekly view
rr obsidian monthly         # Should open monthly view
rr obsidian yearly          # Should open yearly view (verify command ID)

# Test flags
rr -v obsidian daily        # Should show debug output
rr -q obsidian weekly       # Should suppress success message
rr -s obsidian monthly      # Should be completely silent
```

---

#### 3. Add Namespace Alias

**File**: `~/.config/rr/aliases.conf`

**Action**: Add the `o=obsidian` alias to the existing alias configuration

```bash
# Manually edit ~/.config/rr/aliases.conf
# Add this line:
o=obsidian
```

**Or use this command**:
```bash
echo "o=obsidian" >> ~/.config/rr/aliases.conf
```

**Verification**:
```bash
# Check alias was added
grep "o=obsidian" ~/.config/rr/aliases.conf

# Test alias resolution
rr o daily                  # Should work like: rr obsidian daily
```

---

#### 4. Update Shell Completion

**File**: `private/rr/completions/_rr`

**Action**: The completion script auto-discovers namespaces, but we need to test it picks up the alias

**No code changes needed** - the completion already:
1. Discovers all `*.sh` files in `namespaces/`
2. Reads `~/.config/rr/aliases.conf` for aliases
3. Offers both full names and aliases

**Verification** (requires new zsh session):
```bash
# Start new shell to reload completion
exec zsh

# Test completion
rr <TAB>                    # Should show: git karabiner nix obsidian (and aliases)
rr o<TAB>                   # Should complete to: obsidian
rr obsidian <TAB>           # Should show: daily weekly monthly yearly
```

---

### Success Criteria

#### Automated Tests

```bash
# Test namespace exists
[[ -f private/rr/namespaces/obsidian.sh ]] && echo "✓ Namespace file exists"
[[ -x private/rr/namespaces/obsidian.sh ]] && echo "✓ Namespace is executable"

# Test help works
rr obsidian help | grep -q "Usage" && echo "✓ Help command works"

# Test alias is configured
grep -q "o=obsidian" ~/.config/rr/aliases.conf && echo "✓ Alias is configured"

# Test commands exist in help
rr obsidian help | grep -q "daily" && echo "✓ daily command documented"
rr obsidian help | grep -q "weekly" && echo "✓ weekly command documented"
rr obsidian help | grep -q "monthly" && echo "✓ monthly command documented"
rr obsidian help | grep -q "yearly" && echo "✓ yearly command documented"
```

#### Manual Tests

- [x] `rr obsidian daily` opens daily journal view in Obsidian
- [x] `rr obsidian weekly` opens weekly journal view in Obsidian
- [x] `rr obsidian monthly` opens monthly journal view in Obsidian
- [x] `rr obsidian yearly` opens yearly journal view in Obsidian (verify command ID works)
- [x] `rr o daily` works using alias
- [x] `rr obsidian --help` shows all commands
- [x] `rr -v obsidian daily` shows debug output
- [x] `rr -q obsidian daily` suppresses success message
- [ ] Tab completion works: `rr o<TAB>` suggests `obsidian` (requires new zsh session)
- [ ] Tab completion works: `rr obsidian <TAB>` suggests all commands (requires new zsh session)

---

## References

### Existing Documentation

- **rr Implementation Plan**: `thoughts/_shared/plans/20251020_rr-cli-dispatcher-implementation.md`
- **Namespace Patterns Research**: `thoughts/_shared/research/2025-10-20_22-56-54_rr-namespace-patterns-generalization.md`
- **Namespace Implementation Guide**: `private/rr/namespaces/CONTRIBUTORS.md`

### Code References

- **Main dispatcher**: `bin/rr:1-384`
- **Karabiner rules**: `config/karabiner/rules.ts:333-343`
- **Similar namespace (git)**: `private/rr/namespaces/git.sh:1-63`
- **Similar namespace (karabiner)**: `private/rr/namespaces/karabiner.sh:1-59`
- **Shared helpers**: `private/rr/lib/common.sh`
- **Namespace generator**: `private/rr/bin/rr-new-namespace`
- **Documentation generator**: `private/rr/bin/rr-gen-docs`

### External Resources

- **Advanced URI Plugin**: https://github.com/Vinzent03/obsidian-advanced-uri
- **Obsidian URI Scheme**: https://help.obsidian.md/Advanced+topics/Using+obsidian+URI

---

## Implementation Timeline

### Immediate (15-20 minutes)

**Obsidian Namespace Implementation**
1. Generate namespace boilerplate (2 min)
2. Implement command logic (10 min)
3. Add alias to config (1 min)
4. Test all commands (5 min)

**Total estimated time**: 15-20 minutes

### Testing (5 minutes)

- Run automated tests (2 min)
- Manual testing of all commands (3 min)

---

## Risk Mitigation

### Risk: Wrong URI command ID for yearly

**Likelihood**: Medium
**Impact**: High (command won't work)

**Mitigation**:
- Test `obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-year` manually first
- If it doesn't work, check Obsidian Command Palette for exact command ID
- Journals plugin might only support `open-month` instead of `open-year`

**Contingency**:
```bash
# If yearly doesn't exist, fall back to monthly
# Update obsidian.sh to use:
open "obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-month"
# And rename command from "yearly" to "monthly"
```

---

### Risk: Obsidian not opening on first run

**Likelihood**: Low
**Impact**: Medium (confusing user experience)

**Mitigation**:
- Success message confirms action was attempted
- User can verify Obsidian installation with: `open -a Obsidian`
- Prerequisite: Obsidian must be installed

---

### Risk: Vault name is different

**Likelihood**: Low (current config shows vault=brain)
**Impact**: Medium (commands open wrong vault or fail)

**Mitigation**:
- Vault name visible in URI trace output (with -vv flag)
- Easy to edit: just change `vault=brain` to `vault=<name>` in three places

---


## Success Metrics

After implementation:

**Functionality** (100% required):
- ✅ All four commands (daily, weekly, monthly, yearly) work
- ✅ Alias `o` works for quick access
- ✅ Help is complete
- ✅ Commands work alongside existing Karabiner shortcuts

**Quality** (100% required):
- ✅ Commands respect quiet/silent/verbose flags
- ✅ Error handling works (unknown command shows help)
- ✅ Shell completion works after new session

**Integration** (100% required):
- ✅ Follows existing namespace patterns (git, karabiner)
- ✅ Uses shared helpers (trace function)
- ✅ Works with existing rr architecture

**User Experience** (80% target):
- 🎯 Comparable speed to old keyboard shortcuts
- 🎯 More discoverable via `rr obsidian --help`
- 🎯 Consistent with other rr commands
- 🎯 Easy to remember (`rr o daily` = simple)

---

## Open Questions

**Q: Should the yearly command use `open-year` or `open-month`?**
**A**: User requested `yearly`, so attempt `open-year`. If that command doesn't exist in Journals plugin, fall back to `open-month` and document the limitation. NEEDS TESTING.

**Q: Should we support custom vault names via flag or config?**
**A**: No, not initially. Hardcode `vault=brain` as shown in current Karabiner config. Can add configurability later if requested.

**Q: Should completion after rr obsidian <TAB> work immediately?**
**A**: Yes, but requires a new zsh session (`exec zsh`) to reload completion scripts.

---

## Conclusion

This implementation plan provides a complete specification for:

1. **Adding obsidian namespace** with four commands (daily, weekly, monthly, yearly)
2. **Aliasing to `o`** for quick access
3. **Providing CLI alternative** to existing Karabiner shortcuts (both can coexist)

**Estimated total time**: 15-20 minutes
**Complexity**: Low (follows proven patterns)
**Risk**: Low (easy to revert, doesn't modify core systems)
**Value**: High (discoverability, consistency, CLI-first workflow)

The implementation leverages:
- ✅ Existing namespace generator (`rr-new-namespace`)
- ✅ Proven patterns from git and karabiner namespaces
- ✅ Shared helper library (`trace()` function)

**Next step**: Begin implementation with Phase 1, Step 1 (namespace generation).
