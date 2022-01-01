#!/bin/bash


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
