#!/usr/bin/env bash
# shellcheck shell=bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Everything is computed into a scratch dir first and default.nix /
# package-lock.json are only written once every value is known. A failure
# part-way (network, auto-GC, ...) must never leave a bumped version next to
# a stale npmDepsHash.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Tools are built with --out-link into $work, which registers GC roots for the
# duration of the run. `nix-shell -p` doesn't root its deps, so Nix's auto-GC
# (min-free) could delete them mid-run on a nearly full /nix.
# nix-prefetch-url ships with Nix itself.
echo "Preparing tools..."
nix build nixpkgs#nodejs --out-link "$work/nodejs"
nix build nixpkgs#prefetch-npm-deps --out-link "$work/prefetch-npm-deps"
export PATH="$work/nodejs/bin:$work/prefetch-npm-deps/bin:$PATH"

version=$(npm view @openai/codex version)
echo "Latest codex version: $version"

# Get new source hash
url="https://registry.npmjs.org/@openai/codex/-/codex-$version.tgz"
echo "Fetching hash for $url"
hash=$(nix-prefetch-url --type sha256 --unpack "$url")
sri_hash=$(nix hash to-sri --type sha256 "$hash")

# Generate updated lock file
(cd "$work" && npm i --package-lock-only "@openai/codex@$version")

# Calculate npmDepsHash
echo "Calculating npmDepsHash..."
npm_deps_hash=$(prefetch-npm-deps "$work/package-lock.json")
npm_deps_sri=$(nix hash to-sri --type sha256 "$npm_deps_hash")

# All values known — now write them
cp default.nix "$work/default.nix"
sed -i'' \
  -e "s/version = \".*\";/version = \"$version\";/" \
  -e "s|^\( *\)hash = \".*\";|\1hash = \"$sri_hash\";|" \
  -e "s|npmDepsHash = \".*\";|npmDepsHash = \"$npm_deps_sri\";|" \
  "$work/default.nix"

# Guard against a silently-skipped substitution leaving a stale value behind,
# which only surfaces much later as a build-time hash mismatch
for expected in "version = \"$version\";" "hash = \"$sri_hash\";" "npmDepsHash = \"$npm_deps_sri\";"; do
  grep -qF "$expected" "$work/default.nix" ||
    { echo "Error: failed to write '$expected' into default.nix" >&2; exit 1; }
done

cp "$work/package-lock.json" package-lock.json
cp "$work/default.nix" default.nix

echo "Updated codex to version $version"
echo "Source hash: $sri_hash"
echo "npmDepsHash: $npm_deps_sri"
echo "All hashes updated automatically!"
