{
  pkgs,
  pkgsUnstable,
  aiTools,
  ...
}:
{
  imports = [
    ./zsh.nix
    ./git.nix
    ./ripgrep.nix
    ./bat.nix
    ./fzf.nix
    ./yazi.nix
    ./elixir.nix
    ./claude.nix
    ./lvim.nix
    ./ghostty.nix
    ./sublime.nix
    ./glow.nix
  ];

  # https://github.com/nix-community/nix-direnv#via-home-manager
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.config.global.log_filter = "^$";

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  fonts.fontconfig.enable = true;

  home.packages =
    with pkgs;
    [
      fd
      zsh
      wget
      vivid
      bottom
      jq
      jqp
      yq
      gnupg
      delta
      neofetch
      tealdeer
      eza
      tree
      ffmpeg_7-full
      tesseract
      just
      lazygit

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

      nix-init
      pkgsUnstable.nixfmt

      shfmt
      shellcheck

      rclone
      awscli2
      caddy
      cloudflared
      flyctl

      ollama

      kubectl

      exiftool
      age
      sops
      ssh-to-age

      (pkgsUnstable.python3.withPackages (
        ps: with ps; [
          llm
          llm-gemini
          llm-ollama
        ]
      ))
    ]
    ++ lib.optionals stdenv.isDarwin [
      # Mac App Store command line interface
      mas
      coreutils
      pngpaste
      blueutil
    ]
    ++ lib.optionals stdenv.isLinux [ ]
    ++ [
      aiTools.crush
      (pkgs.callPackage ./ccusage { })
      (pkgs.callPackage ./claude-code { })
      (pkgs.callPackage ./codex { })
      (pkgs.callPackage ./gemini-cli { })
    ];
}
