#!/bin/bash

if [ ! -d ~/.asdf ]; then
  print_info "Installing asdf"
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
fi

reload_zsh
asdf update
