# Claude Code Module Update Guide

Native binary module for claude-code (darwin-only).

## Automatic Update Process

```bash
cd nixpkgs/home-manager/modules/claude-code
./update.sh
```

The script will:
1. Fetch the latest version from Google Cloud Storage
2. Download manifest.json with checksums
3. Convert checksums to SRI format
4. Update hashes.json

## Files
- `default.nix` - Package definition (fetches native binary)
- `hashes.json` - Version and platform hashes
- `update.sh` - Automated update script
