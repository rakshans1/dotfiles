{ lib, pkgs, ... }:
let
  kanataIdentifier = "io.kanata.kanata";
  kanataInstallDir = "/Library/Application Support/io.kanata/bin";
  kanataBin = "${kanataInstallDir}/kanata";
in
{
  # TCC privacy grants are tied to code identity. Do not launch kanata through
  # /run/current-system/sw/bin/kanata: that symlink changes identity across Nix
  # switches and is awkward for System Settings. Install a stable, signed copy.
  system.activationScripts.launchd.text = lib.mkBefore ''
    echo >&2 "installing signed kanata launchd binary..."
    /usr/bin/install -d -o root -g wheel -m 0755 "${kanataInstallDir}"
    /usr/bin/install -o root -g wheel -m 0755 "${pkgs.kanata-with-cmd}/bin/kanata" "${kanataBin}"
    /usr/bin/codesign --force --sign - \
      --identifier "${kanataIdentifier}" \
      --requirements '=designated => identifier "${kanataIdentifier}"' \
      "${kanataBin}"
    /usr/bin/codesign --verify --verbose=2 "${kanataBin}"
  '';

  # Karabiner VirtualHIDDevice userspace daemon — required by kanata to talk
  # to the kernel driver. Normally started by Karabiner-Elements; we keep it
  # alive independently since we don't run Karabiner-Elements anymore.
  launchd.daemons.karabiner-vhid-daemon = {
    serviceConfig = {
      Label = "org.pqrs.Karabiner-VirtualHIDDevice-Daemon";
      ProgramArguments = [
        "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/karabiner-vhid-daemon.out.log";
      StandardErrorPath = "/var/log/karabiner-vhid-daemon.err.log";
    };
  };

  # Kanata keyboard remapper as a launchd daemon.
  # Runs as root (required for HID access on macOS via Karabiner virtual driver).
  launchd.daemons.kanata = {
    serviceConfig = {
      Label = "io.kanata";
      ProgramArguments = [
        kanataBin
        "-c"
        "/Users/rakshan/.config/kanata/kanata.kbd"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      StandardOutPath = "/var/log/kanata.out.log";
      StandardErrorPath = "/var/log/kanata.err.log";
    };
  };
}
