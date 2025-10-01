{
  pkgs,
  ghostty ? null,
  lib,
  ...
}:
{
  # Package installation:
  # - Linux: Install via Nix (flake or nixpkgs)
  # - macOS: No installation here (managed by Homebrew in darwin config)
  home.packages = lib.optionals pkgs.stdenv.isLinux [
    (if ghostty != null then ghostty.default else pkgs.ghostty)
  ];

  # Ghostty configuration file
  # See: https://ghostty.org/docs/config/reference
  xdg.configFile."ghostty/config".text = ''
    # Font configuration
    font-family = FiraCode Nerd Font Mono
    font-size = 14

    theme = iceberg-dark

    # Terminal behavior
    shell-integration = detect
    scrollback-limit = 10000

    cursor-style = block

    maximize = true

    window-save-state = always

    # macOS specific
    macos-option-as-alt = true
    macos-titlebar-style = hidden
  '';
}
