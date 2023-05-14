{ config, pkgs, home-manager, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/common.nix
  ];

  home.homeDirectory = "/home/rakshan";
  home.username = "rakshan";

  home.stateVersion = "23.05";

  fonts.fontconfig.enable = true;

  programs.tmux.enable = false;
}
