{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    
    settings = {
      # Font configuration
      font_family = "JetBrainsMono Nerd Font";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size = 14;
      
      # Window layout
      remember_window_size = "yes";
      initial_window_width = 1200;
      initial_window_height = 800;
      window_padding_width = 10;
      
      # Tab bar
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      
      # Color scheme (One Dark)
      foreground = "#abb2bf";
      background = "#282c34";
      selection_foreground = "#282c34";
      selection_background = "#abb2bf";
      
      # Black
      color0 = "#282c34";
      color8 = "#545862";
      
      # Red
      color1 = "#e06c75";
      color9 = "#e06c75";
      
      # Green
      color2 = "#98c379";
      color10 = "#98c379";
      
      # Yellow
      color3 = "#e5c07b";
      color11 = "#e5c07b";
      
      # Blue
      color4 = "#61afef";
      color12 = "#61afef";
      
      # Magenta
      color5 = "#c678dd";
      color13 = "#c678dd";
      
      # Cyan
      color6 = "#56b6c2";
      color14 = "#56b6c2";
      
      # White
      color7 = "#abb2bf";
      color15 = "#c8ccd4";
      
      # Cursor
      cursor = "#abb2bf";
      cursor_text_color = "#282c34";
      
      # URL underline color when hovering
      url_color = "#61afef";
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
      
      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      
      # Mouse
      mouse_hide_wait = "3.0";
      url_style = "curly";
      open_url_with = "default";
      
      # Terminal bell
      bell_on_tab = "yes";
      
      # Advanced
      shell_integration = "enabled";
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      
      # macOS specific
      macos_option_as_alt = "yes";
      macos_quit_when_last_window_closed = "yes";
      macos_window_resizable = "yes";
      macos_traditional_fullscreen = "no";
    };
    
    keybindings = {
      # Tab management
      "cmd+t" = "new_tab";
      "cmd+w" = "close_tab";
      "cmd+shift+]" = "next_tab";
      "cmd+shift+[" = "previous_tab";
      
      # Window management
      "cmd+n" = "new_window";
      "cmd+shift+n" = "new_os_window";
      
      # Font size
      "cmd+plus" = "change_font_size all +2.0";
      "cmd+minus" = "change_font_size all -2.0";
      "cmd+0" = "change_font_size all 0";
      
      # Copy/paste
      "cmd+c" = "copy_to_clipboard";
      "cmd+v" = "paste_from_clipboard";
      
      # Search
      "cmd+f" = "show_scrollback";
      
      # Clear screen
      "cmd+k" = "clear_terminal reset active";
    };
  };
}