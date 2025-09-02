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
      strip_trailing_spaces = "smart";
      term = "xterm-256color";
      scrollback_lines = 10000;
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

      # Iceberg Dark Theme
      background = "#161821";
      foreground = "#c6c8d1";

      selection_background = "#1e2132";
      selection_foreground = "#c6c8d1";

      cursor = "#d2d4de";

      # Terminal colors
      color0 = "#161821";  # black
      color8 = "#6b7089";  # bright black
      color1 = "#e27878";  # red
      color9 = "#e98989";  # bright red
      color2 = "#b4be82";  # green
      color10 = "#c0ca8e"; # bright green
      color3 = "#e2a478";  # yellow
      color11 = "#e9b189"; # bright yellow
      color4 = "#84a0c6";  # blue
      color12 = "#91acd1"; # bright blue
      color5 = "#a093c7";  # magenta
      color13 = "#ada0d3"; # bright magenta
      color6 = "#89b8c2";  # cyan
      color14 = "#95c4ce"; # bright cyan
      color7 = "#c6c8d1";  # white
      color15 = "#d2d4de"; # bright white

      # Tab bar colors
      active_tab_foreground = "#161821";
      active_tab_background = "#84a0c6";
      inactive_tab_foreground = "#d2d4de";
      inactive_tab_background = "#353a50";
      tab_bar_background = "#0f1117";
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