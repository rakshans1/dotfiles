{ config, pkgs, pkgsUnstable, ... }:
{

  # https://github.com/nix-community/nix-direnv#via-home-manager
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.zsh.enable = true;

  home.packages = with pkgs; [
    fd
    ripgrep
    zsh
    wget
    fzf
    glow
    tmux
    vivid
    bottom
    bat
    jq
    delta
    neofetch
    tealdeer
    zoxide
    gh
    ffmpeg_5-full
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    neovim
    helix

    nodejs-18_x
    nodePackages.eslint_d
    nodePackages.prettier
    nodePackages.serve

    rustc
    cargo
    rustfmt

    yt-dlp
    speedtest-cli

    tokei
    yarn
    git

    glow
    gum
    vhs

    duf

    nixpkgs-fmt

    awscli2

  ] ++ lib.optionals stdenv.isDarwin [
    coreutils
  ] ++ lib.optionals stdenv.isLinux [
  ];
}
