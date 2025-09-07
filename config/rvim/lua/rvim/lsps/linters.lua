require('lze').load {
  {
    'lint',
    event = 'BufWritePost',
    after = function()
      require('lint').linters_by_ft = {
        text = {},
        markdown = {},
        rst = { 'rstcheck', 'vale' },
        nix = { 'nix' },
        json = { 'biomejs' },
        css = { 'stylelint' },
        scss = { 'stylelint' },
        dockerfile = { 'hadolint' },
        python = { 'ruff' },
        javascript = { 'biomejs' },
        typescript = { 'biomejs' },
        javascriptreact = { 'biomejs' },
        typescriptreact = { 'biomejs' },
        svelte = { 'eslint_d' },
      }
    end,
  },
}

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  callback = function()
    require('lint').try_lint()
  end,
})
