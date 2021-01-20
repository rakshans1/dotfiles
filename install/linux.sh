#!/bin/bash

# Installs some of the common dependencies needed/desired for software development

# Ask for the administrator password upfront
sudo -v

# sudo apt-get update

# sudo apt-get -y upgrade
sudo apt-get -qq install jq > /dev/null 2>&1


apt_keys=()
apt_source_files=()
apt_source_texts=()
apt_packages=()
deb_installed=()
deb_sources=()

installers_path="cache"

# Ubuntu distro release name, eg. "xenial"
release_name=$(lsb_release -c | awk '{print $2}')


function add_ppa() {
  apt_source_texts+=($1)
  IFS=':/' eval 'local parts=($1)'
  apt_source_files+=("${parts[1]}-ubuntu-${parts[2]}-$release_name")
}

#############################
# WHAT DO WE NEED TO INSTALL?
#############################

# Misc.



apt_packages+=(
  apt-transport-https
  build-essential
  checkinstall
  libssl-dev
  curl
  git
  autojump
  imagemagick
  vim
  vsftpd
  guake
  xclip
  tmux
  transmission
  dconf-editor
)

# https://github.com/oguzhaninan/Stacer
# add_ppa ppa:oguzhaninan/stacer
# apt_packages+=(stacer)

# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
add_ppa ppa:papirus/papirus
apt_packages+=(papirus-icon-theme)

# https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04
# add_ppa ppa:webupd8team/java
# apt_packages+=(oracle-java8-installer)

# https://www.ubuntuupdates.org/ppa/google_chrome
apt_keys+=(https://dl-ssl.google.com/linux/linux_signing_key.pub)
apt_source_files+=(google-chrome)
apt_source_texts+=("deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main")
apt_packages+=(google-chrome-stable)


# https://yarnpkg.com/en/docs/install
apt_keys+=(https://dl.yarnpkg.com/debian/pubkey.gpg)
apt_source_files+=(yarn)
apt_source_texts+=("deb https://dl.yarnpkg.com/debian/ stable main")
apt_packages+=(yarn)

# https://tecadmin.net/install-oracle-virtualbox-on-ubuntu/
# apt_keys+=(https://www.virtualbox.org/download/oracle_vbox_2016.asc)
# apt_source_files+=(virtualbox)
# apt_source_texts+=("deb http://download.virtualbox.org/virtualbox/debian $release_name contrib")
# apt_packages+=(virtualbox-5.1)


# https://github.com/sharkdp/bat
deb_installed+=(bat)
batversion="$(curl -s "https://api.github.com/repos/sharkdp/bat/releases/latest" | jq -r .tag_name | sed 's/v//')" 
deb_sources+=('https://github.com/sharkdp/bat/releases/latest/download/bat_'$batversion'_amd64.deb')

# https://github.com/sharkdp/fd
deb_installed+=(fd)
fdversion="$(curl -s "https://api.github.com/repos/sharkdp/fd/releases/latest" | jq -r .tag_name | sed 's/v//')" 
deb_sources+=('https://github.com/sharkdp/fd/releases/latest/download/fd_'$fdversion'_amd64.deb')


# https://github.com/sharkdp/pastel
deb_installed+=(pastel)
pastelversion="$(curl -s "https://api.github.com/repos/sharkdp/pastel/releases/latest" | jq -r .tag_name | sed 's/v//')" 
deb_sources+=('https://github.com/sharkdp/pastel/releases/latest/download/pastel_'$pastelversion'_amd64.deb')

# https://github.com/sharkdp/vivid
deb_installed+=(vivid)
vividversion="$(curl -s "https://api.github.com/repos/sharkdp/vivid/releases/latest" | jq -r .tag_name | sed 's/v//')" 
deb_sources+=('https://github.com/sharkdp/vivid/releases/latest/download/vivid_'$vividversion'_amd64.deb')

# https://github.com/BurntSushi/ripgrep
deb_installed+=(ripgrep)
rgversion="$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | jq -r .tag_name)"
deb_sources+=('https://github.com/BurntSushi/ripgrep/releases/download/'$rgversion'/ripgrep_'$rgversion'_amd64.deb')

# https://github.com/dandavison/delta
deb_installed+=(delta)
deltaversion="$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | jq -r .tag_name)"
deb_sources+=('https://github.com/dandavison/delta/releases/download/'$deltaversion'/git-delta_'$deltaversion'_amd64.deb')

# https://github.com/muesli/duf
deb_installed+=(duf)
dufversion="$(curl -s "https://api.github.com/repos/muesli/duf/releases/latest" | jq -r .tag_name | sed 's/v//')"
deb_sources+=('https://github.com/muesli/duf/releases/latest/download/duf_'$dufversion'_linux_amd64.deb')

# https://github.com/charmbracelet/glow
deb_installed+=(glow)
glowversion="$(curl -s "https://api.github.com/repos/charmbracelet/glow/releases/latest" | jq -r .tag_name | sed 's/v//')"
deb_sources+=('https://github.com/charmbracelet/glow/releases/latest/download/duf_'$glowversion'_linux_amd64.deb')


####################
# ACTUALLY DO THINGS
####################


# Add APT keys.


if (( ${#apt_keys[@]} > 0 )); then
	for key in "${apt_keys[@]}"; do
		wget -qO - $key | sudo apt-key add - > /dev/null 2>&1
	done
fi

###############################################################################
# Functions                                                                    #
###############################################################################
# Logging stuff.
function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;34m➜\033[0m  $@"; }

function array_filter() { __array_filter 1 "$@"; }
# Works like array_filter, but outputs array indices instead of array items.
function array_filter_i() { __array_filter 0 "$@"; }
# The core function. Wheeeee.
function __array_filter() {
  local __i__ __val__ __mode__ __arr__
  __mode__=$1; shift; __arr__=$1; shift
  for __i__ in $(eval echo "\${!$__arr__[@]}"); do
    __val__="$(eval echo "\${$__arr__[__i__]}")"
    if [[ "$1" ]]; then
      "$@" "$__val__" $__i__ >/dev/null
    else
      [[ "$__val__" ]]
    fi
    if [[ "$?" == 0 ]]; then
      if [[ $__mode__ == 1 ]]; then
        eval echo "\"\${$__arr__[__i__]}\""
      else
        echo $__i__
      fi
    fi
  done
}
# Given strings containing space-delimited words A and B, "setdiff A B" will
# return all words in A that do not exist in B. Arrays in bash are insane
# (and not in a good way).
# From http://stackoverflow.com/a/1617303/142339
function setdiff() {
  local debug skip a b
  if [[ "$1" == 1 ]]; then debug=1; shift; fi
  if [[ "$1" ]]; then
    local setdiff_new setdiff_cur setdiff_out
    setdiff_new=($1); setdiff_cur=($2)
  fi
  setdiff_out=()
  for a in "${setdiff_new[@]}"; do
    skip=
    for b in "${setdiff_cur[@]}"; do
      [[ "$a" == "$b" ]] && skip=1 && break
    done
    [[ "$skip" ]] || setdiff_out=("${setdiff_out[@]}" "$a")
  done
  [[ "$debug" ]] && for a in setdiff_new setdiff_cur setdiff_out; do
    echo "$a ($(eval echo "\${#$a[*]}")) $(eval echo "\${$a[*]}")" 1>&2
  done
  [[ "$1" ]] && echo "${setdiff_out[@]}"
}

function contains() {
    local seeking=$1
    shift
    local array=$@
    for v in ${array[@]}; do
        if [ "$v" == "$seeking" ]; then
            return 0;
        fi
    done
   return 1;
}
###############################################################################
#                                                                     #
###############################################################################


# Add APT sources.
function __temp() { [[ ! -e /etc/apt/sources.list.d/$1.list ]]; }
source_i=($(array_filter_i apt_source_files __temp))

if (( ${#source_i[@]} > 0 )); then
  e_header "Adding APT sources (${#source_i[@]})"
  for i in "${source_i[@]}"; do
    source_file=${apt_source_files[i]}
    source_text=${apt_source_texts[i]}
    if [[ "$source_text" =~ ppa: ]]; then
      e_arrow "$source_text"
      sudo add-apt-repository -y $source_text > /dev/null 2>&1
    else
      echo "$source_file"
      sudo sh -c "echo '$source_text' > /etc/apt/sources.list.d/$source_file.list"
    fi
  done
fi

# Update APT.
e_header "Updating APT"
sudo apt-get -qq update


# Upgrade APT.
e_header "Upgrading APT"
sudo apt-get -qq -y upgrade > /dev/null 2>&1


# Install APT packages.
installed_apt_packages="$(dpkg --get-selections | grep -v deinstall | awk 'BEGIN{FS="[\t:]"}{print $1}' | uniq)"
apt_packages=($(setdiff "${apt_packages[*]}" "$installed_apt_packages"))


if (( ${#apt_packages[@]} > 0 )); then
  e_header "Installing APT packages (${#apt_packages[@]})"
  for package in "${apt_packages[@]}"; do
    e_arrow "$package"
    [[ "$(type -t preinstall_$package)" == function ]] && preinstall_$package
    sudo apt-get -qq install "$package" > /dev/null 2>&1 && \
    [[ "$(type -t postinstall_$package)" == function ]] && postinstall_$package
  done
fi

# Install debs via dpkg
function __temp() { [[ ! -e "$1" ]]; }
deb_installed_filter=($(setdiff "${deb_installed[*]}" "$installed_apt_packages"))
deb_installed_i=($(array_filter_i deb_installed __temp))

if (( ${#deb_installed_i[@]} > 0 )); then
  mkdir -p "$installers_path"
  e_header "Installing debs (${#deb_installed_filter[@]})"
  for i in "${deb_installed_i[@]}"; do
    if ! contains ${deb_installed[i]} ${deb_installed_filter[@]}; then
      continue
    fi
    e_arrow "${deb_installed[i]}"
    deb="${deb_sources[i]}"
    [[ "$(type -t "$deb")" == function ]] && deb="$($deb)"
    installer_file="$installers_path/$(echo "$deb" | sed 's#.*/##')"
    wget -q  -O "$installer_file" "$deb"
    sudo dpkg -i "$installer_file" > /dev/null 2>&1
  done
fi


rm -rf "$installers_path"
