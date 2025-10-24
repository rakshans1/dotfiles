# S3 URL Builder Script Implementation Plan

## Overview

Create a new Raycast script `s3url.sh` that parses JSON blob input and outputs a plain S3 URL in the format `s3://{bucket}/{key}`.

## Current State Analysis

- Existing `blob.sh` script extracts `region`, `bucket`, and `key` from JSON input
- blob.sh uses sed patterns to handle both quoted and unquoted JSON values
- blob.sh is configured as a Raycast script with proper metadata headers

## Desired End State

A new script `private/raycast/scripts/s3url.sh` that:
- Takes the same JSON input format as blob.sh
- Extracts `bucket` and `key` fields (ignores `region`)
- Outputs a plain S3 URL: `s3://{bucket}/{key}`

### Verification:
```bash
# Test with sample input
echo '{"region": "us-west-2", "bucket": "iv-stage-pro-dev", "key": "generatives/cc491897221465d417f045510660bedcf85bbf77b21efb9ef8d841f002670e27/cc491897221465d417f045510660bedcf85bbf77b21efb9ef8d841f002670e27"}' | ./s3url.sh

# Expected output:
s3://iv-stage-pro-dev/generatives/cc491897221465d417f045510660bedcf85bbf77b21efb9ef8d841f002670e27/cc491897221465d417f045510660bedcf85bbf77b21efb9ef8d841f002670e27
```

## What We're NOT Doing

- NOT parsing the JSON output from blob.sh (takes raw JSON input instead)
- NOT including region in the S3 URL
- NOT adding HTTP/HTTPS URL format
- NOT adding additional formatting or context to output

## Implementation Approach

Use `jq` for clean JSON parsing since input is guaranteed to be valid JSON. This is simpler and more reliable than sed-based parsing.

## Phase 1: Create S3 URL Script

### Overview

Create a new Raycast script that extracts bucket and key from JSON and outputs S3 URL.

### Changes Required:

#### 1. New Script File

**File**: `private/raycast/scripts/s3url.sh`
**Changes**: Create new executable script based on blob.sh structure

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

# Parse JSON and extract bucket and key using jq
bucket=$(echo "$input" | jq -r '.bucket')
key=$(echo "$input" | jq -r '.key')

# Output S3 URL
echo "s3://$bucket/$key"
```

#### 2. Make Script Executable

```bash
chmod +x private/raycast/scripts/s3url.sh
```

### Success Criteria:

- [x] Script file created at `private/raycast/scripts/s3url.sh`
- [x] Script is executable (`chmod +x`)
- [x] Script has proper Raycast metadata headers
- [x] `jq` is available in PATH
- [x] Manual test with valid JSON passes
- [ ] Script integrates with Raycast (appears in Raycast launcher)
- [x] Output matches expected format: `s3://{bucket}/{key}`

### Test Cases:

```bash
# Test 1: Simple path
input='{"region": "us-west-2", "bucket": "my-bucket", "key": "path/to/file"}'
expected="s3://my-bucket/path/to/file"

# Test 2: Complex key path (from example)
input='{"region": "us-west-2", "bucket": "iv-stage-pro-dev", "key": "generatives/cc491897221465d417f045510660bedcf85bbf77b21efb9ef8d841f002670e27/cc491897221465d417f045510660bedcf85bbf77b21efb9ef8d841f002670e27"}'
expected="s3://iv-stage-pro-dev/generatives/cc491897221465d417f045510660bedcf85bbf77b21efb9ef8d841f002670e27/cc491897221465d417f045510660bedcf85bbf77b21efb9ef8d841f002670e27"

# Test 3: With special characters in key
input='{"region": "us-east-1", "bucket": "test-bucket", "key": "folder/sub-folder/file_name-v2.json"}'
expected="s3://test-bucket/folder/sub-folder/file_name-v2.json"
```

## References

- Source script: `private/raycast/scripts/blob.sh`
- Raycast script documentation: Existing blob.sh metadata format
