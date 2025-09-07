require('lze').load {
  {
    'conform.nvim',
    event = 'BufWritePre',
    cmd = { 'ConformInfo', 'ConformFormat' },
    keys = {
      {
        '<leader>lF',
        function()
          require('conform').format { async = true }
        end,
        mode = 'n',
        desc = 'Format buffer using conform',
      },
    },
    after = function(_)
      require('conform').setup {
        format_on_save = {
          timeout_ms = 500,
          lsp_format = 'fallback',
        },
        formatters_by_ft = {
          lua = { 'stylua' },
          nix = { 'alejandra' },
          sh = { 'shfmt' },
          go = { 'gofumpt' },
          rust = { 'rustfmt' },
          python = { 'ruff_organize_imports', 'ruff_format' },
          javascript = { 'biome' },
          javascriptreact = { 'biome' },
          typescript = { 'biome' },
          typescriptreact = { 'biome' },
          svelte = { 'prettierd' },
          css = { 'biome' },
          scss = { 'prettierd' },
          less = { 'prettierd' },
          html = { 'prettierd' },
          json = { 'biome' },
          yaml = { 'yamlfix', 'prettierd' },
          markdown = { 'prettierd' },
          typst = { 'typstyle' },
          kdl = { 'kdlfmt' },
          -- run formatters on filetypes that don't have other formatters configured.
          ['_'] = { 'trim_newlines', 'trim_whitespace' },
          -- Uncomment the following to run formatters on all filetypes.
          -- ["*"] = { "codespell" },
        },
      }
    end,
  },
}
