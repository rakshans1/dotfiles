{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Note: Sublime Text and Sublime Merge are installed via Homebrew (see darwin configuration)
  # This module only manages configuration files

  # Iceberg color scheme
  home.file."Library/Application Support/Sublime Text/Packages/User/Mariana.sublime-color-scheme" = {
    text = builtins.toJSON {
      variables = {
        # Iceberg color palette
        blue = "#84a0c6";
        cyan = "#89b8c2";
        green = "#b4be82";
        red = "#e27878";
        orange = "#e2a478";
        purple = "#a093c7";
        yellow = "#e2c792";
        fg = "#c6c8d1";
        bg = "#161821";
      };
      globals = {
        background = "#161821";
        foreground = "#c6c8d1";
        caret = "#c6c8d1";
        line_highlight = "#1e2132";
        selection = "#1e2132";
        selection_border = "#272c42";
        inactive_selection = "#1e2132";
        find_highlight = "#e2c792";
        find_highlight_foreground = "#161821";
        guide = "#444b71";
        active_guide = "#6b7089";
        stack_guide = "#444b71";
        brackets_options = "underline";
        brackets_foreground = "#84a0c6";
        bracket_contents_options = "underline";
        bracket_contents_foreground = "#89b8c2";
        tags_options = "stippled_underline";
      };
      rules = [
        {
          name = "Comment";
          scope = "comment";
          foreground = "var(fg)";
          font_style = "italic";
        }
        {
          name = "String";
          scope = "string";
          foreground = "var(green)";
        }
        {
          name = "Number";
          scope = "constant.numeric";
          foreground = "var(purple)";
        }
        {
          name = "Keyword";
          scope = "keyword, storage.modifier, storage.type";
          foreground = "var(blue)";
        }
        {
          name = "Function";
          scope = "entity.name.function, support.function";
          foreground = "var(cyan)";
        }
        {
          name = "Class";
          scope = "entity.name.class, entity.name.type, support.class";
          foreground = "var(cyan)";
        }
        {
          name = "Variable";
          scope = "variable";
          foreground = "var(fg)";
        }
        {
          name = "Constant";
          scope = "constant";
          foreground = "var(purple)";
        }
        {
          name = "Operator";
          scope = "keyword.operator";
          foreground = "var(blue)";
        }
        {
          name = "Punctuation";
          scope = "punctuation";
          foreground = "var(fg)";
        }
      ];
    };
  };

  # Iceberg-themed Default.sublime-theme customization
  home.file."Library/Application Support/Sublime Text/Packages/User/Default.sublime-theme" = {
    text = builtins.toJSON {
      variables = {
        # Iceberg color palette - matching vim colorscheme
        iceberg_bg = "#161821";
        iceberg_bg_light = "#1e2132";
        iceberg_bg_lighter = "#272c42";
        iceberg_bg_selection = "#1e2132";
        iceberg_fg = "#c6c8d1";
        iceberg_fg_dim = "#6b7089";
        iceberg_fg_darker = "#444b71";
        iceberg_blue = "#84a0c6";
        iceberg_cyan = "#89b8c2";
        iceberg_green = "#b4be82";
        iceberg_red = "#e27878";
        iceberg_orange = "#e2a478";
        iceberg_purple = "#a093c7";

        # Core UI
        base_hue = "#161821";
        base_tint = "#6b7089";

        ui_bg = "#0f1117";
        text_fg = "#c6c8d1";
        link_fg = "#84a0c6";

        label_color = "#c6c8d1";
        icon_tint = "#6b7089";
        shape_tint = "#6b7089";

        button_bg = "#1e2132";
        button_label_color = "#c6c8d1";
        button_label_shadow = "transparent";

        # Scrollbars
        scroll_bar_bg = "#161821";
        scroll_bar_puck_bg = "#444b71";
        scroll_bar_dark_bg = "#161821";
        scroll_bar_puck_dark_bg = "#444b71";

        # Sidebar
        sidebar_bg = "#0f1117";
        sidebar_row_selected = "#1e2132";
        sidebar_heading = "#6b7089";
        sidebar_heading_shadow = "transparent";
        sidebar_label = "#c6c8d1";
        sidebar_label_selected = "#c6c8d1";
        sidebar_label_ignored = "#444b71";

        sidebar_button_tint = "#6b7089";
        sidebar_button_new_tint = "#b4be82";
        sidebar_button_modified_tint = "#84a0c6";
        sidebar_button_deleted_tint = "#e27878";

        sidebar_scroll_bar_bg = "#0f1117";
        sidebar_scroll_bar_puck_bg = "#444b71";

        # VCS colors
        vcs_untracked = "#6b7089";
        vcs_modified = "#84a0c6";
        vcs_missing = "#e27878";
        vcs_staged = "#84a0c6";
        vcs_added = "#b4be82";
        vcs_deleted = "#e27878";
        vcs_unmerged = "#e2a478";

        # Panels
        panel_bg = "#0f1117";
        progress_bar_bg = "#1e2132";
        progress_bar_fg = "#84a0c6";

        # Dialogs
        dialog_bg = "#161821";
        dialog_button_bg = "#1e2132";

        # Tabs
        tabset_dark_tint_mod = "transparent";
        tabset_medium_dark_tint_mod = "transparent";
        tabset_medium_tint_mod = "transparent";
        tabset_light_tint_mod = "transparent";

        tabset_dark_bg = "#0f1117";
        tabset_medium_dark_bg = "#0f1117";
        tabset_medium_bg = "#0f1117";
        tabset_light_bg = "#0f1117";

        file_tab_selected_dark_tint = "transparent";
        file_tab_selected_medium_dark_tint = "transparent";
        file_tab_selected_medium_tint = "transparent";
        file_tab_selected_light_tint = "transparent";

        file_tab_angled_unselected_dark_tint = "#1e2132";
        file_tab_angled_unselected_medium_dark_tint = "#1e2132";
        file_tab_angled_unselected_medium_tint = "#1e2132";
        file_tab_angled_unselected_light_tint = "#1e2132";

        file_tab_angled_unselected_label_color = "#6b7089";
        file_tab_angled_unselected_label_shadow = "transparent";
        file_tab_angled_unselected_medium_label_color = "#6b7089";
        file_tab_angled_unselected_medium_label_shadow = "transparent";
        file_tab_angled_unselected_light_label_color = "#6b7089";
        file_tab_angled_unselected_light_label_shadow = "transparent";

        file_tab_unselected_label_color = "#6b7089";
        file_tab_unselected_light_label_color = "#6b7089";
        file_tab_selected_label_color = "#c6c8d1";
        file_tab_selected_light_label_color = "#c6c8d1";

        file_tab_highlight_new_tint = "#b4be82";
        file_tab_highlight_deleted_tint = "#e27878";

        file_tab_close_dark_tint = "#6b7089";
        file_tab_close_light_tint = "#6b7089";

        # Sheets
        sheet_dark_modifier = "transparent";
        sheet_medium_dark_modifier = "transparent";
        sheet_medium_modifier = "transparent";
        sheet_light_modifier = "transparent";

        # Status bar
        status_bar_bg = "#0f1117";
        status_bar_label_color = "#c6c8d1";
        status_bar_icon_tint = "#6b7089";
        status_bar_label_shadow = "transparent";

        # Overlays
        overlay_bg = "#161821";

        quick_panel_label_color = "#c6c8d1";
        quick_panel_path_label_color = "#6b7089";
        quick_panel_matched_label_color = "#84a0c6";
        quick_panel_matched_path_label_color = "#84a0c6";

        quick_panel_selected_row_bg = "#1e2132";
        quick_panel_selected_label_color = "#c6c8d1";
        quick_panel_selected_path_label_color = "#6b7089";
        quick_panel_selected_matched_label_color = "#84a0c6";
        quick_panel_selected_matched_path_label_color = "#84a0c6";

        quick_panel_link_color = "#84a0c6";

        # Autocomplete
        auto_complete_bg_dark_tint = "#161821";
        auto_complete_bg_light_tint = "#161821";
        auto_complete_selected_row_dark_tint = "#1e2132";
        auto_complete_selected_row_light_tint = "#1e2132";

        # Tool tips
        tool_tip_bg = "#1e2132";
        tool_tip_fg = "#c6c8d1";

        # Checkboxes and radio buttons
        radio_back = "#161821";
        radio_border-unselected = "#444b71";
        radio_selected = "#84a0c6";
        radio_border-selected = "#84a0c6";

        checkbox_back = "#161821";
        checkbox_border-unselected = "#444b71";
        checkbox_selected = "#84a0c6";
        checkbox_border-selected = "#84a0c6";
        checkbox-disabled = "#444b71";

        icon_button_highlight = "#1e2132";
      };
      rules = [
        {
          "class" = "title_bar";
          style = "dark";
          fg = "#c6c8d1";
          bg = "#0f1117";
        }
      ];
    };
  };

  # Sublime Text 4 configuration
  home.file."Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings" = {
    text = builtins.toJSON {
      # Editor settings
      theme = "Default.sublime-theme";
      color_scheme = "Packages/User/Mariana.sublime-color-scheme";

      # Behavior settings
      trim_trailing_white_space_on_save = "all";
      ensure_newline_at_eof_on_save = true;

      # Visual settings
      highlight_line = true;
      line_padding_top = 2;
      line_padding_bottom = 2;
      draw_white_space = "all";
      show_encoding = true;
      show_line_endings = true;

      # Code settings
      word_wrap = true;
      tab_size = 2;

      # Files and folders
      hot_exit = false;
      remember_open_files = false;
      ignored_packages = [ "Vintage" ];
    };
  };

  # Package Control settings (optional)
  home.file."Library/Application Support/Sublime Text/Packages/User/Package Control.sublime-settings" =
    {
      text = builtins.toJSON {
        bootstrapped = true;
        installed_packages = [
          "Close All without Confirmation"
          "Elixir"
          "Package Control"
          "Pretty JSON"
        ];
      };
    };

  # Key bindings (optional)
  home.file."Library/Application Support/Sublime Text/Packages/User/Default (OSX).sublime-keymap" = {
    text = builtins.toJSON [
      # Add custom key bindings here, for example:
      # { keys = [ "super+shift+f" ]; command = "show_panel"; args = { panel = "find_in_files"; }; }
    ];
  };

  # Iceberg theme for Sublime Merge
  home.file."Library/Application Support/Sublime Merge/Packages/User/Merge.sublime-theme" = {
    text = builtins.toJSON {
      variables = {
        # Iceberg color palette
        iceberg_bg = "#161821";
        iceberg_bg_light = "#1e2132";
        iceberg_bg_lighter = "#272c42";
        iceberg_fg = "#c6c8d1";
        iceberg_fg_dim = "#6b7089";
        iceberg_fg_darker = "#444b71";
        iceberg_blue = "#84a0c6";
        iceberg_cyan = "#89b8c2";
        iceberg_green = "#b4be82";
        iceberg_red = "#e27878";
        iceberg_orange = "#e2a478";
        iceberg_purple = "#a093c7";

        # UI colors
        background = "#0f1117";
        foreground = "#c6c8d1";
        text_fg = "#c6c8d1";

        # Sidebar
        sidebar_bg = "#0f1117";
        sidebar_fg = "#c6c8d1";
        sidebar_heading = "#6b7089";
        sidebar_label = "#c6c8d1";

        # Tabs
        tab_bg = "#0f1117";
        tab_fg = "#6b7089";
        tab_selected_bg = "#161821";
        tab_selected_fg = "#c6c8d1";

        # Status bar
        status_bar_bg = "#0f1117";
        status_bar_fg = "#c6c8d1";

        # Diff colors
        diff_added = "#b4be82";
        diff_added_bg = "#1e2132";
        diff_deleted = "#e27878";
        diff_deleted_bg = "#1e2132";
        diff_modified = "#84a0c6";
        diff_modified_bg = "#1e2132";

        # Git graph colors
        git_graph_line = "#6b7089";

        # Buttons
        button_bg = "#1e2132";
        button_fg = "#c6c8d1";
      };
      rules = [
        {
          "class" = "title_bar";
          style = "dark";
          fg = "#c6c8d1";
          bg = "#0f1117";
        }
      ];
    };
  };

  # Iceberg color scheme for Sublime Merge
  home.file."Library/Application Support/Sublime Merge/Packages/User/Merge.sublime-color-scheme" = {
    text = builtins.toJSON {
      variables = {
        blue = "#84a0c6";
        cyan = "#89b8c2";
        green = "#b4be82";
        red = "#e27878";
        orange = "#e2a478";
        purple = "#a093c7";
        yellow = "#e2c792";
        fg = "#c6c8d1";
        bg = "#161821";
      };
      globals = {
        background = "#161821";
        foreground = "#c6c8d1";
        caret = "#c6c8d1";
        selection = "#1e2132";
        line_highlight = "#1e2132";

        # Diff specific colors
        diff_header = "#84a0c6";
        diff_header_from = "#e27878";
        diff_header_to = "#b4be82";
        diff_deleted = "#e27878";
        diff_inserted = "#b4be82";
        diff_changed = "#84a0c6";
      };
      rules = [
        {
          scope = "diff.deleted";
          foreground = "var(red)";
          background = "#1e2132";
        }
        {
          scope = "diff.inserted";
          foreground = "var(green)";
          background = "#1e2132";
        }
        {
          scope = "diff.changed";
          foreground = "var(blue)";
        }
        {
          scope = "diff.header";
          foreground = "var(cyan)";
          font_style = "bold";
        }
        {
          scope = "diff.range";
          foreground = "var(purple)";
        }
        {
          scope = "markup.inserted";
          foreground = "var(green)";
        }
        {
          scope = "markup.deleted";
          foreground = "var(red)";
        }
        {
          scope = "markup.changed";
          foreground = "var(blue)";
        }
      ];
    };
  };
}
