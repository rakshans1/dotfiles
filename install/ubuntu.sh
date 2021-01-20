# General Settings
gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru' 
gsettings set org.gnome.desktop.interface font-name 'FiraCOde NF 11'
gsettings set org.gnome.desktop.interface document-font-name 'FiraCOde NF 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'FiraCode Nerd Font Mono 11'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
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
gsettings set org.gnome.desktop.interface enable-hot-corners true


# App Settings

# Guake
gsettings set guake.general default-shell '/usr/bin/zsh'
gsettings set guake.general window-tabbar false
gsettings set guake.general window-ontop true
gsettings set guake.general start-at-login true
gsettings set guake.general use-popup false
gsettings set guake.general start-fullscreen true
gsettings set guake.keybindings.global show-hide 'F1'
gsettings set guake.keybindings.local toggle-fullscreen 'F2'
gsettings set guake.style.background transparency 100
gsettings set guake.style.font palette '#000000000000:#cccc00000000:#4e4e9a9a0606:#c4c4a0a00000:#34346565a4a4:#757550507b7b:#060698209a9a:#d3d3d7d7cfcf:#555557575353:#efef29292929:#8a8ae2e23434:#fcfce9e94f4f:#72729f9fcfcf:#adad7f7fa8a8:#3434e2e2e2e2:#eeeeeeeeecec:#ffffffffffff:#161518172121'

# CAPS>ESC
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
