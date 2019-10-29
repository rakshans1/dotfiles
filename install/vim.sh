ln -fs ~/dotfiles/vim $HOME/.vim
vim +PluginInstall +qall

sudo apt-get -y install cmake
cd ~/.vim/bundle/YouCompleteMe
git submodule update --init --recursive
python3 install.py --js-completer


