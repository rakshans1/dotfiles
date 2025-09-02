{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    localVariables = {
      POWERLEVEL9K_MODE = "nerdfont-complete";

      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = [
        "prompt_char"
        "dir"
        "dir_writable"
        "vcs"
      ];

      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS = [
        "status"
        "command_execution_time"
      ];

      POWERLEVEL9K_SHORTEN_DIR_LENGTH = 1;
      POWERLEVEL9K_SHORTEN_STRATEGY = "truncate_left";
      POWERLEVEL9K_SHORTEN_DELIMITER = "";

      POWERLEVEL9K_PROMPT_CHAR_BACKGROUND = "232";
      POWERLEVEL9K_PROMPT_CHAR_FOREGROUND = "242";

      POWERLEVEL9K_HOST_LOCAL_BACKGROUND = "232";
      POWERLEVEL9K_HOST_LOCAL_FOREGROUND = "242";
      POWERLEVEL9K_HOST_REMOTE_BACKGROUND = "255";
      POWERLEVEL9K_HOST_REMOTE_FOREGROUND = "232";

      POWERLEVEL9K_USER_ICON = "\uF415"; # 
      POWERLEVEL9K_ROOT_ICON = "\u26A1"; # ⚡
      POWERLEVEL9K_HOST_ICON = "\uF109"; # 
      POWERLEVEL9K_HOST_ICON_FOREGROUND = "red";
      POWERLEVEL9K_HOST_ICON_BACKGROUND = "black";
      POWERLEVEL9K_SSH_ICON = "\uF489";  # 

      POWERLEVEL9K_DIR_HOME_BACKGROUND = "232";
      POWERLEVEL9K_DIR_HOME_FOREGROUND = "242";
      POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND = "232";
      POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND = "242";
      POWERLEVEL9K_DIR_DEFAULT_BACKGROUND = "232";
      POWERLEVEL9K_DIR_DEFAULT_FOREGROUND = "242";
      POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_BACKGROUND = "232";
      POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_FOREGROUND = "red";

      POWERLEVEL9K_STATUS_OK_BACKGROUND = "232";
      POWERLEVEL9K_STATUS_ERROR_BACKGROUND = "232";
      POWERLEVEL9K_STATUS_ERROR_FOREGROUND = "red";

      POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND = "232";
      POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND = "magenta";
      POWERLEVEL9K_COMMAND_EXECUTION_TIME_ICON = "\u231A";

      POWERLEVEL9K_VCS_CLEAN_BACKGROUND = "23";
      POWERLEVEL9K_VCS_CLEAN_FOREGROUND = "252";
      POWERLEVEL9K_VCS_MODIFIED_BACKGROUND = "252";
      POWERLEVEL9K_VCS_MODIFIED_FOREGROUND = "23";
      POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND = "252";
      POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND = "23";

      POWERLEVEL9K_HIDE_BRANCH_ICON = true;

    };

    plugins = [
      {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "git-open";
        src = pkgs.fetchFromGitHub {
          owner = "paulirish";
          repo = "git-open";
          rev = "v3.1.0";
          sha256 = "sha256-bZOknoRMkPqm1pFFFbvrHrSi90ANLEE5fLcABYHov6Q=";
        };
        file = "share/git-open/git-open.plugin.zsh";
      }
      {
        name = "zsh-completions";
        src = "${pkgs.zsh-completions}";
      }
      {
        name = "zsh-autosuggestions";
        src = "${pkgs.zsh-autosuggestions}";
      }
      {
        name = "zsh-syntax-highlighting";
        src = "${pkgs.zsh-syntax-highlighting}";
      }
      {
        name = "zsh-forgit";
        src = pkgs.zsh-forgit;
        file = "share/zsh/zsh-forgit/forgit.plugin.zsh";
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "vi-mode"
        "git"
      ];
    };
    initContent = ''
      # SSH
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)"
        ssh-add
      fi
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix
            eval "$(zoxide init zsh --cmd j)"
      export DIRENV_LOG_FORMAT=""

      # Ensure fzf uses reverse layout for all widgets
      export FZF_CTRL_R_OPTS="--layout=reverse"
      export FZF_ALT_C_OPTS="--layout=reverse"

      export RIPGREP_CONFIG_PATH=~/.ripgreprc

      export MANPAGER='sh -c "col -bx | bat --language=man --style=grid --color=always --decorations=always --theme='"'Monokai Extended Light'"'"'

      for file in $HOME/dotfiles/shell/{shell_aliases,shell_functions}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
      done;
      unset file;

      # Load the shell dotfiles
      for file in $HOME/dotfiles/private/{private_aliases,private_functions}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
      done;
      unset file;

      export KEYTIMEOUT=1

      stty stop undef
      stty start undef

      # partial history expansion in vim mode
      bindkey "^P" up-line-or-search
      bindkey "^N" down-line-or-search
      bindkey "^h" backward-kill-word
      bindkey "^J" end-of-line

      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
      ZSH_HIGHLIGHT_PATTERNS+=("rm -rf *" "fg=white,bold,bg=red")
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[path]="fg=white"
      ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=grey"
      ZSH_HIGHLIGHT_STYLES[alias]="fg=30"
      ZSH_HIGHLIGHT_STYLES[builtin]="fg=30"
      ZSH_HIGHLIGHT_STYLES[function]="fg=30"
      ZSH_HIGHLIGHT_STYLES[command]='fg=30'
      ZSH_HIGHLIGHT_STYLES[precommand]='fg=green'
      ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=green'
      ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=yellow"
      ZSH_HIGHLIGHT_STYLES[redirection]="fg=magenta"
      ZSH_HIGHLIGHT_STYLES[bracket-level-1]="fg=30,bold"
      ZSH_HIGHLIGHT_STYLES[bracket-level-2]="fg=green,bold"
      ZSH_HIGHLIGHT_STYLES[bracket-level-3]="fg=magenta,bold"
      ZSH_HIGHLIGHT_STYLES[bracket-level-4]="fg=yellow,bold"
      ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=124"

      export PATH="$HOME/.local/bin:$PATH"

      # Yazi shell wrapper for changing directory when exiting
      # Ref: https://yazi-rs.github.io/docs/quick-start/
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d $'\0' cwd < "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
      }

      # SOPS age key file location for automatic decryption
      export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
      export ANTHROPIC_API_KEY=$(cat ${config.sops.secrets.llm_api_key.path})
      export ANTHROPIC_BASE_URL=$(cat ${config.sops.secrets.llm_endpoint.path})
      export ANTHROPIC_API_ENDPOINT=$(cat ${config.sops.secrets.llm_endpoint.path})
      export OPENAI_API_KEY=$(cat ${config.sops.secrets.llm_api_key.path})
      export OPENAI_API_ENDPOINT=$(cat ${config.sops.secrets.llm_endpoint.path})
      export GEMINI_API_KEY=$(cat ${config.sops.secrets.llm_api_key.path})
      export GEMINI_API_ENDPOINT=$(cat ${config.sops.secrets.llm_endpoint.path})


      # Cursor Agent integration: ensure command start/finish are detected
      # Ref: https://forum.cursor.com/t/cursor-agent-terminal-doesn-t-work-well-with-powerlevel10k-oh-my-zsh/96808
      if [[ -n $CURSOR_TRACE_ID ]]; then
        PROMPT_EOL_MARK=""
        test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"
        precmd() { print -Pn "\e]133;D;%?\a" }
        preexec() { print -Pn "\e]133;C;\a" }
      fi
    '';
  };

}
