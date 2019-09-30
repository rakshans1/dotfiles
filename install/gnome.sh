#!/bin/sh

# Ask for the administrator password upfront
sudo -v
apt-get -qq -y install gnome-tweak-tool gir1.2-gtop-2.0 gir1.2-networkmanager-1.0  gir1.2-clutter-1.0

sudo wget -O /usr/local/bin/gnomeshell-extension-manage "https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnomeshell-extension-manage"
sudo chmod +x /usr/local/bin/gnomeshell-extension-manage

#user themes
gnomeshell-extension-manage --install --extension-id 19 --user

# Net Speed 
gnomeshell-extension-manage --install --extension-id 104 --user

# Refresh Wifi Connections  
gnomeshell-extension-manage --install --extension-id 905 --user

# Sound Input & Output Device Chooser  
gnomeshell-extension-manage --install --extension-id 906 --user

# system-monitor
gnomeshell-extension-manage --install --extension-id 120 --user

#Clipboard Indicator
gnomeshell-extension-manage --install --extension-id 779 --user

# Reload Gnome Shell
# gnome-shell --replace &
