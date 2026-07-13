#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils jq nix
# shellcheck shell=bash

# Updates hashes.json with the latest opencode version and per-platform
# binary package hashes from npm.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

version=$(npm view opencode-ai version)
echo "Latest opencode version: $version"

# nix system -> opencode platform-specific npm package name
declare -A platforms=(
  [aarch64-darwin]=opencode-darwin-arm64
  [x86_64-darwin]=opencode-darwin-x64
  [x86_64-linux]=opencode-linux-x64
  [aarch64-linux]=opencode-linux-arm64
)

json=$(jq -n --arg version "$version" '{version: $version, hashes: {}}')

for system in "${!platforms[@]}"; do
  pkg="${platforms[$system]}"
  url="https://registry.npmjs.org/$pkg/-/$pkg-$version.tgz"
  echo "Fetching hash for $system ($pkg)..."
  hash=$(nix-prefetch-url --type sha256 --unpack "$url" 2>/dev/null)
  sri=$(nix hash convert --hash-algo sha256 --to sri "$hash")
  json=$(jq --arg s "$system" --arg h "$sri" '.hashes[$s] = $h' <<<"$json")
done

echo "$json" | jq . >hashes.json

echo "Updated opencode to version $version"
echo "All platform hashes updated automatically!"
