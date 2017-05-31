#!/bin/sh

#
# This script configures my Node.js development setup.


packages=(
    http-server
    webpack
    nodemon
)

npm install -g "${packages[@]}