#!/bin/sh

# Ask for the administrator password upfront
sudo -v
apt-get -qq -y install gnome-tweak-tool gir1.2-gtop-2.0 gir1.2-networkmanager-1.0  gir1.2-clutter-1.0

sudo wget -O /usr/local/bin/gnomeshell-extension-manage "https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnomeshell-extension-manage"
sudo chmod +x /usr/local/bin/gnomeshell-extension-manage

#user themes
# gnomeshell-extension-manage --install --extension-id 19 --user

# Net Speed 
gnomeshell-extension-manage --install --extension-id 104 --user --version latest

# Refresh Wifi Connections  
gnomeshell-extension-manage --install --extension-id 905 --user

# Sound Input & Output Device Chooser  
gnomeshell-extension-manage --install --extension-id 906 --user

# Bluetooth quick connect
gnomeshell-extension-manage --install --extension-id 1401 --user

# caffeine
gnomeshell-extension-manage --install --extension-id 517 --user
gsettings --schemadir ~/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas set org.gnome.shell.extensions.caffeine restore-state true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas set org.gnome.shell.extensions.caffeine show-notifications false

# system-monitor
gnomeshell-extension-manage --install --extension-id 120 --user
gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/schemas/ set org.gnome.shell.extensions.system-monitor show-tooltip false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/schemas/ set org.gnome.shell.extensions.system-monitor cpu-show-text false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/schemas/ set org.gnome.shell.extensions.system-monitor icon-display false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/schemas/ set org.gnome.shell.extensions.system-monitor fan-show-menu false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/schemas/ set org.gnome.shell.extensions.system-monitor memory-show-text false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/schemas/ set org.gnome.shell.extensions.system-monitor net-display false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/schemas/ set org.gnome.shell.extensions.system-monitor net-show-menu false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/schemas/ set org.gnome.shell.extensions.system-monitor swap-show-menu false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/schemas/ set org.gnome.shell.extensions.system-monitor thermal-show-menu false

#Clipboard Indicator
gnomeshell-extension-manage --install --extension-id 779 --user
gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com/schemas set org.gnome.shell.extensions.clipboard-indicator history-size 100


gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'system-monitor@paradoxxx.zero.gmail.com', 'netspeed@hedayaty.gmail.com','refresh-wifi@kgshank.net', 'bluetooth-quick-connect@bjarosze.gmail.com', 'caffeine@patapon.info', 'clipboard-indicator@tudmotu.com', 'sound-output-device-chooser@kgshank.net']"

# Reload Gnome Shell
# gnome-shell --replace &
