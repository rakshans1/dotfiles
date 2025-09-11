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
        terminal = {
          enabled = true,
          win = { position = 'float' },
        },
        picker = {
          win = {
            input = {
              keys = {
                ['<S-k>'] = { 'history_back', mode = { 'n' } },
                ['<S-j>'] = { 'history_forward', mode = { 'n' } },
                ['t'] = { 'tab' },
                ['v'] = { 'edit_vsplit' },
              },
            },
            list = {
              keys = {
                ['t'] = { 'tab' },
                ['v'] = { 'edit_vsplit' },
              },
            },
          },
        },
      }
    end,
  },
}
