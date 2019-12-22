#!/bin/bash

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
cd ~/.nvm
. ./nvm.sh
nvm install node
nvm use node

packages=(
    http-server
    nodemon
    gulp
    typescript
    tldr
    gitmoji-cli
    splash-cli
)

npm install -g "${packages[@]}"
