# RR Util Namespace Implementation Plan

## Overview

Create a new `util` namespace in the rr CLI to consolidate blob JSON parsing and S3 URL utilities. This will replace the existing Raycast scripts (`blob.sh` and `s3url.sh`) with a more flexible, pipeline-friendly implementation that integrates with the rr command ecosystem.

## Current State Analysis

### Existing Raycast Scripts

**`private/raycast/scripts/blob.sh`** (38 lines):
- Takes a JSON string as input argument
- Extracts `region`, `bucket`, and `key` fields using sed
- Handles both quoted and unquoted JSON values
- Outputs formatted JSON to stdout
- Used in Raycast as a script command

**`private/raycast/scripts/s3url.sh`** (26 lines):
- Takes a JSON string as input argument
- Parses JSON using `jq`
- Extracts `bucket` and `key` fields
- Outputs S3 URL format: `s3://bucket/key`
- Used in Raycast as a script command

**Limitations:**
- Takes input as command-line arguments (not pipeline-friendly)
- Raycast-specific (requires user input via Raycast UI)
- No download functionality
- No integration with rr CLI features (quiet, verbose, JSON output, etc.)
- Cannot be easily chained in shell pipelines

### RR CLI Infrastructure

**Dispatcher**: `/Users/rakshan/dotfiles/private/rr/bin/rr`
- Fully implemented with global flag parsing
- Namespace routing with alias support
- Environment variable export for namespaces

**Libraries**:
- `lib/common.sh` - Provides `debug()` and `trace()` functions
- `lib/helpers.sh` - Advanced helpers (not needed for simple utils)

**Existing Namespaces**: 9 namespaces implemented
- Pattern established for simple utility commands
- All implement quiet/silent/verbose support
- Shell completion auto-discovers new namespaces

**Alias Configuration**: `~/.config/rr/aliases.conf`
- Currently has aliases: `n=nix`, `g=git`, `k=karabiner`, `kb=karabiner`
- User can add custom aliases

## Desired End State

### New Commands

Create `rr util` (aliased as `rr u`) namespace with three pipeline-friendly commands:

**Note**: Implementation uses helper function pattern from `nix.sh` for cleaner code organization.

**1. `rr util blob parse`**
- Read JSON string from stdin (pipe-friendly)
- Extract `region`, `bucket`, and `key` fields
- Output as structured JSON
- Replace `blob.sh` functionality

**2. `rr util blob url`**
- Read JSON from stdin
- Extract `bucket` and `key`
- Output S3 URL: `s3://bucket/key`
- Replace `s3url.sh` functionality

**3. `rr util blob download`**
- Read JSON from stdin (expects output from `parse` or has all fields)
- Download file using `aws s3 cp`
- Save to `~/Downloads/` with key as filename (basename)
- Support quiet/verbose modes

### Pipeline Usage

```bash
# Complete workflow: paste from clipboard → parse → get URL
pbpaste | rr util blob parse | rr util blob url

# Complete workflow: paste → parse → download
pbpaste | rr util blob parse | rr util blob download

# All three steps
pbpaste | rr util blob parse | rr util blob url | rr util blob download

# With alias
pbpaste | rr u blob parse | rr u blob url | rr u blob download
```

### Verification Criteria

**Functional:**
- [x] `rr util blob parse` reads from stdin and outputs JSON
- [x] `rr util blob url` reads from stdin and outputs S3 URL
- [x] `rr util blob download` downloads to `~/Downloads/` using key basename
- [x] All commands support piping between each other
- [x] Alias `rr u` works for `rr util`
- [x] Commands work with `pbpaste |` prefix

**Quality:**
- [x] All commands implement quiet/silent/verbose flags
- [x] Help text is comprehensive with examples
- [x] Error handling for invalid JSON, missing fields
- [x] Shell completion discovers new namespace automatically

**Replacement:**
- [x] `blob.sh` can call `rr util blob parse` internally
- [x] Workflow documented for replacing Raycast scripts

## What We're NOT Doing

- Not modifying the main rr dispatcher (auto-discovers namespaces)
- Not implementing interactive/gum UI (utils are simple data processors)
- Not supporting JSON output format flag (commands already output JSON/URLs)
- Not implementing non-interactive flag (no interactive prompts needed)
- Not creating complex blob manipulation commands
- Not integrating with cloud APIs beyond AWS CLI
- Not adding blob validation or schema checking

## Implementation Approach

Use **Pattern 1** (Simple Command) from the namespace patterns:
- No gum UI needed (these are simple data processing utilities)
- Stdin-based input for pipeline compatibility
- Focus on quiet/silent/verbose support
- Error handling for invalid input

Key design decisions:
1. **Stdin over arguments**: Makes commands pipeline-friendly
2. **JSON intermediary**: `parse` outputs JSON that `url` and `download` consume
3. **Basename for download**: Use `$(basename "$key")` for download filename
4. **AWS CLI dependency**: Use `aws s3 cp` (already available in environment)

## Phase 1: Create Util Namespace

### Overview

Create the basic namespace structure with all three blob commands.

### Changes Required

#### 1. Namespace Implementation File

**File**: `private/rr/namespaces/util.sh`
**Changes**: Create new file (~210 lines estimated)

```bash
#!/usr/bin/env bash
# namespaces/util.sh - Utility commands for common data processing tasks

CMD="${1:-}"
shift || true

# Source common helpers
source "$RR_DIR/lib/common.sh"

# Helper functions - self-contained implementations

# Helper: Extract JSON field using jq
__extract_field() {
  local input="$1"
  local field="$2"
  echo "$input" | jq -r ".$field" 2>/dev/null || echo ""
}

# Helper: Validate JSON has required fields
__validate_blob_json() {
  local input="$1"
  local bucket key

  bucket=$(__extract_field "$input" "bucket")
  key=$(__extract_field "$input" "key")

  if [[ -z "$bucket" || -z "$key" || "$bucket" == "null" || "$key" == "null" ]]; then
    return 1
  fi
  return 0
}

# Parse blob JSON from stdin
__util_blob_parse() {
  # Read from stdin
  if [[ -t 0 ]]; then
    echo "Error: No input provided. Pipe JSON input to this command." >&2
    echo "Example: pbpaste | rr util blob parse" >&2
    return 1
  fi

  local input
  input=$(cat)

  # Extract fields using sed (handles both quoted and unquoted values)
  local region bucket key
  region=$(echo "$input" | sed -n 's/.*["\x27]region["\x27][[:space:]]*:[[:space:]]*["\x27]\([^"'\'']*\)["\x27].*/\1/p')
  [ -z "$region" ] && region=$(echo "$input" | sed -n 's/.*["\x27]region["\x27][[:space:]]*:[[:space:]]*\([^,}[:space:]]*\).*/\1/p')

  bucket=$(echo "$input" | sed -n 's/.*["\x27]bucket["\x27][[:space:]]*:[[:space:]]*["\x27]\([^"'\'']*\)["\x27].*/\1/p')
  [ -z "$bucket" ] && bucket=$(echo "$input" | sed -n 's/.*["\x27]bucket["\x27][[:space:]]*:[[:space:]]*\([^,}[:space:]]*\).*/\1/p')

  key=$(echo "$input" | sed -n 's/.*["\x27]key["\x27][[:space:]]*:[[:space:]]*["\x27]\([^"'\'']*\)["\x27].*/\1/p')
  [ -z "$key" ] && key=$(echo "$input" | sed -n 's/.*["\x27]key["\x27][[:space:]]*:[[:space:]]*\([^,}[:space:]]*\).*/\1/p')

  # Validate extraction
  if [[ -z "$bucket" || -z "$key" ]]; then
    echo "Error: Could not extract bucket and key from input" >&2
    return 1
  fi

  # Output JSON
  echo "{"
  echo "  \"region\": \"$region\","
  echo "  \"bucket\": \"$bucket\","
  echo "  \"key\": \"$key\""
  echo "}"
}

# Convert blob JSON to S3 URL
__util_blob_url() {
  # Read from stdin
  if [[ -t 0 ]]; then
    echo "Error: No input provided. Pipe JSON input to this command." >&2
    echo "Example: rr util blob parse | rr util blob url" >&2
    return 1
  fi

  local input
  input=$(cat)

  # Validate input
  if ! __validate_blob_json "$input"; then
    echo "Error: Invalid JSON input. Missing bucket or key fields." >&2
    return 1
  fi

  # Extract fields using jq
  local bucket key
  bucket=$(__extract_field "$input" "bucket")
  key=$(__extract_field "$input" "key")

  # Output S3 URL
  echo "s3://$bucket/$key"
}

# Download blob to ~/Downloads/
__util_blob_download() {
  # Read from stdin
  if [[ -t 0 ]]; then
    echo "Error: No input provided. Pipe JSON input to this command." >&2
    echo "Example: rr util blob parse | rr util blob download" >&2
    return 1
  fi

  local input
  input=$(cat)

  local s3_url filename
  # Check if input is JSON or S3 URL
  if [[ "$input" =~ ^s3:// ]]; then
    # Input is S3 URL
    s3_url="$input"
    # Extract filename from URL
    filename=$(basename "$(echo "$s3_url" | sed 's|s3://[^/]*/||')")
  else
    # Input is JSON - extract bucket and key
    if ! __validate_blob_json "$input"; then
      echo "Error: Invalid JSON input. Missing bucket or key fields." >&2
      return 1
    fi

    local bucket key
    bucket=$(__extract_field "$input" "bucket")
    key=$(__extract_field "$input" "key")
    s3_url="s3://$bucket/$key"
    filename=$(basename "$key")
  fi

  # Validate AWS CLI is available
  if ! command -v aws >/dev/null 2>&1; then
    echo "Error: AWS CLI is not installed or not in PATH" >&2
    return 1
  fi

  local download_path
  download_path="$HOME/Downloads/$filename"

  # Download file
  aws s3 cp "$s3_url" "$download_path"
  echo "✓ Downloaded to: $download_path"
}

# Help function
util_help() {
  cat <<'EOF'
Usage: rr util <command> [options]

Commands:
  blob parse      Parse blob JSON from stdin, extract region/bucket/key
  blob url        Convert blob JSON to S3 URL (s3://bucket/key)
  blob download   Download blob to ~/Downloads/ using AWS CLI

Examples:
  # Parse blob JSON from clipboard
  pbpaste | rr util blob parse

  # Get S3 URL from blob
  pbpaste | rr util blob parse | rr util blob url

  # Download blob to ~/Downloads/
  pbpaste | rr util blob parse | rr util blob download

  # Complete pipeline
  pbpaste | rr util blob parse | rr util blob url | rr util blob download

  # Using alias
  pbpaste | rr u blob parse | rr u blob url

  # With verbose mode
  pbpaste | rr -v util blob parse

For detailed documentation: rr docs util
EOF
}

# Command dispatcher
case "$CMD" in
  blob)
    # Sub-command for blob operations
    SUBCMD="${1:-}"
    shift || true

    case "$SUBCMD" in
      parse)
        debug "util" "Parsing blob JSON from stdin"
        if [[ "${RR_SILENT}" == "true" ]]; then
          __util_blob_parse >/dev/null 2>&1
        elif [[ "${RR_QUIET}" == "true" ]]; then
          __util_blob_parse >/dev/null
        else
          __util_blob_parse
        fi
        ;;

      url)
        debug "util" "Converting blob JSON to S3 URL"
        if [[ "${RR_SILENT}" == "true" ]]; then
          __util_blob_url >/dev/null 2>&1
        elif [[ "${RR_QUIET}" == "true" ]]; then
          __util_blob_url >/dev/null
        else
          __util_blob_url
        fi
        ;;

      download)
        debug "util" "Downloading blob to ~/Downloads/"
        if [[ "${RR_SILENT}" == "true" ]]; then
          __util_blob_download >/dev/null 2>&1
        elif [[ "${RR_QUIET}" == "true" ]]; then
          __util_blob_download >/dev/null
        else
          __util_blob_download
        fi
        ;;

      --help|help|"")
        cat <<'EOF'
Usage: rr util blob <command>

Commands:
  parse      Parse blob JSON from stdin (extract region/bucket/key)
  url        Convert blob JSON to S3 URL (s3://bucket/key)
  download   Download blob to ~/Downloads/ using AWS CLI

Examples:
  pbpaste | rr util blob parse
  pbpaste | rr util blob parse | rr util blob url
  pbpaste | rr util blob parse | rr util blob download

Pipeline workflow:
  pbpaste | rr util blob parse | rr util blob url | rr util blob download
EOF
        ;;

      *)
        echo "Unknown blob command: $SUBCMD" >&2
        echo "Run 'rr util blob help' for usage" >&2
        exit 1
        ;;
    esac
    ;;

  --help|help|"")
    util_help
    ;;

  *)
    echo "Unknown command: $CMD" >&2
    echo "Run 'rr util --help' for usage" >&2
    exit 1
    ;;
esac
```

**Reasoning:**
- Uses helper function pattern from `nix.sh` for cleaner code organization
- Helper functions (`__util_blob_parse`, `__util_blob_url`, `__util_blob_download`) contain all logic
- Case statement just calls helpers with appropriate quiet/silent/verbose wrapping
- Stdin-based input for pipeline compatibility
- Uses existing sed patterns from blob.sh for parsing
- Uses jq for JSON validation and extraction
- Downloads to `~/Downloads/` with basename of key
- Implements quiet/silent/verbose support consistently in dispatcher
- Sub-command structure: `blob` with `parse`, `url`, `download`

#### 2. Namespace Alias Configuration

**File**: `~/.config/rr/aliases.conf`
**Changes**: Add alias for util namespace

```conf
# Namespace aliases
# Format: alias=full-namespace

n=nix
g=git
k=karabiner
kb=karabiner
u=util
```

**Reasoning:**
- Follows existing alias pattern
- Short alias `u` is intuitive and not yet used
- Allows `rr u blob parse` instead of `rr util blob parse`

### Success Criteria

- [x] File `private/rr/namespaces/util.sh` created with ~210 lines
- [x] File is executable: `chmod +x private/rr/namespaces/util.sh`
- [x] Alias `u=util` added to `~/.config/rr/aliases.conf`
- [x] Commands work independently:
  - `echo '{"bucket":"test","key":"path/file.txt"}' | rr util blob parse`
  - `echo '{"bucket":"test","key":"path/file.txt"}' | rr util blob url`
- [x] Pipeline works: `echo '{"bucket":"test","key":"path/file.txt"}' | rr util blob parse | rr util blob url`
- [x] Alias works: `rr u --help` shows help
- [x] Verbose mode works: `echo '{}' | rr -v util blob parse` shows debug output
- [x] Quiet mode works: `rr -q util blob parse` suppresses output appropriately
- [x] Error handling works: `rr util blob parse` (no stdin) shows error
- [x] Help works: `rr util help`, `rr util blob help`
- [x] Shell completion discovers new namespace (after `exec zsh`)

---

## Phase 2: Update Raycast Scripts to Use RR

### Overview

Replace the implementation of `blob.sh` to call `rr util blob parse` internally, allowing Raycast users to benefit from the improved implementation while maintaining the Raycast script interface.

### Changes Required

#### 1. Update blob.sh Script

**File**: `private/raycast/scripts/blob.sh`
**Changes**: Replace implementation to use `rr util blob parse`

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title blob
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 📑
# @raycast.argument1 { "type": "text", "placeholder": "String" }
# @raycast.packageName Blob

# Documentation:
# @raycast.description Blob extracter
# @raycast.author rakshan
# @raycast.authorURL https://raycast.com/rakshan

input="$1"

# Use rr util blob parse
echo "$input" | rr util blob parse
```

**Reasoning:**
- Maintains Raycast script interface (takes argument, outputs JSON)
- Delegates to `rr util blob parse` for actual implementation
- Reduces code duplication
- Benefits from any improvements to rr util
- Still works in Raycast UI

#### 2. Document s3url.sh Replacement (Optional)

**File**: `private/raycast/scripts/s3url.sh`
**Changes**: Update to use `rr util blob url`

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title s3url
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🪣
# @raycast.argument1 { "type": "text", "placeholder": "JSON String" }
# @raycast.packageName S3 URL

# Documentation:
# @raycast.description Extracts S3 URL from blob JSON
# @raycast.author rakshan
# @raycast.authorURL https://raycast.com/rakshan

input="$1"

# Use rr util blob url
echo "$input" | rr util blob url
```

**Reasoning:**
- Same benefits as blob.sh replacement
- Maintains backward compatibility with Raycast

### Success Criteria

- [x] `blob.sh` updated to call `rr util blob parse`
- [x] Raycast script still works when invoked from Raycast
- [x] Output format remains identical (formatted JSON)
- [x] No breaking changes to existing Raycast workflows
- [x] (Optional) `s3url.sh` updated to call `rr util blob url`

---

## Testing Plan

### Unit Testing (Per Command)

**Test `rr util blob parse`:**
```bash
# Valid JSON input
echo '{"region":"us-east-1","bucket":"my-bucket","key":"path/to/file.txt"}' | rr util blob parse

# Input with unquoted values
echo '{region:us-east-1,bucket:my-bucket,key:path/to/file.txt}' | rr util blob parse

# Input from clipboard
pbpaste | rr util blob parse

# No stdin (should error)
rr util blob parse

# Verbose mode
echo '{"bucket":"test","key":"file.txt"}' | rr -v util blob parse

# Silent mode
echo '{"bucket":"test","key":"file.txt"}' | rr -s util blob parse
```

**Test `rr util blob url`:**
```bash
# Valid JSON input
echo '{"bucket":"my-bucket","key":"path/to/file.txt"}' | rr util blob url

# From parse output
echo '{"region":"us-east-1","bucket":"my-bucket","key":"path/to/file.txt"}' | rr util blob parse | rr util blob url

# Invalid JSON (should error)
echo '{"bucket":"test"}' | rr util blob url

# No stdin (should error)
rr util blob url

# Verbose mode
echo '{"bucket":"test","key":"file.txt"}' | rr -v util blob url
```

**Test `rr util blob download`:**
```bash
# From JSON input (dry-run test without actual S3)
echo '{"bucket":"my-bucket","key":"path/to/file.txt"}' | rr util blob download

# From S3 URL input
echo 's3://my-bucket/path/to/file.txt' | rr util blob download

# From parse pipeline
echo '{"bucket":"my-bucket","key":"path/to/file.txt"}' | rr util blob parse | rr util blob download

# No stdin (should error)
rr util blob download

# Without AWS CLI (should error gracefully)
PATH="" rr util blob download
```

### Integration Testing (Pipelines)

```bash
# Parse → URL
pbpaste | rr util blob parse | rr util blob url

# Parse → Download
pbpaste | rr util blob parse | rr util blob download

# Parse → URL → Download
pbpaste | rr util blob parse | rr util blob url | rr util blob download

# Using alias
pbpaste | rr u blob parse | rr u blob url

# With verbose
pbpaste | rr -v util blob parse | rr util blob url
```

### Feature Flag Testing

```bash
# Quiet mode
echo '{"bucket":"test","key":"file.txt"}' | rr -q util blob parse

# Silent mode
echo '{"bucket":"test","key":"file.txt"}' | rr -s util blob parse

# Verbose mode
echo '{"bucket":"test","key":"file.txt"}' | rr -v util blob parse

# Extra verbose
echo '{"bucket":"test","key":"file.txt"}' | rr -vv util blob parse

# Combined flags
echo '{"bucket":"test","key":"file.txt"}' | rr -v -q util blob parse
```

### Raycast Integration Testing

```bash
# Test blob.sh directly
bash private/raycast/scripts/blob.sh '{"bucket":"test","key":"file.txt"}'

# Test s3url.sh directly
bash private/raycast/scripts/s3url.sh '{"bucket":"test","key":"file.txt"}'

# Test in Raycast UI (manual)
# 1. Open Raycast
# 2. Run "blob" command
# 3. Enter test JSON
# 4. Verify output
```

### Regression Testing

```bash
# Verify existing namespaces still work
rr nix profile
rr karabiner build
rr git branch

# Verify help still works
rr help
rr util help

# Verify history tracking
rr history | grep util

# Verify completion
rr u<TAB>  # Should complete to "util"
rr util <TAB>  # Should show "blob"
```

---

## Rollback Plan

If issues are discovered:

1. **Remove namespace file:**
   ```bash
   rm private/rr/namespaces/util.sh
   ```

2. **Remove alias from config:**
   ```bash
   # Edit ~/.config/rr/aliases.conf
   # Remove line: u=util
   ```

3. **Revert Raycast scripts:**
   ```bash
   git checkout private/raycast/scripts/blob.sh
   git checkout private/raycast/scripts/s3url.sh
   ```

4. **Reload shell:**
   ```bash
   exec zsh
   ```

The rr dispatcher will continue to work normally as it only loads namespaces that exist.

---

## Future Enhancements

Potential additions (not in scope for this plan):

1. **Additional blob commands:**
   - `rr util blob list` - List all files in bucket
   - `rr util blob info` - Get metadata about S3 object
   - `rr util blob upload` - Upload file to S3

2. **JSON utilities:**
   - `rr util json format` - Pretty-print JSON
   - `rr util json minify` - Minify JSON
   - `rr util json query` - JQ wrapper

3. **Encoding utilities:**
   - `rr util base64 encode/decode`
   - `rr util url encode/decode`
   - `rr util hex encode/decode`

4. **Text processing:**
   - `rr util text upper/lower/title`
   - `rr util text trim`
   - `rr util text replace`

---

## References

### Original Scripts
- Original blob.sh: `private/raycast/scripts/blob.sh`
- Original s3url.sh: `private/raycast/scripts/s3url.sh`

### RR Implementation
- Main dispatcher: `private/rr/bin/rr`
- Namespace examples: `private/rr/namespaces/nix.sh`
- Common helpers: `private/rr/lib/common.sh`
- Documentation: `docs/rr-cli.md`

### Related Plans
- RR CLI implementation: `thoughts/_shared/plans/20251020_rr-cli-dispatcher-implementation.md`
- Blob script creation: `thoughts/_shared/plans/20251024_blob-sh-json-extraction.md`
- S3URL script creation: `thoughts/_shared/plans/20251024_s3url-script-creation.md`

---

**Plan Created:** 2025-10-24
**Implementation Phase:** 2 phases
**Estimated Time:** 1-2 hours
**Status:** Ready for Implementation
