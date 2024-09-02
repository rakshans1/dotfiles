{ config, pkgs, pkgsUnstable, ... }:
let
  llm-mistral = pkgs.callPackage ../packages/llm-mistral/default.nix {};
  llm-ollama = pkgs.callPackage ../packages/llm-ollama/default.nix {};
in
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
    eza
    ffmpeg_7-full
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    neovim

    nodejs_22
    nodePackages.eslint_d
    nodePackages.prettier
    nodePackages.serve
    nodePackages.tailwindcss

    rustc
    cargo
    rustfmt
    cargo-sweep

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

    (llm.withPlugins ([ llm-mistral llm-ollama ]))

    ollama


  ] ++ lib.optionals stdenv.isDarwin [
    coreutils
  ] ++ lib.optionals stdenv.isLinux [
  ];
}
