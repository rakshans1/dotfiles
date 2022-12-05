{ config, pkgs, home-manager, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/common.nix
  ];

  home.homeDirectory = "/Users/rakshan";
  home.username = "rakshan";

  home.stateVersion = "22.05";

  fonts.fontconfig.enable = true;

  programs.tmux.enable = false;
}
