#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq
# shellcheck shell=bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

BASE_URL="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

# Fetch latest version
version=$(curl -s "$BASE_URL/latest")
echo "Latest claude-code version: $version"

current=$(jq -r '.version' hashes.json)
echo "Current version: $current"

if [[ "$version" == "$current" ]]; then
  echo "Already up to date"
  exit 0
fi

echo "Updating from $current to $version"

# Fetch manifest
manifest=$(curl -s "$BASE_URL/$version/manifest.json")

# Convert hex checksum to SRI format
hex_to_sri() {
  echo "sha256-$(echo "$1" | xxd -r -p | base64)"
}

# Extract darwin-arm64 checksum and convert to SRI
darwin_arm64_hex=$(echo "$manifest" | jq -r '.platforms."darwin-arm64".checksum')
darwin_arm64_sri=$(hex_to_sri "$darwin_arm64_hex")

echo "aarch64-darwin: $darwin_arm64_sri"

# Write hashes.json
cat > hashes.json << EOF
{
  "version": "$version",
  "hashes": {
    "aarch64-darwin": "$darwin_arm64_sri"
  }
}
EOF

echo "Updated to $version"
