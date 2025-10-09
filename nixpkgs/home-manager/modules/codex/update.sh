#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodePackages.npm nix-prefetch-scripts
# shellcheck shell=bash

set -euo pipefail

version=$(npm view @openai/codex version)
echo "Latest codex version: $version"

# Update version in default.nix
cd "$(dirname "${BASH_SOURCE[0]}")"
sed -i'' -e "s/version = \".*\";/version = \"$version\";/" default.nix

# Get new source hash
url="https://registry.npmjs.org/@openai/codex/-/codex-$version.tgz"
echo "Fetching hash for $url"
hash=$(nix-prefetch-url --type sha256 --unpack "$url")
sri_hash=$(nix hash to-sri --type sha256 "$hash")

# Update source hash in default.nix
sed -i'' -e "s|hash = \".*\";|hash = \"$sri_hash\";|" default.nix

# Generate updated lock file
npm i --package-lock-only "@openai/codex@$version"
rm -f package.json

echo "Updated codex to version $version"
echo "Source hash: $sri_hash"
echo "You may need to update npmDepsHash after trying to build"
