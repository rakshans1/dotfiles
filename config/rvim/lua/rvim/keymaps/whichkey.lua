require('lze').load {
  {
    'which-key.nvim',
    event = { 'DeferredUIEnter' },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },
    after = function(_)
      local wk = require 'which-key'
      wk.setup { preset = 'helix' }
      wk.add {
        { '<Leader>a', group = '+Avante' },
        { '<leader>d', group = '+DAP' },
        { '<leader>f', group = '+File' },
        { '<leader>g', group = '+Git' },
        { '<leader>h', group = '+Git hunk' },
        { '<leader>i', group = '+Iron' },
        { '<leader>j', group = '+Neopyter' },
        { '<leader>l', group = '+LSP' },
        { '<leader>m', group = '+Grapple' },
        { '<leader>n', group = '+Notes' },
        { '<leader>p', group = '+Pos[session]' },
        { '<Leader>q', group = '+Close' },
        { '<leader>s', group = '+Search' },
        { '<leader>t', group = '+Test' },
        { '<leader>v', group = '+Vim' },
        { '<leader>u', group = '+Misc.' },
        { '<leader>x', group = '+Trouble' },
        { '<leader>z', group = '+Zen' },
        { '<leader>[', group = '+prev' },
        { '<leader>]', group = '+next' },
      }
    end,
  },
}
