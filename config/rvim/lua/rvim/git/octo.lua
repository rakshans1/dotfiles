require('lze').load {
  {
    'octo-nvim',
    event = { 'DeferredUIEnter' },
    load = function(name)
      require('lzextras').loaders.multi {
        name,
        'snacks-nvim',
      }
    end,
    cmd = { 'Octo' },
    keys = {
      { '<leader>gpl', '<cmd>Octo pr list<cr>', desc = 'List PR' },
    },

    after = function(_)
      require('octo').setup {
        enable_builtin = true,
        picker = 'snacks',
      }
    end,
  },
}
