#!/usr/bin/env bash

echo -e "\\n\\nCreating vim symlinks"
VIMFILES=( "$HOME/.vim:~/dotfiles/config/nvim"
        "$HOME/.vimrc:~/dotfiles/config/nvim/init.vim" )

for file in "${VIMFILES[@]}"; do
    KEY=${file%%:*}
    VALUE=${file#*:}
    if [ -e "${KEY}" ]; then
        echo "${KEY} already exists... skipping."
    else
        echo "Creating symlink for $KEY"
        echo $VALUE
        ln -s "${VALUE}" "${KEY}"
    fi
done
