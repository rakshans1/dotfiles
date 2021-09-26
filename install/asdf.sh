#!/bin/bash

if [ ! -d ~/.asdf ];then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
  asdf plugin add nodejs
  asdf install nodejs latest
  asdf global nodejs latest
fi

packages=(
    zx
    http-server
    nodemon
    typescript
    tldr
    splash-cli
    dockerfile-language-server-nodejs
    vscode-css-languageserver-bin
)

npm install -g "${packages[@]}"
