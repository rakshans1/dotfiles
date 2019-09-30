#!/bin/bash


packages=(
    vlc
    postman
)

cpackages=(
    code
    sublime-text
)

sudo snap install "${packages[@]}"

for package in "${cpackages[@]}"
do
   :
  sudo snap install "${package}" --classic
done

