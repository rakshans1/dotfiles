# gemini-cli Module Update Guide

Custom Home Manager module for latest @google/gemini-cli from GitHub.

## Update Process

```bash
cd nixpkgs/home-manager/modules/gemini-cli
./update.sh
cd ../../../..
git add nixpkgs/home-manager/modules/gemini-cli/
git commit -m "Update gemini-cli to vX.X.X"
nix-switch
```

## Troubleshooting

**Hash mismatch:** Re-run `./update.sh`
**Build fails:** Check package structure changes in `default.nix`
**Verify:** `gemini --version`

## Files
- `default.nix` - Package definition
- `update.sh` - Auto-update script

## Notes
- Uses GitHub source (not npm) to match nixpkgs approach
- Removes node-pty dependency in postPatch to avoid build issues