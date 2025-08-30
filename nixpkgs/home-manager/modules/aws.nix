{ config, lib, pkgs, private, ... }:

{
  # AWS configuration files managed by Nix
  # Config is static, credentials are dynamically generated from SOPS secrets

  home.file.".aws/config".text = ''
    [default]
    region = ap-south-1
    output = json
  '';

    # Generate credentials file with SOPS secrets
  home.activation.awsCredentials = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.aws
    chmod 700 $HOME/.aws

    if [[ -f "${config.sops.secrets.aws_access_key_id.path}" && -f "${config.sops.secrets.aws_secret_access_key.path}" ]]; then
      echo "[default]" > $HOME/.aws/credentials
      echo "aws_access_key_id = $(cat ${config.sops.secrets.aws_access_key_id.path})" >> $HOME/.aws/credentials
      echo "aws_secret_access_key = $(cat ${config.sops.secrets.aws_secret_access_key.path})" >> $HOME/.aws/credentials
      chmod 600 $HOME/.aws/credentials
    fi
  '';
}