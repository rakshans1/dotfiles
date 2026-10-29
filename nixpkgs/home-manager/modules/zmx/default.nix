# zmx - terminal session persistence (https://zmx.sh), upstream release binary.
#
# DELIBERATELY PINNED. A zmx upgrade that changes the client <-> daemon IPC
# kills every running session (zmx "known issues"), i.e. every pane, server
# and agent living in zmx. So zmx must never move as a side effect of
# `rr nix switch` / `nix flake update`:
#   - not from `nixpkgs` / `nixpkgsUnstable`: both are rolling FlakeHub
#     inputs that `rr nix switch` updates (and neither carries zmx today);
#   - instead a fixed upstream tarball (version + hash in hashes.json) that
#     only changes when this file's pin is edited by hand.
#
# Upgrading (deliberately, with nothing important running in zmx):
#   1. read the zmx changelog for IPC/protocol changes
#   2. for each platform:  nix hash file zmx-<v>-<platform>.tar.gz
#      (or nix store prefetch-file https://zmx.sh/a/zmx-<v>-<platform>.tar.gz)
#   3. update hashes.json, `rr nix switch`, then recreate sessions
{
  lib,
  stdenv,
  fetchurl,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hashes;

  platformMap = {
    aarch64-darwin = "macos-aarch64";
    x86_64-linux = "linux-x86_64";
  };

  platform = stdenv.hostPlatform.system;
  platformSuffix = platformMap.${platform} or (throw "zmx: unsupported system ${platform}");
in
stdenv.mkDerivation {
  pname = "zmx";
  inherit version;

  src = fetchurl {
    url = "https://zmx.sh/a/zmx-${version}-${platformSuffix}.tar.gz";
    hash = hashes.${platform};
  };

  # The tarball holds a single `zmx` binary at its root
  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 zmx $out/bin/zmx

    # zsh completion as an autoloadable file (fpath) instead of an
    # `eval "$(zmx completions zsh)"` on every shell start. Upstream ends the
    # script with `compdef _zmx zmx`; autoloaded files must call the function.
    mkdir -p $out/share/zsh/site-functions "$TMPDIR/zmx-run"
    ZMX_DIR="$TMPDIR/zmx-run" $out/bin/zmx completions zsh \
      | sed 's/^compdef _zmx zmx$/_zmx "$@"/' > $out/share/zsh/site-functions/_zmx
    runHook postInstall
  '';

  meta = {
    description = "Session persistence for terminal processes";
    homepage = "https://zmx.sh";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "zmx";
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
  };
}
