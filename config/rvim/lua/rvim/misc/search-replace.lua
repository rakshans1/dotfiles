require('lze').load {
  {
    'grug-far.nvim',
    cmd = { 'GrugFar' },
    keys = {
      {
        '<leader>sr',
        '<cmd>GrugFar<CR>',
        desc = 'GrugFar replace',
      },
    },
    after = function(_)
      require('grug-far').setup {}
    end,
  },
  {
    'ssr.nvim',
    keys = {
      {
        '<leader>sR',
        mode = { 'n', 'v', 'x' },
        '<cmd>lua require("ssr").open()<CR>',
        desc = 'SSR (structured) replace',
      },
    },
    after = function(_)
      require('ssr').setup {}
    end,
  },
}
