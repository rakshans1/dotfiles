{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type file --hidden --follow --exclude .git";
    defaultOptions = [
      "--layout=reverse"
      "--color=fg:#C6C8D1,bg:#161821,hl:#89b8c2"
      "--color=fg+:#d2d4de,bg+:#262626,hl+:#95c4ce"
      "--color=info:#b4be82,prompt:#e27878,pointer:#a093c7"
      "--color=marker:#c0ca8e,spinner:#ada0d3,header:#84a0c6"
    ];
    fileWidgetCommand = "fd --type file --hidden --follow --exclude .git";
  };
}
