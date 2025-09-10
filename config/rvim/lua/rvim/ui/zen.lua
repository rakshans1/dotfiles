require('lze').load {
  {
    'zen-mode.nvim',
    keys = {
      -- zen mode
      {
        '<leader>zz',
        '<cmd>ZenMode<cr>',
        desc = 'Zen mode',
      },
      -- twilight
      {
        '<leader>zt',
        '<cmd>Twilight<cr>',
        desc = 'Zen mode twilight',
      },
    },
    event = { 'DeferredUIEnter' },
    load = function(name)
      require('lzextras').loaders.multi {
        name,
        'twilight.nvim',
      }
    end,
    after = function(_)
      require('zen-mode').setup {
        plugins = {
          twilight = { enabled = false },
        },
        window = { backdrop = 1 },
      }
    end,
  },
}
