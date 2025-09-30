# Claude Code Module Update Guide

Custom Home Manager module for latest claude-code from npm.

## Update Process

```bash
cd nixpkgs/home-manager/modules/claude-code
./update.sh
cd ../../../..
git add nixpkgs/home-manager/modules/claude-code/
git commit -m "Update claude-code to vX.X.X"
nix-switch
```

## Troubleshooting

**Hash mismatch:** Re-run `./update.sh`
**Build fails:** Check package structure changes in `default.nix`
**Verify:** `claude --version`

## Files
- `default.nix` - Package definition
- `update.sh` - Auto-update script
- `package-lock.json` - Dependencies