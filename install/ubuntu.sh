# General Settings
gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White' 
gsettings set org.gnome.desktop.interface font-name 'FuraCode Nerd Font 11'
gsettings set org.gnome.desktop.interface document-font-name 'FuraCode Nerd Font 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'FuraCode Nerd Font 11'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Workspace 

# gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-up "['<Super><Shift>Up']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Super><Shift>Right']"
# gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-down "['<Super><Shift>Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Super><Shift>Left']"

gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "['<Super><Shift>Up']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Super><Shift>Right']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "['<Super><Shift>Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Super><Shift>Left']"
gsettings set org.gnome.shell.extensions.dash-to-dock app-shift-hotkey-1 "[]"
gsettings set org.gnome.shell.extensions.dash-to-dock app-shift-hotkey-2 "[]"
gsettings set org.gnome.shell.extensions.dash-to-dock app-shift-hotkey-3 "[]"

gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Shift><Super>exclam']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Shift><Super>at']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Shift><Super>numbersign']"

gsettings set org.gnome.desktop.wm.preferences num-workspaces 3

gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f']"

gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop']"
gsettings set org.gnome.shell enable-hot-corners true


# App Settings

# Guake
# dconf write /apps/guake/keybindings/global/show-hide "'F1'"
# dconf write /apps/guake/keybindings/local/toggle-fullscreen "'F2'"
gsettings set apps.guake.general default-shell '/usr/bin/zsh'
gsettings set apps.guake.general use-popup false
gsettings set apps.guake.general start-fullscreen true
gsettings set apps.guake.keybindings.global show-hide 'F1'
gsettings set apps.guake.keybindings.global toggle-fullscreen 'F2'
