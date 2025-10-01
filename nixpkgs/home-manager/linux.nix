{
  config,
  pkgs,
  home-manager,
  sops-nix,
  ...
}:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/common.nix
    ./modules/sops.nix
    ./modules/aws.nix
    ./modules/kubernetes.nix
    sops-nix.homeManagerModules.sops
  ];

  home.homeDirectory = "/home/rakshan";
  home.username = "rakshan";

  home.stateVersion = "23.05";

  fonts.fontconfig.enable = true;

  programs.tmux.enable = false;
}
