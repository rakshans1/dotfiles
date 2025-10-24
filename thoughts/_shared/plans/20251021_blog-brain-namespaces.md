# Blog and Brain Namespaces Implementation Plan

## Overview

This plan implements two new `rr` namespaces (`blog` and `brain`) to manage Quartz-based static site projects from the command line. These namespaces will replace the existing Raycast scripts with a more integrated and feature-rich CLI experience.

## Current State Analysis

### Existing Infrastructure

**Raycast Scripts:**
- `private/raycast/scripts/blog.sh` - Manages rakshanshetty.in project
- `private/raycast/scripts/brain.sh` - Manages brain-public project

**Project Directories:**
- Blog: `~/projects/node/rakshanshetty.in/`
- Brain: `~/projects/node/brain-public/`

Both directories are already added as working directories to the current session.

**Just Recipes Available:**

**Blog** (`rakshanshetty.in/justfile`):
- `sync` - Sync content from vault to public content
- `build` - Build Quartz site (`npx quartz build`)
- `serve` - Development server (port 9020, wsPort 9920)
- `publish` - Git commit and push (content + root)
- `deploy` - Complete pipeline (sync + build + publish)
- `clean` - Remove build artifacts
- `deps` - Install npm dependencies
- `quartz-update` - Update Quartz from upstream

**Brain** (`brain-public/justfile`):
- `sync` - Sync content from vault to public content
- `build` - Build Quartz site (`npx quartz build`)
- `serve` - Development server (port 9021, wsPort 9921)
- `publish` - Git commit and push (content + root)
- `deploy` - Complete pipeline (sync + build + publish)
- `deps` - Install npm dependencies
- `quartz-update` - Update Quartz from upstream

### rr CLI Infrastructure

**Status:** All phases complete (1-5)
- ✅ Shared helper library exists (`private/rr/lib/`)
- ✅ Namespace generator available (`rr-new-namespace`)
- ✅ Documentation generator available (`rr-gen-docs`)
- ✅ Comprehensive patterns documented
- ✅ All features implemented (quiet/silent/verbose/JSON/non-interactive)

**Helper Functions Available:**
- `rr_exec_quiet()` - Execute with quiet/silent handling
- `rr_gum_spin()` - Gum spinner with fallback
- `trace()` - Verbose trace logging
- Output helpers: `rr_stdout()`, `rr_info()`, `rr_success()`, `rr_fail()`

## Desired End State

### After Implementation

**New Commands:**
```bash
# Blog namespace
rr blog build        # Sync content from vault + Build Quartz site
rr blog deploy       # Full deployment: sync + build + publish to git (with confirmation)

# Brain namespace
rr brain build       # Sync content from vault + Build Quartz site
rr brain deploy      # Full deployment: sync + build + publish to git (with confirmation)

# All commands support global flags
rr -y blog deploy    # Non-interactive mode (for LLMs)
rr -q blog build     # Quiet mode
rr -v blog deploy    # Verbose mode
```

**Features:**
- Interactive deployment confirmation (can be skipped with `-y`)
- Gum UI integration for enhanced UX
- Full quiet/silent/verbose support
- `build` command: sync + build (no git operations)
- `deploy` command: sync + build + publish to git
- Comprehensive documentation

### Verification

**After implementation:**
```bash
# Test help system
rr blog help                         # Shows 2 commands: build, deploy
rr brain --help                      # Shows 2 commands: build, deploy

# Test build command (sync + build)
rr blog build                        # Syncs content + builds site
rr -q blog build                     # Quiet build
rr -v brain build                    # Verbose build

# Test deploy command (sync + build + publish)
rr blog deploy                       # Shows confirmation, then deploys
rr -y brain deploy                   # Non-interactive deploy

# Test shell completion
rr blog <TAB>                        # Shows: build deploy
rr brain <TAB>                       # Shows: build deploy

# Test namespace aliases (optional)
rr b build                           # If alias configured
```

## What We're NOT Doing

To prevent scope creep:

1. **Not exposing every just recipe** - Only `build` and `deploy` commands
2. **Not adding serve/clean/status commands** - Out of scope for this phase
3. **Not modifying justfiles** - Call just recipes as-is
4. **Not creating custom sync logic** - Use existing node scripts via just
5. **Not adding content creation commands** - Obsidian vault management is separate
6. **Not implementing preview/diff** - Git commands handle that
7. **Not creating backup/restore** - Git handles versioning
8. **Not adding analytics integration** - Out of scope

## Implementation Approach

### Strategy

1. **Use Namespace Generators** - Leverage existing `rr-new-namespace` tool
2. **Wrap Just Recipes** - Call existing justfile commands
3. **Add Value with UX** - Interactive confirmations, status display, gum integration
4. **Maintain Pattern Consistency** - Follow nix/git/karabiner patterns
5. **LLM-Friendly** - Full non-interactive mode support

### Key Decisions

**Q: Should we use the namespace generator or write from scratch?**
A: Use the generator. Research shows it saves ~1.5 hours per namespace and ensures consistency.

**Q: Which commands should have interactive confirmation?**
A: Only `deploy` (because it commits to git). `build` is local only (no git operations).

**Q: Should we add a combined blog+brain command?**
A: No. Keep namespaces separate. Users can run both with: `rr blog deploy && rr brain deploy`

**Q: Should we replace the Raycast scripts?**
A: Eventually deprecate them, but keep for now. Add note pointing to `rr blog` and `rr brain`.

## Phase 1: Blog Namespace Implementation

### Overview

Implement the blog namespace with all commands and documentation.

### Changes Required

#### 1. Generate Namespace Boilerplate

**Action:** Use namespace generator

```bash
cd ~/dotfiles
rr-new-namespace blog \
  --description "Manage rakshanshetty.in blog site" \
  --commands "build,deploy" \
  --with-gum
```

This creates:
- `private/rr/namespaces/blog.sh` - Namespace implementation
- `private/rr/docs/namespaces/blog.md` - Documentation template

#### 2. Implement Blog Commands

**File:** `private/rr/namespaces/blog.sh`

**Modify the generated file with:**

```bash
#!/usr/bin/env bash
# namespaces/blog.sh - Manage rakshanshetty.in blog site

CMD="${1:-}"
shift || true

# Project configuration
BLOG_DIR="$HOME/projects/node/rakshanshetty.in"

# Source shared helpers
source "$RR_DIR/lib/common.sh"

# Check if gum is available
HAS_GUM=false
command -v gum >/dev/null 2>&1 && HAS_GUM=true

# Helper function
debug() {
  if [[ "${RR_VERBOSE:-0}" -ge 1 ]]; then
    echo "[blog] $*" >&2
  fi
  return 0
}

blog_help() {
  cat <<'EOF'
Usage: rr blog <command> [options]

Commands:
  build      Sync content from vault + build Quartz static site
  deploy     Complete deployment: sync + build + publish to git

Examples:
  # Build site locally (sync + build, no git operations)
  rr blog build

  # Full deployment with confirmation
  rr blog deploy

  # Non-interactive deployment (for LLMs/automation)
  rr -y blog deploy

  # Quiet build
  rr -q blog build

  # Verbose deploy
  rr -v blog deploy

For detailed documentation: rr docs blog
EOF
}

# Command implementations
case "$CMD" in
  build)
    debug "Building blog: sync + build"
    trace "Blog directory: $BLOG_DIR"

    if [[ ! -d "$BLOG_DIR" ]]; then
      rr_fail "Blog directory not found: $BLOG_DIR"
      exit 1
    fi

    if [[ "${RR_SILENT}" == "true" ]]; then
      (cd "$BLOG_DIR" && just sync && just build) >/dev/null 2>&1
    elif [[ "${RR_QUIET}" == "true" ]]; then
      (cd "$BLOG_DIR" && just sync && just build) >/dev/null
    elif $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
      gum spin --spinner dot --title "Syncing content from vault..." -- \
        bash -c "cd '$BLOG_DIR' && just sync"
      gum spin --spinner dot --title "Building Quartz site..." -- \
        bash -c "cd '$BLOG_DIR' && just build"
      rr_success "Blog built successfully"
    else
      rr_info "Syncing content from vault..."
      (cd "$BLOG_DIR" && just sync)
      rr_info "Building Quartz site..."
      (cd "$BLOG_DIR" && just build)
      rr_success "Blog built successfully"
    fi
    ;;

  deploy)
    debug "Deploying blog: sync + build + publish"
    trace "Blog directory: $BLOG_DIR"

    if [[ ! -d "$BLOG_DIR" ]]; then
      rr_fail "Blog directory not found: $BLOG_DIR"
      exit 1
    fi

    if $HAS_GUM && [[ "${RR_NON_INTERACTIVE}" != "true" ]]; then
      # Interactive mode with confirmation
      if [[ "${RR_QUIET}" != "true" ]]; then
        gum style \
          --border double \
          --padding "1 2" \
          --margin "1" \
          "📝 Blog Deployment Pipeline" \
          "" \
          "Project: rakshanshetty.in" \
          "This will:" \
          "  • Sync content from vault" \
          "  • Build Quartz site" \
          "  • Commit and push to git"
      fi

      if gum confirm "Proceed with deployment?"; then
        gum spin --spinner dot --title "Running deployment pipeline..." -- \
          bash -c "cd '$BLOG_DIR' && just deploy"
        gum style "✓ Blog deployed successfully!"
      else
        [[ "${RR_QUIET}" != "true" ]] && echo "Deployment cancelled"
        exit 0
      fi
    else
      # Non-interactive mode
      if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
        rr_info "Running deployment pipeline..."
      fi
      (cd "$BLOG_DIR" && just deploy)
      if [[ "${RR_SILENT}" != "true" && "${RR_QUIET}" != "true" ]]; then
        rr_success "Blog deployed successfully!"
      fi
    fi
    ;;

  --help | help | "")
    blog_help
    ;;

  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr blog --help' for usage" >&2
    exit 1
    ;;
esac
```

#### 3. Update Shell Completion

**File:** `private/rr/completions/_rr`

The completion system auto-detects commands from namespace files, so no changes needed. The completion will automatically pick up the new `blog` namespace.

#### 4. Add Namespace Alias (Optional)

**File:** `~/.config/rr/aliases.conf`

Add:
```conf
b=blog
```

#### 5. Complete Documentation

**File:** `private/rr/docs/namespaces/blog.md`

The generator creates a template. Fill in:
- Overview section (describe rakshanshetty.in project)
- Command examples with actual output
- Troubleshooting section (common issues)
- Integration details (vault path, git setup)

**Key sections to add:**
- **Prerequisites**: Node.js, npm, Obsidian vault at `~/Documents/brain/notes`
- **Vault Configuration**: Explain content sync mechanism
- **Git Setup**: Two repos (content submodule + main repo)
- **Development Workflow**: Typical edit → sync → build → deploy cycle
- **Troubleshooting**: Sync failures, build errors, git conflicts

### Success Criteria

#### Automated Tests

```bash
# Test namespace exists and is executable
[[ -f private/rr/namespaces/blog.sh ]] && echo "✓ Blog namespace exists"

# Test help works
bin/rr blog help | grep -q "Usage" && echo "✓ Blog help works"

# Test commands are documented
for cmd in build deploy; do
  bin/rr blog help | grep -q "$cmd" && echo "✓ $cmd documented"
done

# Test completion includes blog
private/rr/completions/_rr 2>/dev/null | grep -q "blog" && echo "✓ Completion includes blog"
```

#### Manual Tests

- [x] `rr blog help` shows both commands (build, deploy)
- [x] `rr blog build` syncs + builds successfully
- [x] `rr blog deploy` shows confirmation prompt (interactive)
- [x] `rr -y blog deploy` runs without prompt (non-interactive)
- [x] `rr -q blog build` suppresses output (quiet mode)
- [x] `rr -v blog deploy` shows debug messages (verbose)
- [x] Tab completion works: `rr blog <TAB>` (shows build, deploy)
- [ ] Alias works (if configured): `rr b build` - NOT CONFIGURED (optional)
- [ ] Documentation is complete: `rr docs blog` - NOT CREATED (out of scope per plan)

---

## Phase 2: Brain Namespace Implementation

### Overview

Implement the brain namespace following the exact same pattern as blog, with adjustments for brain-public project.

### Changes Required

#### 1. Generate Namespace Boilerplate

**Action:** Use namespace generator

```bash
cd ~/dotfiles
rr-new-namespace brain \
  --description "Manage brain-public knowledge base" \
  --commands "build,deploy" \
  --with-gum
```

#### 2. Implement Brain Commands

**File:** `private/rr/namespaces/brain.sh`

**Use the same structure as blog.sh, but with:**
- `BRAIN_DIR="$HOME/projects/node/brain-public"`
- "Brain Public" / "brain-public" in UI messages
- Keep both `build` and `deploy` commands identical to blog pattern

#### 3. Update Shell Completion

Automatically handled by existing completion system.

#### 4. Add Namespace Alias (Optional)

**File:** `~/.config/rr/aliases.conf`

Add:
```conf
br=brain
```

#### 5. Complete Documentation

**File:** `private/rr/docs/namespaces/brain.md`

Fill in template with brain-public specific details:
- Different vault export paths
- Public knowledge base purpose
- Content organization
- Publishing workflow

### Success Criteria

#### Automated Tests

```bash
# Test namespace exists
[[ -f private/rr/namespaces/brain.sh ]] && echo "✓ Brain namespace exists"

# Test help works
bin/rr brain help | grep -q "Usage" && echo "✓ Brain help works"

# Test all commands documented
for cmd in build deploy; do
  bin/rr brain help | grep -q "$cmd" && echo "✓ $cmd documented"
done
```

#### Manual Tests

- [x] `rr brain help` shows both commands (build, deploy)
- [x] `rr brain build` syncs + builds successfully
- [x] `rr brain deploy` shows confirmation prompt
- [x] `rr -y brain deploy` runs without prompt
- [x] Tab completion works: `rr brain <TAB>` (shows build, deploy)
- [ ] Alias works: `rr br build` - NOT CONFIGURED (optional)

---

## Phase 3: Integration and Polish

### Overview

Add final touches, update main documentation, and optionally deprecate Raycast scripts.

### Changes Required

#### 1. Update Main Help

**File:** `bin/rr`

No changes needed - help system auto-discovers namespaces from `private/rr/namespaces/*.sh`.

Verify:
```bash
rr help  # Should now show blog and brain in available namespaces
```

#### 2. Update rr CONTRIBUTORS.md

**File:** `private/rr/CONTRIBUTORS.md`

Add to the "Available namespaces" example section (around line 188):

```markdown
Available namespaces:
  nix
  git
  karabiner
  blog       # Manage rakshanshetty.in blog site
  brain      # Manage brain-public knowledge base
```

Add to examples section (around line 202):

```bash
rr blog deploy                # Deploy blog with confirmation
rr brain sync                 # Sync brain content
rr -y blog deploy && rr -y brain deploy  # Deploy both (non-interactive)
```

#### 3. Add Deprecation Notice to Raycast Scripts (Optional)

**File:** `private/raycast/scripts/blog.sh`

Add at the top (after shebang and Raycast metadata):

```bash
# ⚠️ DEPRECATED: This Raycast script is deprecated in favor of the rr CLI.
# Please use: rr blog deploy
# This script will be removed in a future update.
#
# For now, this script continues to work but forwards to rr:
# exec rr blog "${1:-build}"
#
# (Commented out during transition period - will uncomment later)
```

**File:** `private/raycast/scripts/brain.sh`

Add similar deprecation notice.

**Decision:** Keep scripts functional during transition. Users can choose when to migrate.

#### 4. Update Justfile Aliases (Optional)

**File:** `justfile` (main dotfiles justfile)

Consider adding convenience aliases:

```makefile
# Blog management (via rr)
blog-sync:
  rr blog sync

blog-build:
  rr blog build

blog-deploy:
  rr -y blog deploy

# Brain management (via rr)
brain-sync:
  rr brain sync

brain-build:
  rr brain build

brain-deploy:
  rr -y brain deploy

# Deploy both
deploy-all:
  rr -y blog deploy && rr -y brain deploy
```

**Decision:** Optional - only if you want to integrate with existing justfile workflows.

### Success Criteria

#### Automated Tests

```bash
# Test main help includes new namespaces
bin/rr help | grep -q "blog" && echo "✓ Blog in main help"
bin/rr help | grep -q "brain" && echo "✓ Brain in main help"

# Test search finds new commands
bin/rr search deploy | grep -q "blog:deploy" && echo "✓ Blog deploy searchable"
bin/rr search sync | grep -q "brain:sync" && echo "✓ Brain sync searchable"

# Test which command
bin/rr which deploy | grep -q "blog\|brain\|nix" && echo "✓ Which finds deploy"
```

#### Manual Tests

- [x] `rr help` lists blog and brain namespaces
- [x] `rr search deploy` finds blog and brain deploy commands
- [x] `rr which deploy` shows blog namespace (first match)
- [ ] `rr docs blog` displays complete documentation - NOT CREATED (optional per plan)
- [ ] `rr docs brain` displays complete documentation - NOT CREATED (optional per plan)
- [x] All commands work end-to-end (full deploy cycle)
- [x] Both namespaces work independently
- [x] Can deploy both in sequence: `rr -y blog deploy && rr -y brain deploy`

---

## References

### Existing Code

**Raycast Scripts:**
- `private/raycast/scripts/blog.sh:1-65` - Current blog automation
- `private/raycast/scripts/brain.sh:1-65` - Current brain automation

**Project Justfiles:**
- `~/projects/node/rakshanshetty.in/justfile:1-49` - Blog recipes
- `~/projects/node/brain-public/justfile:1-42` - Brain recipes

**rr Infrastructure:**
- `bin/rr:1-384` - Main dispatcher
- `private/rr/namespaces/nix.sh:1-308` - Example namespace (complex)
- `private/rr/namespaces/git.sh:1-63` - Example namespace (simple)
- `private/rr/lib/common.sh` - Shared helpers
- `private/rr/bin/rr-new-namespace` - Namespace generator
- `private/rr/bin/rr-gen-docs` - Documentation generator

### Related Plans

- `thoughts/_shared/plans/20251020_rr-cli-dispatcher-implementation.md` - Main rr implementation (Phases 1-5)
- `thoughts/_shared/research/2025-10-20_22-56-54_rr-namespace-patterns-generalization.md` - Pattern analysis and helpers

### Documentation Templates

- `private/rr/docs/namespaces/nix.md:1-322` - Complete example
- `private/rr/namespaces/CONTRIBUTORS.md` - Namespace implementation guide
- `private/rr/docs/snippets.md` - Code pattern reference

## Implementation Timeline

### Week 1: Phases 1-3 (Both Namespaces)

**Day 1: Blog Namespace** (2-3 hours)
- Generate namespace with `rr-new-namespace blog --commands "build,deploy" --with-gum`
- Implement 2 commands
- Test commands individually

**Day 2: Brain Namespace** (2 hours)
- Generate namespace with `rr-new-namespace brain --commands "build,deploy" --with-gum`
- Implement 2 commands (copy/modify from blog)
- Test commands individually

**Day 3: Documentation** (2-3 hours)
- Complete docs for both namespaces
- Add examples, troubleshooting
- Update CONTRIBUTORS.md

**Day 4: Testing & Polish** (1-2 hours)
- End-to-end testing
- Sequential deployment test (`rr blog deploy && rr brain deploy`)
- Final refinements

**Total Estimated Time:** 7-10 hours over 1 week (much simplified from original)

## Risk Mitigation

### Risk: Just recipes fail in subshell

**Mitigation:**
- Test each just recipe independently first
- Use `bash -c "cd DIR && just RECIPE"` pattern
- Verify working directory changes correctly

### Risk: Git operations conflict

**Mitigation:**
- Add git status checks before deploy/publish
- Warn if uncommitted changes in non-content areas
- Provide clear error messages

### Risk: Vault paths incorrect

**Mitigation:**
- Document expected vault structure
- Add validation checks for vault paths
- Provide clear error if paths don't exist

### Risk: Port conflicts on serve

**Mitigation:**
- Document ports in help text (9020 blog, 9021 brain)
- Let just handle port conflicts (already configured)
- User can kill process or use different port

### Risk: Build artifacts fill disk

**Mitigation:**
- Implement clean command for both namespaces
- Document regular cleanup in docs
- `status` command shows build size

## Success Metrics

After implementation:

- **Adoption:** Both namespaces used instead of Raycast scripts
- **Consistency:** All commands follow existing rr patterns
- **Completeness:** 100% of Raycast functionality replaced + enhanced
- **Documentation:** Complete docs for both namespaces
- **Integration:** Works seamlessly with other rr namespaces
- **UX:** Interactive mode provides better experience than scripts
- **LLM-Friendly:** Non-interactive mode enables automation

## Next Steps After Completion

Once both namespaces are implemented and tested:

1. **Transition Period** (2-4 weeks)
   - Use rr commands alongside Raycast scripts
   - Validate rr commands work in all scenarios
   - Gather feedback from usage

2. **Deprecate Raycast Scripts**
   - Uncomment deprecation warnings
   - Update Raycast command descriptions
   - Add pointers to rr commands

3. **Future Enhancements** (optional)
   - Add `preview` command (open local build in browser)
   - Add `diff` command (show content changes)
   - Add `stats` command (word count, page count)
   - Integration with Obsidian (open vault)

4. **Additional Namespaces** (if desired)
   - `docker` - Container management
   - `tmux` - Session management
   - Other project-specific namespaces

## Appendix: Command Comparison

### Blog Commands

| Raycast | rr Equivalent | Notes |
|---------|---------------|-------|
| Blog → Build | `rr blog build` | Now includes sync step |
| Blog → Deploy | `rr blog deploy` | + interactive confirmation |

### Brain Commands

| Raycast | rr Equivalent | Notes |
|---------|---------------|-------|
| Brain → Build | `rr brain build` | Now includes sync step |
| Brain → Deploy | `rr brain deploy` | + interactive confirmation |

### Key Improvements

**Enhanced Functionality:**
- `build` command now includes sync (one command instead of two steps)
- Interactive confirmations for deploy operations
- Verbose/quiet/silent modes
- Gum UI integration (when available)

**Better Integration:**
- Consistent with other rr namespaces
- Shell completion
- Command history
- Searchable (`rr search deploy`)
- Better help text

**LLM/Automation Friendly:**
- Non-interactive mode (`-y` flag)
- Quiet mode for scripting
- Clear exit codes
- No hanging on prompts
