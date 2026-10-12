{
  config,
  lib,
  pkgs,
  private,
  ...
}:

{
  # AWS configuration files managed by Nix
  # Config is static, credentials are dynamically generated from SOPS secrets

  # AWS CLI calls need an MFA session (Oct 2026): use `aws-vault exec invideo
  # --duration=36h`. The access key lives in the macOS keychain (`aws-vault add
  # invideo`); the profiles below only name the MFA device. `invideo-alt` uses
  # the second authenticator device registered on the IAM user.
  home.packages = [ pkgs.aws-vault ];
  # Keep the key in the login keychain (unlocked at login) rather than a
  # separate aws-vault keychain with its own password.
  home.sessionVariables.AWS_VAULT_KEYCHAIN_NAME = "login";

  home.file.".aws/config".text = ''
    [default]
    region = ap-south-1
    output = json

    [profile invideo]
    region = us-west-2
    mfa_serial = arn:aws:iam::583463116790:mfa/ApplePasswords

    [profile invideo-alt]
    region = us-west-2
    mfa_serial = arn:aws:iam::583463116790:mfa/rakshan
  '';

  # Generate credentials file with SOPS secrets
  home.activation.awsCredentials = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
