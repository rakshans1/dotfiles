#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch-scripts
# shellcheck shell=bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

BASE_URL="https://storage.googleapis.com/grok-build-public-artifacts/cli"
CHANNEL="${GROK_CHANNEL:-stable}"

# Fetch latest version from the channel pointer
version=$(curl -fsSL "$BASE_URL/$CHANNEL" | tr -d '[:space:]')
echo "Latest grok version ($CHANNEL): $version"

current=$(jq -r '.version' hashes.json)
echo "Current version: $current"

if [[ "$version" == "$current" ]]; then
  echo "Already up to date"
  exit 0
fi

echo "Updating from $current to $version"

# No published checksum manifest - prefetch the binary and derive the SRI hash
url="$BASE_URL/grok-${version}-macos-aarch64"
echo "Fetching $url"
darwin_arm64_sri=$(nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url "$url" 2>/dev/null)")

echo "aarch64-darwin: $darwin_arm64_sri"

cat >hashes.json <<EOF
{
  "version": "$version",
  "hashes": {
    "aarch64-darwin": "$darwin_arm64_sri"
  }
}
EOF

echo "Updated to $version"
