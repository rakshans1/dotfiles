{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Static keys managed by Nix. Codex's runtime-written sections
  # (e.g. [projects.*], [marketplaces.*], [notice.*], [plugins.*])
  # are left untouched by the per-key dasel puts below unless overlaid by
  # the optional private overlay.
  #
  # Each entry: path = { type = "string|bool|int"; value = ...; }
  managed = {
    "model" = { type = "string"; value = "gpt-5.5"; };
    "personality" = { type = "string"; value = "pragmatic"; };
    "model_reasoning_effort" = { type = "string"; value = "xhigh"; };
    "sandbox_mode" = { type = "string"; value = "workspace-write"; };
    "check_for_update_on_startup" = { type = "bool"; value = false; };

    "tui.vim_mode_default" = { type = "bool"; value = true; };

    "features.hooks" = { type = "bool"; value = true; };
    "features.codex_git_commit" = { type = "bool"; value = false; };
    "features.multi_agent" = { type = "bool"; value = true; };
    "features.js_repl" = { type = "bool"; value = false; };

    "shell_environment_policy.experimental_use_profile" = { type = "bool"; value = true; };

    "desktop.conversationDetailMode" = { type = "string"; value = "STEPS_COMMANDS"; };
    "desktop.open-in-target-preferences.global" = { type = "string"; value = "sublimeText"; };
  };

  renderValue = v: if builtins.isBool v then (if v then "true" else "false") else toString v;

  putCommands = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      path: spec:
      ''${pkgs.dasel}/bin/dasel put -f "$CONFIG" -r toml -t ${spec.type} -v '${renderValue spec.value}' '${path}' ''
    ) managed
  );

  pruneCommands = ''
    if ${pkgs.dasel}/bin/dasel -f "$CONFIG" -r toml 'features.codex_hooks' >/dev/null 2>&1; then
      ${pkgs.dasel}/bin/dasel delete -f "$CONFIG" -r toml -w toml -o "$CONFIG.pruned" 'features.codex_hooks'
      mv "$CONFIG.pruned" "$CONFIG"
    fi
  '';
in
{
  home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.codex
    CONFIG=$HOME/.codex/config.toml
    [ -f "$CONFIG" ] || : > "$CONFIG"

    ${putCommands}
    ${pruneCommands}

    # Merge in optional private overlay (org-specific marketplaces + plugins).
    # The overlay file is kept in the private dotfiles repo; if absent, nothing
    # happens. Keeps any org-private URLs out of this public file.
    OVERLAY=$HOME/dotfiles/private/extras/codex.toml
    if [ -r "$OVERLAY" ]; then
      ${pkgs.yq}/bin/tomlq -s -t '.[0] * .[1]' \
        "$CONFIG" "$OVERLAY" \
        > "$CONFIG.merged"
      mv "$CONFIG.merged" "$CONFIG"
    fi

    chmod 600 "$CONFIG"
    echo "Successfully applied managed Codex configuration"
  '';
}
