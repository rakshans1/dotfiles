#!/bin/bash


cd ~/
git clone https://github.com/creationix/nvm.git .nvm
cd ~/.nvm
git checkout v0.33.11
. ./nvm.sh
nvm install node
nvm use node


packages=(
    http-server
    nodemon
    gulp
    typescript
    diff-so-fancy
    tldr
    fkill-cli
    gitmoji-cli
)

npm install -g "${packages[@]}"
