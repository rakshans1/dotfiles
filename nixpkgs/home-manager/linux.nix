{ config, pkgs, home-manager, sops-nix, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/common.nix
    sops-nix.homeManagerModules.sops
  ];

  # Basic SOPS configuration
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    # Note: No default secrets file specified yet - add secrets as needed
    secrets = {
      # Secrets will be defined here when needed
    };
  };

  home.homeDirectory = "/home/rakshan";
  home.username = "rakshan";

  home.stateVersion = "23.05";

  fonts.fontconfig.enable = true;

  programs.tmux.enable = false;
}
