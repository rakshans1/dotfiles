require('lze').load {
  {
    'mini.indentscope',
    -- event = { 'DeferredUIEnter' },
    after = function(_)
      require('mini.indentscope').setup {
        options = {
          try_as_border = true,
          border = 'both',
        },
        symbol = '╎',
      }
      local disabled_filetypes =
        { 'NvimTree', 'alpha', 'help', 'snacks_dashboard', '', 'Outline' }
      vim.api.nvim_create_autocmd('BufWinEnter', {
        group = vim.api.nvim_create_augroup(
          'MiniIndentScopeDisable',
          { clear = true }
        ),
        callback = function(opts)
          local ftype = vim.bo[opts.buf].filetype
          if vim.tbl_contains(disabled_filetypes, ftype) then
            vim.b[opts.buf].miniindentscope_disable = true
          end
        end,
      })
    end,
  },
}
