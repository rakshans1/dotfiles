#!/bin/bash


packages=(
    vlc
    postman
)

cpackages=(
    code
    sublime-text
    sublime-merge
)

sudo snap install "${packages[@]}"

for package in "${cpackages[@]}"
do
   :
  sudo snap install "${package}" --classic
done

sudo snap install nvim --beta --classic
