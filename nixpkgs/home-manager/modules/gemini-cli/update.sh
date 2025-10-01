#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-github nodePackages.npm
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

echo "Updated gemini-cli to version $version"
echo "GitHub hash: $hash"
echo "Run nix-switch to rebuild with new version"
