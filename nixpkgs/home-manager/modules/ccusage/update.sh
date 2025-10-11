#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodePackages.npm nix-prefetch-scripts prefetch-npm-deps
# shellcheck shell=bash

set -euo pipefail

version=$(npm view ccusage version)
echo "Latest ccusage version: $version"

# Update version in default.nix
cd "$(dirname "${BASH_SOURCE[0]}")"
sed -i'' -e "s/version = \".*\";/version = \"$version\";/" default.nix

# Get new source hash
url="https://registry.npmjs.org/ccusage/-/ccusage-$version.tgz"
echo "Fetching hash for $url"
hash=$(nix-prefetch-url --type sha256 --unpack "$url")
sri_hash=$(nix hash to-sri --type sha256 "$hash")

# Update source hash in default.nix
sed -i'' -e "s|hash = \".*\";|hash = \"$sri_hash\";|" default.nix

# Generate updated lock file
npm i --package-lock-only "ccusage@$version"
rm -f package.json

# Calculate npmDepsHash
echo "Calculating npmDepsHash..."
npm_deps_hash=$(prefetch-npm-deps package-lock.json)
npm_deps_sri=$(nix hash to-sri --type sha256 "$npm_deps_hash")

# Update npmDepsHash in default.nix
sed -i'' -e "s|npmDepsHash = \".*\";|npmDepsHash = \"$npm_deps_sri\";|" default.nix

echo "Updated ccusage to version $version"
echo "Source hash: $sri_hash"
echo "npmDepsHash: $npm_deps_sri"
echo "All hashes updated automatically!"
