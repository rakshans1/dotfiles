require('lze').load {
  {
    'copilot.lua',
    event = 'InsertEnter',
    cmd = 'Copilot',
    -- load = function(name)
    -- require('lzextras').loaders.multi {
    --   name,
    --   'copilot-lsp',
    -- }
    -- end,
    after = function(_)
      require('copilot').setup {
        -- nes = { enabled = true },
        panel = { enabled = false },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = false,
          keymap = {
            accept = '<Tab>',
            accept_line = '<C-;>',
            accept_word = false,
            next = '<A-n>',
            prev = '<A-p>',
          },
        },
        filetypes = {
          gitrebase = true,
          ['grug-far'] = false,
          ['grug-far-history'] = false,
          ['grug-far-help'] = false,
          ['.'] = false,
          [''] = false,
          ['chatgpt-input'] = false,
          oil = false,
          minifiles = false,
          markdown = true,
          yaml = true,
          gitcommit = true,
        },
      }
    end,
  },
}
