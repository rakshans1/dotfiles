{ config, pkgs, pkgsUnstable, aiTools, ... }:
{

  imports = [
    ./zsh.nix
    ./git.nix
    ./ripgrep.nix
    ./bat.nix
    ./elixir.nix
    ./claude.nix
    ./lvim.nix
    ./kitty.nix
  ];

  # https://github.com/nix-community/nix-direnv#via-home-manager
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.config.global.log_filter = "^$";

  home.packages = with pkgs; [
    fd
    zsh
    wget
    fzf
    vivid
    bottom
    jq
    gnupg
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
    age
    sops
    ssh-to-age

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
  ] ++ [ aiTools.crush ];
}
