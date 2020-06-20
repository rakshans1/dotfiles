#!/bin/bash

#
# This script configures my Node.js development setup.

# Ask for the administrator password upfront
sudo -v

# Installing Node
# https://github.com/nodesource/distributions#debinstall
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

packages=(
    http-server
    nodemon
)

npm install -g "${packages[@]}"
