packages=(
  fd
  tmux
  ripgrep
  yarn
  zsh
  htop
  bat
  autojump
  jq
  neovim
  wget
  git-delta
  glow
)

brew install "${packages[@]}"

casks=(
  iterm2
  docker
  visual-studio-code
  sublime-text
  sublime-merge
  google-chrome
  dbeaver-community
  postman
  vlc
  mark-text
)

brew install --cask "${casks[@]}"
