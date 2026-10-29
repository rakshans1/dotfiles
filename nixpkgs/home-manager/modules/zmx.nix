{ pkgs, ... }:
# zmx: per-session terminal persistence (one tiny daemon per session), the
# process layer replacing tmux (docs/tmux-to-ghostty-zmx-plan.md, P2).
# Coexists with tmux: nothing here runs unless a shell lives inside zmx.
# The package is pinned on purpose, see ./zmx/default.nix.
let
  zmx = pkgs.callPackage ./zmx { };
in
{
  # Ships share/zsh/site-functions/_zmx, picked up from the profile's fpath
  home.packages = [ zmx ];

  # ctrl+\ would detach (and it steals nvim's <C-\><C-n>); detach by closing
  # the split or `zmx detach` instead.
  home.sessionVariables.ZMX_NO_DETACH_KEY = "1";

  programs.zsh.initContent = ''
    # zmx: only inside a session (ZMX_SESSION is set by zmx)
    if [[ -n "$ZMX_SESSION" ]]; then
      # Client env (SSH_AUTH_SOCK, ...) goes stale across re-attaches: refresh
      # it from the attached client before each prompt.
      autoload -Uz add-zsh-hook
      _zmx_env_hook() { eval "$(zmx print-env -s . 2>/dev/null)" }
      add-zsh-hook precmd _zmx_env_hook

      # p10k right-prompt segment with the session name (p10k reads its
      # elements at the first prompt, so appending here is enough).
      prompt_zmx_session() { p10k segment -b 232 -f 110 -t "$ZMX_SESSION" }
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(zmx_session)
    fi
  '';
}
