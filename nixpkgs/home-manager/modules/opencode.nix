{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Static config managed by Nix. opencode's runtime-written keys (theme
  # tweaks, last-used model, etc.) are preserved by the deep merge below
  # unless they overlap with these keys.
  #
  # The z.ai (GLM) provider is Anthropic wire-compatible, so it loads the
  # @ai-sdk/anthropic SDK and points at z.ai's Anthropic endpoint. The API
  # key is resolved at runtime from $ZAI_API_KEY (exported by zsh-env from
  # sops) via opencode's {env:...} interpolation — no secret in this file.
  managed = {
    "$schema" = "https://opencode.ai/config.json";
    autoupdate = false; # binary is managed read-only by Nix; self-update can't work
    provider = {
      zai = {
        npm = "@ai-sdk/anthropic";
        name = "z.ai (GLM)";
        options = {
          baseURL = "https://api.z.ai/api/anthropic";
          apiKey = "{env:ZAI_API_KEY}";
        };
        models = {
          "glm-5.2" = { name = "GLM 5.2"; };
          "glm-4.7" = { name = "GLM 4.7"; };
          "glm-4.7-flash" = { name = "GLM 4.7 Flash"; };
        };
      };
    };
    model = "zai/glm-5.2";
    small_model = "zai/glm-4.7-flash";
  };

  managedJson = builtins.toJSON managed;
in
{
  # Apply managed opencode settings without replacing runtime-written keys.
  home.activation.opencodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.config/opencode

    CONFIG=$HOME/.config/opencode/opencode.json
    [ -f "$CONFIG" ] || printf '{}\n' > "$CONFIG"

    ${pkgs.jq}/bin/jq --argjson managed '${managedJson}' '. * $managed' \
      "$CONFIG" > "$CONFIG.merged"
    mv "$CONFIG.merged" "$CONFIG"

    chmod 644 "$CONFIG"
    echo "Successfully applied managed opencode configuration"
  '';
}
