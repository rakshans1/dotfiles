{ config, pkgs, pkgsUnstable, ... }:
{

  imports = [
    ./zsh.nix
  ];

  # https://github.com/nix-community/nix-direnv#via-home-manager
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs; [
    fd
    ripgrep
    zsh
    wget
    tmux
    fzf
    vivid
    bottom
    bat
    jq
    delta
    neofetch
    tealdeer
    zoxide
    gh
    eza
    ffmpeg_7-full
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    tesseract

    neovim
    lunarvim

    nodejs_22
    nodePackages.eslint_d
    nodePackages.serve
    nodePackages.tailwindcss

    rustc
    cargo
    rustfmt
    cargo-sweep

    k9s

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
    nix-init

    awscli2
    caddy
    cloudflared

    ollama

    kubectl

    exiftool

    (python3.withPackages (
      ps: with ps; [
        llm
        llm-gemini
        llm-ollama
      ]
    ))

    claude-code
    gemini-cli

  ] ++ lib.optionals stdenv.isDarwin [
   # Mac App Store command line interface
    mas
    coreutils
    pngpaste
    blueutil
  ] ++ lib.optionals stdenv.isLinux [
  ];
}
