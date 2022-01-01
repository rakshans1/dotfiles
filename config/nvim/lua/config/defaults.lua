return {
  leader = "space",
  colorscheme = "iceberg",
  line_wrap_cursor_movement = true,
  transparent_window = false,
  format_on_save = {
    pattern = "*",
    timeout = 1000,
  },
  keys = {},

  builtin = {},

  plugins = {
    -- use config.lua for this not put here
  },

  autocommands = {},

  log = {
    ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
    level = "warn",
    viewer = {
      ---@usage this will fallback on "less +F" if not found
      cmd = "lnav",
      layout_config = {
        ---@usage direction = 'vertical' | 'horizontal' | 'window' | 'float',
        direction = "horizontal",
        open_mapping = "",
        size = 40,
        float_opts = {},
      },
    },
  },
  lang = {
    typescript = {
      formatters = {{
        exe = "prettierd"
      }},
      linters = {{
        exe = "eslint_d"
      }}
    },
    javascript = {
      formatters = {{
        exe = "prettierd"
      }},
      linters = {{
        exe = "eslint_d"
      }}
    },
    javascriptreact = {
      formatters = {{
        exe = "prettierd"
      }},
      linters = {{
        exe = "eslint_d"
      }}
    },
    typescriptreact = {
      formatters = {{
        exe = "prettierd"
      }},
      linters = {{
        exe = "eslint_d"
      }}
    },
  },
}
