require('lze').load {
  {
    'nvim-notify',
    -- event = { 'DeferredUIEnter' },
    after = function(_)
      require('notify').setup {
        level = 'info',
        background_color = '#191724',
      }
    end,
  },
  {
    'noice.nvim',
    -- Comment this out because lualine uses noice at startup
    event = { 'DeferredUIEnter' },
    load = function(name)
      require('lzextras').loaders.multi {
        name,
        'nui.nvim',
        'nvim-notify',
      }
    end,
    after = function(_)
      require('noice').setup {
        lsp = {
          progress = { enabled = true },
          hover = { enabled = true },
          signature = { enabled = true },
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          long_message_to_split = false,
          lsp_doc_border = true,
          inc_rename = true,
        },
        notify = { enabled = true },
        messages = { enabled = true },
      }
    end,
  },
}

-- NOTE: Disable deprecation warnings for vim.tbl_islist
local original_deprecate = vim.deprecate

vim.deprecate = function(msg, ...)
  if msg:find 'vim.tbl_islist' then
    return
  end
  original_deprecate(msg, ...)
end
