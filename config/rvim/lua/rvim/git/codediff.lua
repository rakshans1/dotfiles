require('lze').load {
  {
    'codediff.nvim',
    cmd = { 'CodeDiff' },
    keys = {
      { '<leader>gd', '<cmd>CodeDiff<cr>', desc = 'CodeDiff Open' },
      { '<leader>gf', '<cmd>CodeDiff file HEAD<cr>', desc = 'CodeDiff File History' },
    },
    after = function(_)
      require('codediff').setup {
        diff = { layout = 'side-by-side' },
        explorer = { view_mode = 'tree' },
        history = { view_mode = 'tree' },
        keymaps = {
          view = {
            toggle_explorer = '<leader>n',
          },
        },
      }
    end,
  },
}
