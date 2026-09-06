#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq
# shellcheck shell=bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

BASE_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app"

# Platform manifest carries version, download url and sha512 checksum
manifest=$(curl -fsSL "$BASE_URL/manifests/darwin_arm64.json")

version=$(echo "$manifest" | jq -r '.version')
url=$(echo "$manifest" | jq -r '.url')
sha512_hex=$(echo "$manifest" | jq -r '.sha512')

echo "Latest antigravity-cli version: $version"

current=$(jq -r '.version' hashes.json)
echo "Current version: $current"

if [[ "$version" == "$current" ]]; then
  echo "Already up to date"
  exit 0
fi

echo "Updating from $current to $version"

sri=$(nix hash convert --hash-algo sha512 --to sri "$sha512_hex")
echo "aarch64-darwin: $sri"

cat >hashes.json <<EOF
{
  "version": "$version",
  "platforms": {
    "aarch64-darwin": {
      "url": "$url",
      "hash": "$sri"
    }
  }
}
EOF

echo "Updated to $version"
