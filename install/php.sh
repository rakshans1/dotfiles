#!/bin/bash

# Installs Apache Php Mysql and phpmyadmin for php development.

# Ask for the administrator password upfront
sudo -v

apt_packages=()


# Ubuntu distro release name, eg. "xenial"
release_name=$(lsb_release -c | awk '{print $2}')

# Variables
DBUSER=root
DBPASSWD=root

#############################
# Adding Settings
#############################
#localhost phpmyadmin username : phpmyadmin password: root


echo "mysql-server mysql-server/root_password password $DBPASSWD" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | sudo debconf-set-selections


#############################
# WHAT DO WE NEED TO INSTALL?
#############################
apt_packages+=(
  apache2
  mysql-server-5.6
  php7.0
  libapache2-mod-php
  php-mcrypt
  php7.0-mysql
  phpmyadmin
)

####################
# ACTUALLY DO THINGS
####################

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
###############################################################################
#                                                                     #
###############################################################################

# Update APT.
e_header "Updating APT"
# sudo apt-get -qq update

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

# Enabling Rewrite.
sudo a2enmod rewrite > /dev/null 2>&1

# Configure Phpmyadmin
e_header "Configure Apache to use phpmyadmin"

sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# # Configure Apache
# e_header "Configure Apache"
# cat > /etc/apache2/sites-enabled/000-default.conf << "EOF"
# <VirtualHost *:80>
#     DocumentRoot /var/www
#     ErrorLog \${APACHE_LOG_DIR}/error.log
#     CustomLog \${APACHE_LOG_DIR}/access.log combined
# </VirtualHost>
# EOF

# Installing Composer
e_header "Installing Composer for PHP package management"
curl --silent https://getcomposer.org/installer | php > /dev/null 2>&1
sudo mv composer.phar /usr/local/bin/composer

sudo a2dismod mpm_event > /dev/null 2>&1
sudo a2enmod mpm_prefork > /dev/null 2>&1
sudo a2enmod php7.0 > /dev/null 2>&1

e_header "Restarting Apache"
sudo service apache2 restart > /dev/null 2>&1