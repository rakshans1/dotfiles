#!/usr/bin/env bash


nvim --headless -c 'PlugInstall' -c 'qa'


if python3 -c "import pynvim" &> /dev/null; then
    echo ''
else
    sudo apt-get -qq -y install python3-pip
	pip3 install neovim
	python3 -m pip install --user --upgrade pynvim
fi

