require('lze').load {
  {
    'possession-nvim',
    event = { 'DeferredUIEnter' },
    load = function(name)
      require('lzextras').loaders.multi {
        name,
        'plenary.nvim',
      }
    end,
    after = function(_)
      require('possession').setup {
        autosave = { current = true, cwd = true },
        autoload = 'auto_cwd',
        plugins = {
          delete_hidden_buffers = false,
        },
      }
    end,
  },
}
