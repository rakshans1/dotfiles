# Kanata Setup

Kanata replaces Karabiner-Elements as the keyboard remapper. It runs as a
launchd daemon (defined in `nixpkgs/darwin/mbp/modules/kanata.nix`) and reads
its config from `~/.config/kanata/kanata.kbd` (symlinked to
`config/kanata/kanata.kbd` in this repo).

## Components

| Piece | Location |
|-------|----------|
| Package | `kanata-with-cmd` in `nixpkgs/darwin/mbp/configuration.nix` (`environment.systemPackages`) |
| Daemon | `nixpkgs/darwin/mbp/modules/kanata.nix` (launchd) |
| Config file | `config/kanata/kanata.kbd` (symlinked via `nixpkgs/home-manager/modules/kanata.nix`) |
| Helper command | `rr kanata <subcommand>` (`private/rr/namespaces/kanata.sh`) |
| Logs | `/var/log/kanata.out.log` and `/var/log/kanata.err.log` |

Karabiner-Elements is still installed because kanata depends on its virtual
HID driver. Only Karabiner's config grabber needs to be off — the driver runs
as a separate system extension.

## One-time setup on a new machine

1. **Install via nix**: `rr nix switch` — installs `kanata-with-cmd` and
   registers the launchd daemon.
2. **Disable Karabiner-Elements GUI**: System Settings → General → Login Items
   & Extensions → "Allow in the Background" → toggle off both
   "Karabiner-Elements Non-Privileged Agents v2" and "Karabiner-Elements
   Privileged Daemons v2". Keep the Karabiner-DriverKit-VirtualHIDDevice
   system extension enabled.
3. **Grant Input Monitoring permission** to kanata:

   ```bash
   rr kanata grant
   ```

   This opens System Settings → Privacy & Security → Input Monitoring. Then:
   - Click "+"
   - `Cmd+Shift+G`, enter `/run/current-system/sw/bin`
   - Select `kanata`, click Open, toggle ON
   - If kanata still fails, repeat for Accessibility

4. **Restart the daemon**: `rr kanata restart`
5. **Verify**: `rr kanata status` — should show a PID and exit code `0`.

## Daily commands

```bash
rr kanata grant     # Open Input Monitoring (if permission is missing/broken)
rr kanata restart   # Restart daemon (after config edit)
rr kanata status    # Check daemon PID + last exit code
rr kanata logs      # Tail stderr log
rr kanata check     # Validate kanata.kbd syntax without running
```

## Editing the config

Edit `config/kanata/kanata.kbd` directly — the file is symlinked into
`~/.config/kanata/` via home-manager (`mkOutOfStoreSymlink`), so edits are
live. After saving:

```bash
rr kanata check     # validate syntax
rr kanata restart   # apply changes
rr kanata logs      # verify in logs
```

## Troubleshooting

### "IOHIDDeviceOpen error: not permitted" in logs

Input Monitoring permission is missing. Run `rr kanata grant`.

### Permission keeps breaking after nix-darwin updates

Should not happen — kanata is copied to `/Library/Application
Support/io.kanata/bin/kanata` and ad-hoc codesigned with a stable identifier
(`io.kanata.kanata`) by the activation script. TCC tracks the grant by code
identity, which is now stable across nix-darwin rebuilds. If permission does
break, re-run `rr kanata grant` and reselect kanata.

### Karabiner and kanata both run, fighting over the keyboard

Disable Karabiner-Elements login items (see step 2 above). The
Karabiner-DriverKit-VirtualHIDDevice extension is fine — it's just the
driver that kanata uses.

### Daemon won't start

Check the err log:

```bash
rr kanata logs
```

Common causes:
- Permission missing (see above)
- Config syntax error (`rr kanata check`)
- Kanata binary not installed (`which kanata`)
