ln -s ~/dotfiles/vim $HOME/.vim
vim +PluginInstall +qall

cd ~/.vim/bundle/YouCompleteMe
git submodule update --init --recursive
./install.sh --js-completer

