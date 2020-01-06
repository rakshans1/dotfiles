#!/bin/bash

if [  -f "~/.nvm/nvm.sh" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
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
    gitmoji-cli
    splash-cli
)

npm install -g "${packages[@]}"
