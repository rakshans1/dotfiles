{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Static keys managed by Nix. Codex's runtime-written sections
  # (e.g. [projects.*], [marketplaces.*], [notice.*], [plugins.*])
  # are left untouched by the per-key tomlq setpaths below unless overlaid by
  # the optional private overlay.
  managed = {
    "model" = "gpt-5.5";
    "personality" = "pragmatic";
    "model_reasoning_effort" = "xhigh";
    "sandbox_mode" = "workspace-write";
    "check_for_update_on_startup" = false;

    "tui.vim_mode_default" = true;

    "features.hooks" = true;
    "features.codex_git_commit" = false;
    "features.multi_agent" = true;
    "features.js_repl" = false;

    "shell_environment_policy.experimental_use_profile" = true;
    "shell_environment_policy.set.BROWSER_USE_AVAILABLE_BACKENDS" = "chrome";

    "mcp_servers.node_repl.env.BROWSER_USE_AVAILABLE_BACKENDS" = "chrome";

    "desktop.conversationDetailMode" = "STEPS_COMMANDS";
    "desktop.open-in-target-preferences.global" = "sublimeText";
  };

  # Keys removed from older managed configs.
  pruned = [
    "features.codex_hooks"
    "mcp_servers.chrome-devtools"
  ];

  splitPath = lib.splitString ".";

  managedJson = builtins.toJSON {
    set = lib.mapAttrsToList (path: value: {
      path = splitPath path;
      inherit value;
    }) managed;
    del = map splitPath pruned;
  };

  tomlq = "${pkgs.yq}/bin/tomlq";
in
{
  home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.codex
    CONFIG=$HOME/.codex/config.toml
    [ -f "$CONFIG" ] || : > "$CONFIG"

    ${tomlq} -t --argjson m ${lib.escapeShellArg managedJson} \
      'reduce $m.set[] as $e (. // {}; setpath($e.path; $e.value)) | delpaths($m.del)' \
      "$CONFIG" > "$CONFIG.managed"
    mv "$CONFIG.managed" "$CONFIG"

    # Merge in optional private overlay (org-specific marketplaces + plugins).
    # The overlay file is kept in the private dotfiles repo; if absent, nothing
    # happens. Keeps any org-private URLs out of this public file.
    OVERLAY=$HOME/dotfiles/private/extras/codex.toml
    if [ -r "$OVERLAY" ]; then
      ${tomlq} -s -t '.[0] * .[1]' \
        "$CONFIG" "$OVERLAY" \
        > "$CONFIG.merged"
      mv "$CONFIG.merged" "$CONFIG"
    fi

    chmod 600 "$CONFIG"
    echo "Successfully applied managed Codex configuration"
  '';
}
