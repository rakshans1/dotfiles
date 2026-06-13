{ ... }:

# rvim (the nixCats neovim flake in config/rvim) is intentionally NOT part of
# the Home Manager closure: evaluating the nixCats flake (its own nixpkgs +
# builder machinery) added ~13s to every `rr nix switch` eval. Instead,
# `rr nix switch` builds config/rvim into a dedicated nix profile only when
# its contents change. This module just puts that profile on PATH (prepended,
# so its `vim` shadows /usr/bin/vim).
{
  programs.zsh.initContent = ''
    export PATH="$HOME/.local/state/nix/profiles/rvim/bin:$PATH"
  '';
}
