require('lze').load {
  {
    'wtf.nvim',
    event = 'DeferredUIEnter',
    keys = {
      {
        '<leader>cd',
        mode = { 'n', 'x' },
        function()
          require('wtf').ai()
        end,
        desc = 'Debug diagnostic with AI',
      },
      {
        mode = { 'n' },
        '<leader>cs',
        function()
          require('wtf').search()
        end,
        desc = 'Search diagnostic with Google',
      },
    },
    after = function(_)
      require('wtf').setup()
    end,
  },
}
