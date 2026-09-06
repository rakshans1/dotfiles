# Grok CLI Module Update Guide

Native binary module for xAI's Grok CLI (https://x.ai/cli, darwin-only).

## Automatic Update Process

    cd nixpkgs/home-manager/modules/grok
    ./update.sh

The script will:

1. Fetch the latest version from the `stable` channel pointer on Google Cloud Storage
   (`GROK_CHANNEL=alpha ./update.sh` to track the alpha channel)
2. Prefetch the `macos-aarch64` binary (xAI publishes no checksum manifest)
3. Convert the hash to SRI format
4. Update hashes.json

## Files

• default.nix - Package definition (fetches native binary)
• hashes.json - Version and platform hashes
• update.sh - Automated update script

## Notes

- Upstream artifacts live at
  `https://storage.googleapis.com/grok-build-public-artifacts/cli/grok-<version>-macos-aarch64`
- The wrapper disables the built-in auto-updater and telemetry, since Nix owns the binary.
- Auth is unchanged: run `grok login` (writes `~/.grok/auth.json`) or set `GROK_DEPLOYMENT_KEY`.
