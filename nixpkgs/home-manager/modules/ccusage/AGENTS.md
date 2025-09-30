# ccusage Module Update Guide

Custom Home Manager module for latest ccusage from npm.

## Update Process

```bash
cd nixpkgs/home-manager/modules/ccusage
./update.sh
cd ../../../..
git add nixpkgs/home-manager/modules/ccusage/
git commit -m "Update ccusage to vX.X.X"
nix-switch
```

## Troubleshooting

**Hash mismatch:** Re-run `./update.sh`
**Build fails:** Check package structure changes in `default.nix`
**Verify:** `ccusage --version`

## Files
- `default.nix` - Package definition
- `update.sh` - Auto-update script
- `package-lock.json` - Dependencies