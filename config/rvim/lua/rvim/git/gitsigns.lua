require('lze').load {
  {
    'gitsigns.nvim',
    event = { 'DeferredUIEnter' },
    keys = {
      -- hunks
      {
        ']h',
        '<cmd>lua require("gitsigns").next_hunk()<cr>',
        desc = 'Next hunk',
      },
      {
        '[h',
        '<cmd>lua require("gitsigns").prev_hunk()<cr>',
        desc = 'Previous hunk',
      },
      {
        '<leader>hp',
        '<cmd>lua require("gitsigns").preview_hunk()<cr>',
        desc = 'Preview hunk',
      },
      {
        '<leader>hP',
        '<cmd>lua require("gitsigns").preview_hunk_inline()<cr>',
        desc = 'Preview hunk (inline)',
      },
      {
        '<leader>hs',
        '<cmd>lua require("gitsigns").stage_hunk()<cr>',
        desc = 'Stage hunk',
      },
      {
        '<leader>hu',
        '<cmd>lua require("gitsigns").undo_stage_hunk()<cr>',
        desc = 'Undo stage hunk',
      },
      {
        '<leader>hr',
        '<cmd>lua require("gitsigns").reset_hunk()<cr>',
        desc = 'Reset hunk',
      },
      -- buffer
      {
        '<leader>ga',
        '<cmd>lua require("gitsigns").stage_buffer()<CR>',
        desc = 'Stage buffer',
      },
      {
        '<leader>gr',
        '<cmd>lua require("gitsigns").reset_buffer()<CR>',
        desc = 'Stage buffer',
      },
    },
    after = function(_)
      require('gitsigns').setup {
        signs = {
          add = { text = '▒' },
          change = { text = '▒' },
          delete = { text = '▒' },
          topdelete = { text = '▒' },
          changedelete = { text = '▒' },
        },
        signs_staged = {
          add = { text = '▒' },
          change = { text = '▒' },
          delete = { text = '▒' },
          topdelete = { text = '▒' },
          changedelete = { text = '▒' },
        },
        attach_to_untracked = false,
        current_line_blame = false,
        numhl = true,
        trouble = true,
      }
    end,
  },
}
