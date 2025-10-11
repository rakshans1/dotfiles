#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-github nodePackages.npm prefetch-npm-deps
# shellcheck shell=bash

set -euo pipefail

version=$(npm view @google/gemini-cli version)
echo "Latest gemini-cli version: $version"

cd "$(dirname "${BASH_SOURCE[0]}")"
sed -i'' -e "s/version = \".*\";/version = \"$version\";/" default.nix

echo "Fetching GitHub hash for v$version"
nix-prefetch-github google-gemini gemini-cli --rev "v$version" | tee github-hash.json
hash=$(grep '"hash"' github-hash.json | cut -d'"' -f4)
rm github-hash.json

sed -i'' -e "s|hash = \".*\";|hash = \"$hash\";|" default.nix

# Fetch the source to get package-lock.json for npmDepsHash calculation
echo "Fetching source for npmDepsHash calculation..."
temp_dir=$(mktemp -d)
curl -sL "https://github.com/google-gemini/gemini-cli/archive/refs/tags/v$version.tar.gz" | tar xz -C "$temp_dir" --strip-components=1

# Calculate npmDepsHash
echo "Calculating npmDepsHash..."
npm_deps_hash=$(prefetch-npm-deps "$temp_dir/package-lock.json")
npm_deps_sri=$(nix hash to-sri --type sha256 "$npm_deps_hash")

# Clean up
rm -rf "$temp_dir"

# Update npmDepsHash in default.nix
sed -i'' -e "s|npmDepsHash = \".*\";|npmDepsHash = \"$npm_deps_sri\";|" default.nix

echo "Updated gemini-cli to version $version"
echo "GitHub hash: $hash"
echo "npmDepsHash: $npm_deps_sri"
echo "All hashes updated automatically!"
