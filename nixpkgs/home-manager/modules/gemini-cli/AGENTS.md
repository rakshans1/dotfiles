# gemini-cli Module Update Guide

Custom Home Manager module for latest @google/gemini-cli from GitHub.

## Automatic Update Process

The `update.sh` script automatically updates **all required hashes**:
- Package version
- GitHub source hash (`hash`)
- npm dependencies hash (`npmDepsHash`)

```bash
cd nixpkgs/home-manager/modules/gemini-cli
./update.sh
```

The script will:
1. Fetch the latest version from npm
2. Download and hash the GitHub source
3. Fetch package-lock.json from GitHub
4. Calculate npmDepsHash automatically
5. Update all values in default.nix

After the script completes, simply commit and apply:

```bash
git add .
git commit -m "chore: Update gemini-cli to v<VERSION>"
nix-switch
```

## Troubleshooting

**Hash mismatch:** Should not happen - script calculates correct hashes
**Build fails:** Check package structure changes in `default.nix`
**Verify installation:** `gemini --version`

## Files
- `default.nix` - Package definition
- `update.sh` - Fully automated update script

## Notes
- Uses GitHub source (not npm) to match nixpkgs approach
- Removes node-pty dependency in postPatch to avoid build issues