require('lze').load {
  {
    'indent-blankline.nvim',
    event = { 'DeferredUIEnter' },
    keys = {
      {
        '<leader>ii',
        function()
          require('ibl').setup_buffer(0, {
            enabled = not require('ibl.config').get_config(0).enabled,
          })
        end,
        mode = { 'n', 'x' },
        desc = 'Toggle indent blankline',
      },
    },
    after = function(_)
      require('ibl').setup {
        enabled = false,
        indent = {
          char = '│',
          smart_indent_cap = true,
        },
        whitespace = { remove_blankline_trail = true },
        scope = {
          enabled = false,
          show_end = true,
          show_start = true,
        },
        exclude = {
          filetypes = {
            'help',
            'alpha',
            'dashboard',
            'neo-tree',
            'Trouble',
            'trouble',
            'lazy',
            'notify',
            'toggleterm',
            'lazyterm',
            'lspinfo',
            'packer',
            'checkhealth',
            'help',
            'man',
            'gitcommit',
            'TelescopePrompt',
            'TelescopeResults',
            "''",
          },
        },
      }
      local hooks = require 'ibl.hooks'
      hooks.register(
        hooks.type.WHITESPACE,
        hooks.builtin.hide_first_space_indent_level
      )
      hooks.register(
        hooks.type.WHITESPACE,
        hooks.builtin.hide_first_tab_indent_level
      )
    end,
  },
}
