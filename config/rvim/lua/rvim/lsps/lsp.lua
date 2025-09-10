local servers = require 'rvim.lsps.servers'

require('lze').load {
  {
    'nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    after = function(_)
      local lspconfig = require 'lspconfig'
      lspconfig.util.default_config =
        vim.tbl_extend('force', lspconfig.util.default_config, {
          capabilities = require('blink.cmp').get_lsp_capabilities({}, true),
          on_attach = function(_, bufnr)
            vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
              require('conform').format { async = true }
            end, { desc = 'Format current buffer using conform' })
          end,
        })
      for server_name, cfg in pairs(servers) do
        lspconfig[server_name].setup(cfg or {})
      end
    end,
  },
  {
    'lazydev.nvim',
    cmd = { 'LazyDev' },
    ft = 'lua',
    after = function(_)
      require('lazydev').setup {
        library = {
          {
            words = { 'rvim' },
            path = '/lua',
          },
        },
      }
    end,
  },
  {
    'inc-rename.nvim',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('inc_rename').setup {
        show_message = true,
      }
    end,
  },
}
