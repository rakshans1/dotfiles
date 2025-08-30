{ config, lib, pkgs, private, ... }:

{
  # SOPS age key configuration for system user
  sops.age.keyFile = "/Users/${config.system.primaryUser}/.config/sops/age/keys.txt";

  # Darwin-specific secrets (system-level)
  sops.secrets = {
    # System-level secrets for Darwin
    # Example configuration (uncomment when secrets exist):
    # "admin_password" = {
    #   sopsFile = "${private}/secrets/darwin.yaml";
    #   owner = config.system.primaryUser;
    # };

    # Service credentials
    # "service_token" = {
    #   sopsFile = "${private}/secrets/darwin.yaml";
    # };
  };
}
