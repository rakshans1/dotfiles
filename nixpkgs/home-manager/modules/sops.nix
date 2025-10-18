{
  config,
  lib,
  pkgs,
  private,
  ...
}:

{
  # SOPS age key configuration
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  # Define all your secrets here
  sops.secrets = {
    # API Keys
    "llm_api_key" = {
      sopsFile = "${private}/secrets/common.yaml";
    };
    "llm_endpoint" = {
      sopsFile = "${private}/secrets/common.yaml";
    };

    # AWS Credentials
    "aws_access_key_id" = {
      sopsFile = "${private}/secrets/common.yaml";
    };
    "aws_secret_access_key" = {
      sopsFile = "${private}/secrets/common.yaml";
    };

    # Kubernetes Configuration
    "k8s_certificate_authority_data" = {
      sopsFile = "${private}/secrets/common.yaml";
    };
    "k8s_server_endpoint" = {
      sopsFile = "${private}/secrets/common.yaml";
    };
    "k8s_cluster_name" = {
      sopsFile = "${private}/secrets/common.yaml";
    };
    "k8s_region" = {
      sopsFile = "${private}/secrets/common.yaml";
    };
    "k8s_namespace" = {
      sopsFile = "${private}/secrets/common.yaml";
    };
    "k8s_aws_account_id" = {
      sopsFile = "${private}/secrets/common.yaml";
    };

    # WakaTime API Key
    "wakatime_api_key" = {
      sopsFile = "${private}/secrets/common.yaml";
    };

  }
  // (
    # Platform-specific secrets
    if pkgs.stdenv.isDarwin then
      {
        # macOS-specific secrets
        # "keychain_password" = {
        #   sopsFile = "${private}/secrets/darwin.yaml";
        # };
      }
    else
      {
        # Linux-specific secrets
        # "sudo_password" = {
        #   sopsFile = "${private}/secrets/linux.yaml";
        # };
      }
  );
}
