{ config, lib, pkgs, ... }:

{
  # SOPS age key configuration
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  # Default secrets file - common across platforms
  sops.defaultSopsFile = ./private/secrets/common.yaml;

  # Platform-specific secrets file based on system
  sops.secrets = {
    # Common secrets available on all platforms
    # Example configuration (uncomment when secrets exist):
    # "github_token" = {
    #   sopsFile = ./private/secrets/common.yaml;
    # };
    # "openai_api_key" = {
    #   sopsFile = ./private/secrets/common.yaml;
    # };

    # Development secrets
    # "database_password" = {
    #   sopsFile = ./private/secrets/development.yaml;
    # };

    # Personal service secrets
    # "backup_encryption_key" = {
    #   sopsFile = ./private/secrets/personal.yaml;
    # };
  } // (
    # Platform-specific secrets
    if pkgs.stdenv.isDarwin then {
      # macOS-specific secrets
      # "keychain_password" = {
      #   sopsFile = ./private/secrets/darwin.yaml;
      # };
    } else {
      # Linux-specific secrets
      # "sudo_password" = {
      #   sopsFile = ./private/secrets/linux.yaml;
      # };
    }
  );

  # Note: age, sops, and ssh-to-age are already installed via common.nix
}
