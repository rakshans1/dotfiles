{ config, lib, pkgs, private, ... }:

{
  # AWS Configuration Management
  # Manages ~/.aws/config and ~/.aws/credentials files via Home Manager

  home.file.".aws/config".text = ''
    [default]
    region = ap-south-1
    output = json

    # Add additional profiles here as needed:
    # [profile dev]
    # region = us-west-2
    # output = json
    #
    # [profile staging]
    # region = eu-west-1
    # output = json
  '';

    # Use activation script to create credentials file with actual secret values
  home.activation.awsCredentials = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.aws
    $DRY_RUN_CMD chmod 700 $HOME/.aws

    # Create credentials file with actual secret values
    if [[ -f "${config.sops.secrets.aws_access_key_id.path}" && -f "${config.sops.secrets.aws_secret_access_key.path}" ]]; then
      $DRY_RUN_CMD cat > $HOME/.aws/credentials << EOF
[default]
aws_access_key_id = $(cat ${config.sops.secrets.aws_access_key_id.path})
aws_secret_access_key = $(cat ${config.sops.secrets.aws_secret_access_key.path})

# Add additional credential profiles here as needed:
# [dev]
# aws_access_key_id = REPLACE_WITH_DEV_KEY_ID
# aws_secret_access_key = REPLACE_WITH_DEV_SECRET_KEY
EOF

      $DRY_RUN_CMD chmod 600 $HOME/.aws/credentials
    else
      echo "Warning: AWS secret files not found, skipping credentials file creation"
    fi
  '';
}
