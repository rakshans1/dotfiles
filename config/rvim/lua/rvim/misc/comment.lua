require('lze').load {
  {
    'nvim-ts-context-commentstring',
    dep_of = 'comment.nvim',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('ts_context_commentstring').setup {
        enable_autocmd = false,
      }
    end,
  },
  {
    'comment.nvim',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('Comment').setup {
        sticky = true,
        mappings = { basic = true, extra = true },
        pre_hook = require(
          'ts_context_commentstring.integrations.comment_nvim'
        ).create_pre_hook(),
      }
    end,
  },
}
