#!/bin/bash


packages=(

)

cpackages=(
    code
    sublime-text
    webstorm
    intellij-idea-community
)

sudo snap install "${packages[@]}" --classic
sudo snap install "${cpackages[@]}" --classic

