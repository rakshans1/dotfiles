{ config, lib, ... }:

{
  xdg.configFile."glow/iceberg.json".text = builtins.toJSON {
    document = {
      block_prefix = "\n";
      block_suffix = "\n";
      color = "#c6c8d1";
      background_color = "#161821";
      margin = 2;
    };
    block_quote = {
      indent = 1;
      indent_token = "│ ";
      color = "#6b7089";
    };
    paragraph = {
      color = "#c6c8d1";
    };
    list = {
      level_indent = 2;
      color = "#c6c8d1";
    };
    heading = {
      block_suffix = "\n";
      color = "#91acd1";
      bold = true;
    };
    h1 = {
      prefix = " ";
      suffix = " ";
      color = "#84a0c6";
      bold = true;
    };
    h2 = {
      prefix = "## ";
      color = "#91acd1";
      bold = true;
    };
    h3 = {
      prefix = "### ";
      color = "#89b8c2";
    };
    h4 = {
      prefix = "#### ";
      color = "#89b8c2";
    };
    h5 = {
      prefix = "##### ";
      color = "#95c4ce";
    };
    h6 = {
      prefix = "###### ";
      color = "#6b7089";
      bold = false;
    };
    text = {
      color = "#c6c8d1";
    };
    strikethrough = {
      crossed_out = true;
      color = "#6b7089";
    };
    emph = {
      italic = true;
      color = "#e2a478";
    };
    strong = {
      bold = true;
      color = "#e9b189";
    };
    hr = {
      color = "#6b7089";
      format = "\n────────\n";
    };
    item = {
      block_prefix = "• ";
      color = "#89b8c2";
    };
    enumeration = {
      block_prefix = ". ";
      color = "#89b8c2";
    };
    task = {
      ticked = "[✓] ";
      unticked = "[ ] ";
      color = "#b4be82";
    };
    link = {
      color = "#84a0c6";
      underline = true;
    };
    link_text = {
      color = "#91acd1";
      bold = true;
    };
    image = {
      color = "#a093c7";
      underline = true;
    };
    image_text = {
      color = "#6b7089";
      format = "Image: {{.text}} →";
    };
    code = {
      prefix = " ";
      suffix = " ";
      color = "#e98989";
      background_color = "#1e2132";
    };
    code_block = {
      color = "#c6c8d1";
      background_color = "#1e2132";
      margin = 2;
      chroma = {
        text = {
          color = "#c6c8d1";
        };
        error = {
          color = "#d2d4de";
          background_color = "#e27878";
        };
        comment = {
          color = "#6b7089";
        };
        comment_preproc = {
          color = "#e2a478";
        };
        keyword = {
          color = "#84a0c6";
          bold = true;
        };
        keyword_reserved = {
          color = "#a093c7";
        };
        keyword_namespace = {
          color = "#ada0d3";
        };
        keyword_type = {
          color = "#91acd1";
        };
        operator = {
          color = "#89b8c2";
        };
        punctuation = {
          color = "#c6c8d1";
        };
        name = {
          color = "#c6c8d1";
        };
        name_builtin = {
          color = "#ada0d3";
        };
        name_tag = {
          color = "#a093c7";
        };
        name_attribute = {
          color = "#89b8c2";
        };
        name_class = {
          color = "#e9b189";
          bold = true;
        };
        name_constant = {
          color = "#e2a478";
        };
        name_decorator = {
          color = "#e9b189";
        };
        name_exception = {
          color = "#e27878";
        };
        name_function = {
          color = "#b4be82";
        };
        name_other = {
          color = "#c6c8d1";
        };
        literal = {
          color = "#c6c8d1";
        };
        literal_number = {
          color = "#e2a478";
        };
        literal_date = {
          color = "#e2a478";
        };
        literal_string = {
          color = "#c0ca8e";
        };
        literal_string_escape = {
          color = "#95c4ce";
        };
        generic_deleted = {
          color = "#e27878";
        };
        generic_emph = {
          italic = true;
        };
        generic_inserted = {
          color = "#b4be82";
        };
        generic_strong = {
          bold = true;
        };
        generic_subheading = {
          color = "#6b7089";
        };
        background = {
          background_color = "#1e2132";
        };
      };
    };
    table = {
      color = "#c6c8d1";
    };
    definition_list = {
      color = "#c6c8d1";
    };
    definition_term = {
      color = "#91acd1";
    };
    definition_description = {
      block_prefix = "\n→ ";
    };
    html_block = {
      color = "#6b7089";
    };
    html_span = {
      color = "#6b7089";
    };
  };

  # Configure glow to use the Iceberg theme
  xdg.configFile."glow/glow.yml".text = ''
    # Iceberg theme for Glow
    style: "${config.home.homeDirectory}/.config/glow/iceberg.json"

    # Use pager to display markdown
    pager: true

    # Word wrap at 120 columns
    width: 120

    # Mouse wheel support (TUI-mode only)
    mouse: true
  '';
}
