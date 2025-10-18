{
  config,
  lib,
  pkgs,
  private,
  ...
}:

{
  # WakaTime configuration managed by Nix with SOPS secrets

  # Generate .wakatime.cfg with SOPS secrets
  home.activation.wakatimeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -f "${config.sops.secrets.wakatime_api_key.path}" ]]; then
      # Read secret at runtime
      API_KEY=$(cat ${config.sops.secrets.wakatime_api_key.path})

      # Generate .wakatime.cfg
      cat > $HOME/.wakatime.cfg <<EOF
[settings]
debug=true
hidefilenames = false
ignore =
    COMMIT_EDITMSG\$
    PULLREQ_EDITMSG\$
    MERGE_MSG\$
    TAG_EDITMSG\$

api_key=$API_KEY
EOF

      chmod 600 $HOME/.wakatime.cfg
      echo "Successfully generated WakaTime configuration"
    fi
  '';
}
