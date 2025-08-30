{ config, pkgs, home-manager, sops-nix, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/common.nix
    ./modules/tmux.nix
    ./modules/sops.nix
    sops-nix.homeManagerModules.sops
  ];

  nixpkgs.config.allowUnfree = true;

  home.homeDirectory = "/Users/rakshan";
  home.username = "rakshan";

  home.stateVersion = "23.05";

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "vim";
  };
}
