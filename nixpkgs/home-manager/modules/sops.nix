{
  config,
  lib,
  pkgs,
  private,
  ...
}:

{
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets = import "${private}/secrets.nix" { inherit private pkgs; };
}
