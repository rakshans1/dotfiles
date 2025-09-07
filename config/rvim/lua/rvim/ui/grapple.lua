require('lze').load {
  {
    'grapple.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    keys = {
      {
        '<leader>mm',
        '<cmd>Grapple tag<CR><cmd>lua vim.notify("Added to grapple", "info")<CR>',
        desc = 'Grapple tag',
      },
      {
        '<leader>md',
        '<cmd>Grapple untag<CR><cmd>lua vim.notify("Removed from grapple", "info")<CR>',
        desc = 'Grapple delete tag',
      },
      {
        '<leader>ml',
        '<cmd>Grapple open_tags<CR>',
        desc = 'Grapple show',
      },
      {
        ']g',
        '<cmd>Grapple cycle_forward<CR><cmd>lua vim.notify("Grapple next", "info")<CR>',
        desc = 'Grapple next',
      },
      {
        '[g',
        '<cmd>Grapple cycle_backward<CR><cmd>lua vim.notify("Grapple prev", "info")<CR>',
        desc = 'Grapple prev',
      },
      {
        '<leader>m1',
        '<cmd>Grapple select index=1<CR>',
        desc = 'Grapple select 1',
      },
      {
        '<leader>m2',
        '<cmd>Grapple select index=2<CR>',
        mode = 'n',
        desc = 'Grapple select 2',
      },
      {
        '<leader>m3',
        '<cmd>Grapple select index=3<CR>',
        desc = 'Grapple select 3',
      },
      {
        '<leader>m4',
        '<cmd>Grapple select index=4<CR>',
        desc = 'Grapple select 4',
      },
    },
    after = function(_)
      require('grapple').setup {
        leader_key = '<leader>m',
        show_icons = true,
        status = true,
        scope = 'git_branch',
        style = 'basename',
        always_show_path = false,
        separate_by_branch = true,
        win_opts = {
          border = 'rounded',
        },
      }
    end,
  },
}
