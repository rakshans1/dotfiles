#!/bin/sh

sudo wget -O /usr/local/bin/gnomeshell-extension-manage "https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnomeshell-extension-manage"
sudo chmod +x /usr/local/bin/gnomeshell-extension-manage


#user themes
gnomeshell-extension-manage --install --extension-id 19 --user

# Coverflow Alt-Ta
gnomeshell-extension-manage --install --extension-id 97 --user

# Dash to Dock
gnomeshell-extension-manage --install --extension-id 307 --user

# Drop Down Terminal
gnomeshell-extension-manage --install --extension-id 442 --user

# Net Speed 
gnomeshell-extension-manage --install --extension-id 104 --user

# Proxy Switcher 
gnomeshell-extension-manage --install --extension-id 771 --user

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
