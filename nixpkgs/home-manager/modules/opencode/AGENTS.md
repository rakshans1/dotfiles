# opencode Module Update Guide

Native binary module for opencode (sst/opencode), distributed as
platform-specific prebuilt Bun binaries on npm.

## Why not buildNpmPackage?

The `opencode-ai` npm package is a thin wrapper whose `postinstall` script
downloads the real, self-contained binary for the current platform (e.g.
`opencode-darwin-arm64`). That network download is blocked in the Nix sandbox,
so we fetch the platform-specific binary package directly — same approach as the
`claude-code` module.

## Automatic Update Process

```bash
cd nixpkgs/home-manager/modules/opencode
./update.sh
```

The script will:
1. Fetch the latest version from npm (`opencode-ai`)
2. Compute the unpacked SRI hash for each platform's binary package
3. Update `hashes.json`

After the script completes, commit and apply:

```bash
git add .
git commit -m "chore: Update opencode to v<VERSION>"
rr nix switch
```

## Troubleshooting

**Hash mismatch:** Should not happen — the script computes correct hashes
**Build fails:** Check whether the npm package layout changed in `default.nix`
**Verify installation:** `opencode --version`

## Files
- `default.nix` - Package definition (fetches native binary per platform)
- `hashes.json` - Version and per-platform hashes
- `update.sh` - Automated update script
