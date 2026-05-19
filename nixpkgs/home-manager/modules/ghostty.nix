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

    # Keybinds
    keybind = global:alt+grave_accent=toggle_quick_terminal

    # Cmd+letter -> Ctrl+letter (for tmux/shell flows on macOS)
    keybind = cmd+s=text:\x13
    keybind = cmd+h=text:\x08
    keybind = cmd+j=text:\x0a
    keybind = cmd+k=text:\x0b
    keybind = cmd+l=text:\x0c
    keybind = cmd+w=text:\x17
    keybind = cmd+x=text:\x18
    keybind = cmd+b=text:\x02
    keybind = cmd+p=text:\x10
    keybind = cmd+slash=text:\x1f
    keybind = cmd+backslash=text:\x1c
    keybind = cmd+n=text:\x0e
    keybind = cmd+d=text:\x04
    keybind = cmd+u=text:\x15

    # macOS specific
    macos-option-as-alt = true
    macos-titlebar-style = hidden
  '';
}
