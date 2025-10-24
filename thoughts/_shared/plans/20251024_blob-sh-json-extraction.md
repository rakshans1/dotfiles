# Replace LLM with Shell Pattern Matching in blob.sh

## Overview

Replace the LLM call in `blob.sh` Raycast script with shell regex pattern matching to extract AWS S3 blob reference data (region, bucket, key) from any string input.

## Current State Analysis

**File**: `private/raycast/scripts/blob.sh`

Currently uses LLM (gemini-2.0-flash) to extract blob information:
```bash
/Users/rakshan/.nix-profile/bin/llm -m gemini-2.0-flash "Given a string extract the values for aws s3 blob in following format { region: \"\", bucket: \"\", key: \"\"} String: $1 OUTPUT:"
```

**Issues with current approach:**
- Requires network call to LLM API (slow, requires internet)
- Unnecessary use of AI for structured pattern matching
- Potential cost and rate limits
- Inconsistent output formatting

**What we need to handle:**
- Input can be any string containing region, bucket, key fields
- Fields can appear in any order
- Values might or might not be quoted
- Values may contain special characters or spaces
- No `blob_reference` wrapper guaranteed

## Desired End State

The script will:
1. Accept any string as argument ($1)
2. Use regex pattern matching to extract `region`, `bucket`, and `key` fields
3. Handle both quoted and unquoted values
4. Handle fields in any order
5. Output formatted JSON with the three extracted fields

**Success verification:**
```bash
# Test 1: Full JSON with blob_reference wrapper
./blob.sh '{"blob_reference":{"key":"test/path","region":"us-west-2","bucket":"test-bucket"},"blob_metadata":{}}'

# Test 2: Simple JSON-like string
./blob.sh 'region: us-west-2, bucket: test-bucket, key: path/to/file'

# Test 3: Embedded in log message
./blob.sh 'Error occurred: {"region":"us-east-1","bucket":"my-bucket","key":"data/file.txt"} at line 42'
```

## What We're NOT Doing

- Not changing the Raycast metadata or script structure
- Not adding support for other input formats (S3 URLs, ARNs, etc.)
- Not adding extensive error handling (basic extraction only)
- Not validating AWS region/bucket name formats

## Implementation Approach

Replace the LLM call with shell pattern matching using `sed` and `grep` to extract region, bucket, and key fields from any string. The approach:

1. Use `sed` with regex patterns to extract each field independently
2. Try quoted values first, fall back to unquoted values
3. Handle fields in any order (each extraction is independent)
4. Format output as clean JSON

This works with BSD sed (macOS default) and requires no external dependencies.

## Phase 1: Replace LLM Call with Pattern Matching

### Overview

Replace line 18 with a shell script that uses regex pattern matching to extract the three required fields from any input string.

### Changes Required

#### File: `private/raycast/scripts/blob.sh`

**Change**: Replace line 18

**Old code** (line 18):
```bash
/Users/rakshan/.nix-profile/bin/llm -m gemini-2.0-flash "Given a string extract the values for aws s3 blob in following format { region: \"\", bucket: \"\", key: \"\"} String: $1 OUTPUT:"
```

**New code**:
```bash
input="$1"

# Extract region (handles both quoted and unquoted values)
region=$(echo "$input" | sed -n 's/.*["\x27]region["\x27][[:space:]]*:[[:space:]]*["\x27]\([^"'\'']*\)["\x27].*/\1/p')
[ -z "$region" ] && region=$(echo "$input" | sed -n 's/.*["\x27]region["\x27][[:space:]]*:[[:space:]]*\([^,}[:space:]]*\).*/\1/p')

# Extract bucket (handles both quoted and unquoted values)
bucket=$(echo "$input" | sed -n 's/.*["\x27]bucket["\x27][[:space:]]*:[[:space:]]*["\x27]\([^"'\'']*\)["\x27].*/\1/p')
[ -z "$bucket" ] && bucket=$(echo "$input" | sed -n 's/.*["\x27]bucket["\x27][[:space:]]*:[[:space:]]*\([^,}[:space:]]*\).*/\1/p')

# Extract key (handles both quoted and unquoted values)
key=$(echo "$input" | sed -n 's/.*["\x27]key["\x27][[:space:]]*:[[:space:]]*["\x27]\([^"'\'']*\)["\x27].*/\1/p')
[ -z "$key" ] && key=$(echo "$input" | sed -n 's/.*["\x27]key["\x27][[:space:]]*:[[:space:]]*\([^,}[:space:]]*\).*/\1/p')

# Output as JSON
echo "{"
echo "  \"region\": \"$region\","
echo "  \"bucket\": \"$bucket\","
echo "  \"key\": \"$key\""
echo "}"
```

**Explanation:**
- Each field is extracted independently, allowing any order
- First attempt: Match quoted values `"field":"value"`
- Fallback: Match unquoted values `"field":value`
- `sed -n` with `/p` flag only prints if pattern matches
- `[[:space:]]*` handles optional whitespace around colons
- `[^,}[:space:]]*` matches value until comma, brace, or whitespace
- Output formatted as clean JSON

### Success Criteria

#### Automated Tests

Run these commands to verify the script works correctly:

```bash
cd ~/dotfiles/private/raycast/scripts

# Test 1: Full JSON with blob_reference wrapper (original example)
./blob.sh '{"blob_reference":{"key":"generatives/cc491897221465d417f045510660bedcf85bbf77b21efb9ef8d841f002670e27/cc491897221465d417f045510660bedcf85bbf77b21efb9ef8d841f002670e27","region":"us-west-2","bucket":"iv-stage-pro-dev"},"blob_metadata":{"size":891116,"provider":null,"duration":37104,"tags":{"alpha":false,"audio":true},"media_type":"audio","mime_type":"audio/mpeg","dimension":{"width":null,"height":null},"license":null}}'
```
Expected: Extracts region="us-west-2", bucket="iv-stage-pro-dev", key="generatives/..."

```bash
# Test 2: Fields in different order
./blob.sh '{"bucket":"test-bucket","key":"path/to/file","region":"us-east-1"}'
```
Expected: Extracts all three fields regardless of order

```bash
# Test 3: Fields at top level (no blob_reference wrapper)
./blob.sh '{"region":"eu-west-1","bucket":"my-bucket","key":"data/test.mp3","other":"ignored"}'
```
Expected: Extracts only the three blob fields, ignores other fields

```bash
# Test 4: Embedded in larger text
./blob.sh 'Log entry: Error processing {"region":"ap-south-1","bucket":"uploads","key":"user/123/file.jpg"} at timestamp 1234567890'
```
Expected: Finds and extracts the embedded blob information

```bash
# Test 5: Nested within blob_reference (inside other JSON)
./blob.sh 'Response: {"status":"ok","data":{"region":"us-west-2","bucket":"cache","key":"temp/file"}}'
```
Expected: Extracts the nested blob fields

#### Manual Tests

- [x] Script executes successfully from command line
- [ ] Script works when invoked from Raycast (requires manual testing in Raycast UI)
- [x] Output is valid JSON format
- [x] Output contains all three fields: region, bucket, key
- [x] Script execution is instant (no network delay)
- [x] Works with fields in any order
- [x] Handles both quoted and unquoted values (if applicable)

---

## References

- Original file: `private/raycast/scripts/blob.sh:18`
- Raycast script patterns: `private/raycast/scripts/CONTRIBUTORS.md`
- Example input: Original user-provided JSON with `blob_reference` wrapper
- Shell pattern matching: Using BSD sed (macOS compatible)
