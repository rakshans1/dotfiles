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

    flyctl

    nodejs-18_x
    nodePackages.eslint_d
    nodePackages.prettier

    pkgsUnstable.youtube-dl
    speedtest-cli

    tokei
    yarn
    git

    glow
    duf

    nixpkgs-fmt

    awscli
  ] ++ lib.optionals stdenv.isDarwin [
    coreutils
  ] ++ lib.optionals stdenv.isLinux [
  ];
}
