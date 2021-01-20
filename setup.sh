#!/bin/bash
############################

# This symlinks all the dotfiles to ~/


############################

########## Support Functions

answer_is_yes() {
  [[ "$REPLY" =~ ^[Yy]$ ]] \
    && return 0 \
    || return 1
}

ask() {
  print_question "$1"
  read
}

ask_for_confirmation() {
  print_question "$1 (y/n) "
  read -n 1
  printf "\n"
}

ask_for_sudo() {

  # Ask for the administrator password upfront
  sudo -v

  # Update existing `sudo` time stamp until this script has finished
  # https://gist.github.com/cowboy/3118588
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &> /dev/null &

}

cmd_exists() {
  [ -x "$(command -v "$1")" ] \
    && printf 0 \
    || printf 1
}

execute() {
  $1 &> /dev/null
  print_result $? "${2:-$1}"
}

get_answer() {
  printf "$REPLY"
}

get_os() {

  declare -r OS_NAME="$(uname -s)"
  local os=""

  if [ "$OS_NAME" == "Darwin" ]; then
    os="osx"
  elif [ "$OS_NAME" == "Linux" ] && [ -e "/etc/lsb-release" ]; then
    os="ubuntu"
  fi

  printf "%s" "$os"

}
mkd() {
  if [ -n "$1" ]; then
    if [ -e "$1" ]; then
      if [ ! -d "$1" ]; then
        print_error "$1 - a file with the same name already exists!"
      else
        print_success "$1"
      fi
    else
      execute "mkdir -p $1" "$1"
    fi
  fi
}

print_error() {
  # Print output in red
  printf "\e[0;31m  [✖] $1 $2\e[0m\n"
}

print_info() {
  # Print output in purple
  printf "\n\e[0;35m $1\e[0m\n\n"
}

print_question() {
  # Print output in yellow
  printf "\e[0;33m  [?] $1\e[0m"
}

print_result() {
  [ $1 -eq 0 ] \
    && print_success "$2" \
    || print_error "$2"

  [ "$3" == "true" ] && [ $1 -ne 0 ] \
    && exit
}

print_success() {
  # Print output in green
  printf "\e[0;32m  [✔] $1\e[0m\n"
}

# Warn user this script will overwrite current dotfiles
while true; do
  read -p "Warning: this will overwrite your current dotfiles. Continue? [y/n] " yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
  esac
done

# Get the dotfiles directory's absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"


dir=~/dotfiles                        # dotfiles directory

# Get current dir (so run this script from anywhere)

export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change to the dotfiles directory
echo -n "Changing to the $dir directory..."
cd $dir
echo "done"

#
# Actual symlink stuff
#

declare -a FILES_TO_SYMLINK=(
  'shell/zshrc'
  'shell/tmux.conf'

  'git/gitconfig'
  'git/gitignore'

  'rc/javascript/eslintrc'
  'rc/ripgreprc'

  'shell/tmux'
)


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

  local i=''
  local sourceFile=''
  local targetFile=''

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  for i in ${FILES_TO_SYMLINK[@]}; do

    sourceFile="$(pwd)/$i"
    targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

    if [ ! -e "$targetFile" ]; then
      execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
    elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
      print_success "$targetFile → $sourceFile"
    else
      ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
      if answer_is_yes; then
        rm -rf "$targetFile"
        execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
      else
        print_error "$targetFile → $sourceFile"
      fi
    fi

  done

  unset FILES_TO_SYMLINK

  echo -e "\\n\\ninstalling to ~/.config"
  echo "=============================="
  if [ ! -d "$HOME/.config" ]; then
      echo "Creating ~/.config"
      mkdir -p "$HOME/.config"
  fi

  config_files=$(ls -d ~/dotfiles/config/*)
  for config in $config_files; do
      target="$HOME/.config/$( basename "$config" )"
      echo $target
      if [ -e "$target" ]; then
          echo "~${target#$HOME} already exists... Skipping."
      else
          echo "Creating symlink for $config"
          ln -s "$config" "$target"
      fi
  done
}


install_zsh () {
  # Test to see if zshell is installed.  If it is:
  if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Install Oh My Zsh if it isn't already present
    if [[ ! -d ~/.oh-my-zsh ]]; then
      cd ~ && git clone https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
      chsh -s $(which zsh)
    fi
  else
    # If zsh isn't installed, get the platform of the current machine
    platform=$(uname);
    # If the platform is Linux, try an apt-get to install zsh and then recurse
    if [[ $platform == 'Linux' ]]; then
      if [[ -f /etc/redhat-release ]]; then
        sudo yum install zsh
        install_zsh
      fi
      if [[ -f /etc/debian_version ]]; then
        sudo apt-get -qq install zsh
        install_zsh
      fi
    # If the platform is OS X, tell the user to install zsh :)
    elif [[ $platform == 'Darwin' ]]; then
      echo "We'll install zsh, then re-run this script!"
      brew install zsh
      exit
    fi
  fi
}

setup_linux () {
  ###############################################################################
  # Linux                                                      #
  ###############################################################################
  #ln -s ~/dotfiles/linux/mimeapps.list $HOME/.local/share/applications

  if [ ! -d ~/.local/share/fonts ]; then
    mkdir $HOME/.local/share/fonts
  fi

  if [ ! -d ~/.local/share/fonts/FiraCode ]; then
    echo "Installing Fonts"
    cd /tmp
    wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
    unzip FiraCode.zip -d ~/.local/share/fonts/FiraCode
  fi

  ###############################################################################
  # Caps to Esc                                                                 #
  ###############################################################################
  setxkbmap -option caps:escape
}

setup_mac () {
  brew install zsh
  brew tap homebrew/cask-fonts
  brew install --cask font-fira-code
}



setup () {
  if [ ! -d ~/.fzf ]; then
    print_info "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
  fi
  platform=$(uname);
  if [[ $platform == 'Linux' ]]; then
    setup_linux
  elif [[ $platform == 'Darwin' ]]; then
    setup_mac
  fi
}


main
install_zsh
setup

# Reload zsh settings
#source ~/.zshrc

