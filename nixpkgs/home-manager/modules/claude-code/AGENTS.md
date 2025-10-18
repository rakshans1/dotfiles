# Claude Code Module Update Guide

Custom Home Manager module for latest claude-code from npm.

## Automatic Update Process

The `update.sh` script automatically updates **all required hashes**:
- Package version
- Source hash (`hash`)
- npm dependencies hash (`npmDepsHash`)

```bash
cd nixpkgs/home-manager/modules/claude-code
./update.sh
```

The script will:
1. Fetch the latest version from npm
2. Download and hash the source
3. Generate updated package-lock.json
4. Calculate npmDepsHash automatically
5. Update all values in default.nix

After the script completes, simply commit and apply:

```bash
git add .
git commit -m "chore: Update claude-code to v<VERSION>"
nix-switch
```

## Troubleshooting

**Hash mismatch:** Should not happen - script calculates correct hashes
**Build fails:** Check package structure changes in `default.nix`
**Verify installation:** `claude --version`

## Files
- `default.nix` - Package definition
- `update.sh` - Fully automated update script
- `package-lock.json` - npm dependencies (auto-generated)