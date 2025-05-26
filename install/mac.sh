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
  chrome-cli
)

brew install --cask "${casks[@]}"


apps=(
  # WhatsApp Messenger
  "310633997"
)

mas install "${apps[@]}"
