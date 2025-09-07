require('lze').load {
  {
    'flash.nvim',
    event = { 'DeferredUIEnter' },
    keys = {
      {
        'S',
        function()
          require('flash').treesitter()
        end,
        mode = { 'n', 'o', 'x' },
        desc = 'Flash treesitter',
      },
      {
        'r',
        function()
          require('flash').remote()
        end,
        mode = { 'o' },
        desc = 'Flash remote',
      },
      {
        '<leader><leader>',
        function()
          require('flash').jump()
        end,
        mode = { 'n', 'o', 'x' },
        desc = 'Flash jump',
      },
    },
    after = function(_)
      require('flash').setup {
        continue = false,
        modes = {
          char = { enabled = false },
          search = { enabled = false },
        },
        jump = {
          autojump = false,
          history = false,
          jumplist = true,
          nohlsearch = true,
        },
        label = {
          after = true,
          min_pattern_length = 0,
          rainbow = { enabled = false },
        },
      }
    end,
  },
}
