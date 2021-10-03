#!/usr/bin/env bash

git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

nvim --headless -c 'PackerCompile' -c 'qa'
nvim --headless -c 'PackerInstall' -c 'qa'

if python3 -c "import pynvim" &> /dev/null; then
    echo ''
else
    sudo apt-get -qq -y install python3-pip
	pip3 install neovim
	python3 -m pip install --user --upgrade pynvim
fi

