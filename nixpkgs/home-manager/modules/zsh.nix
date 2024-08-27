{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      custom = "$HOME/dotfiles/zsh";
      theme = "powerlevel10k/powerlevel10k";
      plugins = [
        "vi-mode"
        "git"
        "git-extras"
        "git-open"
        "zsh-completions"
        "zsh-syntax-highlighting"
        "zsh-autosuggestions"
        "forgit"
        "docker"
        "docker-compose"
        "yarn"
      ];
    };
    initExtra = ''
      source $ZSH_CUSTOM/themes/powerlevel.sh
      source $ZSH_CUSTOM/plugins/zshhighlight.sh

      eval "$(zoxide init zsh --cmd j)"
      export DIRENV_LOG_FORMAT=

      export FZF_DEFAULT_COMMAND='fd --type file --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
        --color=fg:#C6C8D1,bg:#161821,hl:#89b8c2
        --color=fg+:#d2d4de,bg+:#262626,hl+:#95c4ce
        --color=info:#b4be82,prompt:#e27878,pointer:#a093c7
        --color=marker:#c0ca8e,spinner:#ada0d3,header:#84a0c6
      '
      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
      export RIPGREP_CONFIG_PATH=~/.ripgreprc

      export MANPAGER='sh -c "col -bx | bat --language=man --style=grid --color=always --decorations=always --theme='"'Monokai Extended Light'"'"'

      for file in $HOME/dotfiles/shell/{shell_aliases,shell_functions}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
      done;
      unset file;

      # Load the shell dotfiles
      for file in $HOME/dotfiles/shell/work/{work_aliases,work_functions}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
      done;
      unset file;

      export EDITOR='vim'

      export KEYTIMEOUT=1

      stty stop undef
      stty start undef

      # partial history expansion in vim mode
      bindkey "^P" up-line-or-search
      bindkey "^N" down-line-or-search
      bindkey "^h" backward-kill-word
      bindkey "^J" end-of-line
    '';
  };

}
