{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      # Font configuration
      font_family = "FiraCode Nerd Font Mono";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size = 14;

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

      # Advanced
      shell_integration = "enabled";
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";

      # macOS specific
      macos_option_as_alt = "yes";
      macos_quit_when_last_window_closed = "yes";
      macos_window_resizable = "yes";
      macos_traditional_fullscreen = "no";
      macos_hide_titlebar = "yes";
    };

    keybindings = {
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