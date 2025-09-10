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
    keys = {
      {
        '<C-_>',
        function()
          require('Comment.api').toggle.linewise.current()
        end,
        mode = { 'n' },
        desc = 'Comment Line',
      },
      {
        '<C-_>',
        function()
          local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
          vim.api.nvim_feedkeys(esc, 'nx', false)
          require('Comment.api').toggle.linewise(vim.fn.visualmode())
        end,
        mode = { 'o', 'x' },
        desc = 'Comment Line',
      },
    },
  },
}
