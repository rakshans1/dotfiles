packages=(
  stats
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
  transmission
  multipass
)

brew install --cask "${casks[@]}"
