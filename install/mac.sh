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
  watch
  stats
  vivid
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
)

brew install --cask "${casks[@]}"
