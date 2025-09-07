require('lze').load {
  {
    'mini.snippets',
    event = { 'DeferredUIEnter' },
    after = function(_)
      local gen_loader = require('mini.snippets').gen_loader
      require('mini.snippets').setup {
        snippets = {
          gen_loader.from_lang(),
        },
        mappings = {
          expand = '',
          jump_next = '<C-j>',
          jump_prev = '<C-k>',
          stop = '<C-c>',
        },
      }
    end,
  },
}
