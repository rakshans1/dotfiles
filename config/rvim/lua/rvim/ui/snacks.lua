require('lze').load {
  {
    'snacks.nvim',
    after = function(_)
      local snacks = require 'snacks'
      local snacks_dashboard = require 'rvim.ui.snacks-dashboard'
      require 'rvim.ui.snacks-rename'

      snacks.setup {
        styles = {
          float = { wo = { winblend = 0 } },
          lazygit = {
            border = 'rounded',
            backdrop = false,
          },
          git = { backdrop = false },
        },
        bigfile = { enabled = true },
        gitbrowse = { enabled = true },
        lazygit = {
          enabled = true,
          win = { position = 'float' },
        },
        quickfile = { enabled = false },
        dashboard = snacks_dashboard.dashboard,
        notifier = {
          enabled = true,
          style = 'compact',
          timeout = 2500,
        },
        image = {
          enabled = true,
          doc = { inline = false, float = true },
        },
        statuscolumn = {
          enabled = false,
          left = { 'mark', 'sign' },
          right = { 'fold', 'git' },
          folds = { open = true, git_hl = true },
        },
        picker = {
          layouts = {
            custom = {
              -- custom default layout
              layout = {
                backdrop = false,
                box = 'horizontal',
                width = 0.8,
                min_width = 120,
                height = 0.8,
                border = 'none',
                {
                  box = 'vertical',
                  border = 'none',
                  {
                    win = 'input',
                    height = 1,
                    border = 'rounded',
                    title = '{title} {live} {flags}',
                    title_pos = 'center',
                  },
                  {
                    win = 'list',
                    title = 'Results',
                    border = 'rounded',
                    title_pos = 'center',
                  },
                },
                {
                  win = 'preview',
                  title = '{preview:Preview}',
                  border = 'rounded',
                  width = 0.5,
                  title_pos = 'center',
                },
              },
            },
            dropdown_custom = {
              -- custom dropdown layout
              layout = {
                backdrop = false,
                row = 1,
                width = 0.4,
                min_width = 80,
                height = 0.8,
                border = 'none',
                box = 'vertical',
                {
                  win = 'preview',
                  title = '{preview}',
                  height = 0.4,
                  border = 'rounded',
                },
                {
                  box = 'vertical',
                  border = 'none',
                  title_pos = 'center',
                  {
                    win = 'input',
                    height = 1,
                    border = 'rounded',
                    title_pos = 'center',
                    title = '{title} {live} {flags}',
                  },
                  {
                    win = 'list',
                    border = 'rounded',
                    title_pos = 'center',
                    title = 'Results',
                  },
                },
              },
            },
            ivy_custom = {
              -- custom ivy layout
              layout = {
                box = 'horizontal',
                backdrop = false,
                row = -1,
                width = 0,
                height = 0.4,
                border = 'none',
                {
                  box = 'vertical',
                  border = 'none',
                  {
                    win = 'input',
                    height = 1,
                    border = 'rounded',
                    title = ' {title} {live} {flags}',
                    title_pos = 'left',
                  },
                  {
                    win = 'list',
                    border = 'rounded',
                    title = 'Results',
                    title_pos = 'left',
                  },
                },
                {
                  win = 'preview',
                  title = '{preview:Preview}',
                  width = 0.6,
                  border = 'rounded',
                  title_pos = 'center',
                },
              },
            },
            vertical_custom = {
              -- custom vertical layout
              layout = {
                backdrop = false,
                width = 0.5,
                min_width = 80,
                height = 0.8,
                min_height = 30,
                box = 'vertical',
                border = 'none',
                {
                  win = 'input',
                  height = 1,
                  border = 'rounded',
                  title = '{title} {live} {flags}',
                  title_pos = 'center',
                },
                {
                  win = 'list',
                  border = 'rounded',
                  title = 'Results',
                  title_pos = 'center',
                },
                {
                  win = 'preview',
                  title = '{preview}',
                  height = 0.4,
                  border = 'rounded',
                  title_pos = 'center',
                },
              },
            },
            vscode_custom = {
              -- custom vscode layout
              layout = {
                backdrop = false,
                row = 1,
                width = 0.4,
                min_width = 80,
                height = 0.4,
                border = 'none',
                box = 'vertical',
                {
                  win = 'input',
                  height = 1,
                  border = 'rounded',
                  title = '{title} {live} {flags}',
                  title_pos = 'center',
                },
                {
                  win = 'list',
                  border = 'rounded',
                  title = 'Results',
                  title_pos = 'center',
                },
                {
                  win = 'preview',
                  title = '{preview}',
                  border = 'rounded',
                  title_pos = 'center',
                },
              },
            },
          },
          sources = {
            -- Snacks pickers (find) [f]
            files = { layout = { preset = 'custom' } },
            git_files = { layout = { preset = 'custom' } },
            buffers = { layout = { preset = 'dropdown_custom' } },
            projects = { layout = { preset = 'vscode_custom' } },
            jumps = { layout = { preset = 'ivy_custom' } },
            marks = { layout = { preset = 'ivy_custom' } },

            -- Snacks pickers (git) [g]
            git_log = { layout = { preset = 'custom' } },
            git_log_file = { layout = { preset = 'custom' } },

            -- Snacks pickers (search) [s]
            grep = { layout = { preset = 'vertical_custom' } },
            -- lines = {layout = {preset = "ivy_custom"}},
            grep_buffers = { layout = { preset = 'vertical_custom' } },
            todo_comments = { layout = { preset = 'vertical_custom' } },

            -- Snacks pickers (misc) [t]
            command_history = { layout = { preset = 'vscode_custom' } },
            registers = { layout = { preset = 'vscode_custom' } },
            undo = { layout = { preset = 'dropdown_custom' } },
            help = { layout = { preset = 'custom' } },
            highlights = { layout = { preset = 'dropdown_custom' } },
            icons = { layout = { preset = 'vscode_custom' } },
            keymaps = { layout = { preset = 'vscode_custom' } },

            -- Snacks pickers (lsp) [l]
            diagnostics = { layout = { preset = 'vertical_custom' } },
            lsp_symbols = { layout = { preset = 'custom' } },
          },
        },
      }
    end,
  },
}
