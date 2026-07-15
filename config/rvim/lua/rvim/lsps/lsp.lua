local control = require 'rvim.lsps.control'

require('lze').load {
  {
    'nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    after = function(_)
      control.configure()
    end,
  },
  {
    'lazydev.nvim',
    cmd = { 'LazyDev' },
    ft = 'lua',
    after = function(_)
      require('lazydev').setup {
        library = {
          {
            words = { 'rvim' },
            path = '/lua',
          },
        },
      }
    end,
  },
  {
    'inc-rename.nvim',
    cmd = { 'IncRename' },
    after = function(_)
      require('inc_rename').setup {
        show_message = true,
      }
    end,
  },
}
