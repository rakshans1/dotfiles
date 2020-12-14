#!/bin/bash

if ! [  -f "~/.nvm/nvm.sh" ]; then

  nvmVersion="$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | jq -r .tag_name)" 
  curl -o- 'https://raw.githubusercontent.com/nvm-sh/nvm/'$nvmVersion'/install.sh' | bash
  cd ~/.nvm
  . ./nvm.sh
  nvm install --lts
  nvm use node
  nvm alias default node
fi

packages=(
    http-server
    nodemon
    typescript
    tldr
    splash-cli
    dockerfile-language-server-nodejs
    vscode-css-languageserver-bin
)

npm install -g "${packages[@]}"
