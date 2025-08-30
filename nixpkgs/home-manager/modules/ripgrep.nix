{ config, pkgs, ... }:

{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--glob=!*.lock"
      "--glob=!.git/*"
      "--smart-case"
    ];
  };
}
