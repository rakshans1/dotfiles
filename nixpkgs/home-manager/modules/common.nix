{
  pkgs,
  pkgsUnstable,
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
    ./codex.nix
    ./opencode.nix
    ./agents.nix
    ./lvim.nix
    ./ghostty.nix
    ./sublime.nix
    ./glow.nix
    ./bottom.nix
    ./caddy.nix
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

      jq
      jqp
      yq
      gnupg
      delta
      difftastic
      neofetch
      tealdeer
      eza
      tree
      ffmpeg_7-full
      tesseract
      just
      lazygit
      overmind

      asciiquarium-transparent

      neovim
      lunarvim

      nodejs_22
      nodePackages.serve
      pnpm

      bun

      rustc
      cargo

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

      pkgsUnstable.ollama

      kubectl

      exiftool
      imagemagick
      age
      sops
      ssh-to-age
      chafa

      # (pkgsUnstable.python3.withPackages (
      #   ps: with ps; [
      #     llm
      #     llm-gemini
      #     llm-ollama
      #   ]
      # ))

      # lsp to be installed globally
      typescript-language-server
      bash-language-server
    ]
    ++ lib.optionals stdenv.isDarwin [
      # Mac App Store command line interface
      mas
      coreutils
      gnused # GNU sed so `sed -i 's/…/'` works (macOS ships BSD sed)
      pngpaste
      blueutil
    ]
    ++ lib.optionals stdenv.isLinux [ ]
    ++ [
      (pkgs.callPackage ./claude-code { })
      (pkgs.callPackage ./codex { })
      (pkgs.callPackage ./opencode { })
    ];

  # Create symlink for claude-code at ~/.local/bin/claude
  home.file.".local/bin/claude".source = "${pkgs.callPackage ./claude-code { }}/bin/claude";
}
