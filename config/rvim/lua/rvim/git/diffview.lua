require('lze').load {
  {
    'diffview.nvim',
    event = { 'DeferredUIEnter' },
    cmd = { 'DiffviewOpen', 'DiffviewClose' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview Open' },
    },
    after = function(_)
      require('diffview').setup {}
    end,
  },
}
