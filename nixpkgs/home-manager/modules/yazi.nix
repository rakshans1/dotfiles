{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      manager = {
        show_hidden = true;
      };
    };

    theme = {
      # Iceberg color scheme
      manager = {
        cwd = { fg = "#c6c8d1"; bg = "#161821"; bold = true; };
        hovered = { fg = "#161821"; bg = "#84a0c6"; bold = true; };
        preview_hovered = { fg = "#84a0c6"; bg = "#161821"; bold = true; };
        find_keyword = { fg = "#84a0c6"; bg = "#161821"; bold = true; };
        find_position = { fg = "#a093c7"; bg = "#161821"; };
        marker_copied = { fg = "#84a0c6"; bg = "#161821"; bold = true; };
        marker_cut = { fg = "#e27878"; bg = "#161821"; bold = true; };
        marker_marked = { fg = "#b4be82"; bg = "#161821"; bold = true; };
        marker_selected = { fg = "#84a0c6"; bg = "#161821"; bold = true; };
        count_copied = { fg = "#84a0c6"; bg = "#161821"; bold = true; };
        count_cut = { fg = "#e27878"; bg = "#161821"; bold = true; };
        count_selected = { fg = "#84a0c6"; bg = "#161821"; bold = true; };
        border_symbol = "│";
        border_style = { fg = "#6b7089"; bg = "#161821"; };
      };

      tabs = {
        active = { fg = "#161821"; bg = "#84a0c6"; bold = true; };
        inactive = { fg = "#6b7089"; bg = "#1e2132"; };
        sep_inner = { open = " "; close = " "; };
        sep_outer = { open = ""; close = ""; };
      };

      mode = {
        normal_main = { fg = "#84a0c6"; bg = "#161821"; bold = true; };
        normal_alt = { fg = "#6b7089"; bg = "#161821"; };
        select_main = { fg = "#b4be82"; bg = "#161821"; bold = true; };
        select_alt = { fg = "#6b7089"; bg = "#161821"; };
        unset_main = { fg = "#e27878"; bg = "#161821"; bold = true; };
        unset_alt = { fg = "#6b7089"; bg = "#161821"; };
      };

      status = {
        overall = { fg = "#c6c8d1"; bg = "#161821"; };
        sep_left = { open = ""; close = " "; };
        sep_right = { open = " "; close = ""; };
        perm_type = { fg = "#84a0c6"; bg = "#161821"; bold = true; };
        perm_read = { fg = "#b4be82"; bg = "#161821"; bold = true; };
        perm_write = { fg = "#e27878"; bg = "#161821"; bold = true; };
        perm_exec = { fg = "#b4be82"; bg = "#161821"; bold = true; };
        perm_sep = { fg = "#6b7089"; bg = "#161821"; };
        progress_label = { fg = "#84a0c6"; bg = "#161821"; bold = true; };
        progress_normal = { fg = "#84a0c6"; bg = "#161821"; };
        progress_error = { fg = "#e27878"; bg = "#161821"; };
      };

      which = {
        cols = 3;
        mask = { fg = "#1e2132"; };
        cand = { fg = "#84a0c6"; };
        rest = { fg = "#6b7089"; };
        desc = { fg = "#a093c7"; };
        separator = "  ";
        separator_style = { fg = "#6b7089"; };
      };

      help = {
        on = { fg = "#84a0c6"; bold = true; };
        run = { fg = "#b4be82"; };
        desc = { fg = "#c6c8d1"; };
        hovered = { fg = "#161821"; bg = "#84a0c6"; bold = true; };
        footer = { fg = "#6b7089"; bg = "#161821"; };
      };

      filetype = {
        rules = [
          # Images
          { mime = "image/*"; fg = "#e2a478"; }

          # Videos and Audio
          { mime = "video/*"; fg = "#a093c7"; }
          { mime = "audio/*"; fg = "#a093c7"; }

          # Archives
          { mime = "application/*zip*"; fg = "#e27878"; }
          { mime = "application/*tar*"; fg = "#e27878"; }
          { mime = "application/*7z*"; fg = "#e27878"; }

          # Code files by extension
          { name = "*.nix"; fg = "#84a0c6"; }
          { name = "*.ex"; fg = "#a093c7"; }
          { name = "*.exs"; fg = "#a093c7"; }
          { name = "*.rs"; fg = "#e27878"; }
          { name = "*.go"; fg = "#84a0c6"; }
          { name = "*.py"; fg = "#b4be82"; }
          { name = "*.js"; fg = "#e2a478"; }
          { name = "*.ts"; fg = "#84a0c6"; }
          { name = "*.json"; fg = "#e2a478"; }
          { name = "*.toml"; fg = "#e2a478"; }
          { name = "*.yml"; fg = "#e2a478"; }
          { name = "*.yaml"; fg = "#e2a478"; }
          { name = "*.md"; fg = "#c6c8d1"; }

          # Hidden files
          { name = ".*"; fg = "#6b7089"; }

          # Directories
          { name = "*/"; fg = "#84a0c6"; bold = true; }

          # Default fallback
          { name = "*"; fg = "#c6c8d1"; }
        ];
      };
    };
  };
}