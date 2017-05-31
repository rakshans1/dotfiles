#!/bin/bash
###############################################################################
# Linux                                                                    #
###############################################################################






# $HOME/dotfiles/install/linux.sh


###############################################################################
# Node                                                                        #
###############################################################################

# Installing Node
# https://github.com/nodesource/distributions#debinstall
https://github.com/nodesource/distributions#debinstall
sudo apt-get install -y nodejs

$HOME/dotfiles/install/npm.sh


###############################################################################
# Symlinks to link dotfiles into ~/                                           #
###############################################################################

./setup.sh
