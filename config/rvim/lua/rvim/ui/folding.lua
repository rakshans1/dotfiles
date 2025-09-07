local fold_handler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = (' 󱥸───────────────────┤ 󰘕 %d lines ├───────────────────╮'):format(
    endLnum - lnum
  )
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      -- table.insert(newVirtText, chunk)
      table.insert(newVirtText, { chunkText, 'UfoFoldedFg' })
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, 'UfoFoldedFg' })
      -- table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, { suffix, 'Comment' })
  return newVirtText
end

require('lze').load {
  {
    'nvim-ufo',
    load = function(name)
      require('lzextras').loaders.multi {
        'promise-async',
        name,
      }
    end,
    keys = {
      {
        'zR',
        function()
          require('ufo').openAllFolds()
        end,
        desc = 'Open all folds',
      },
      {
        'zM',
        function()
          require('ufo').closeAllFolds()
        end,
        desc = 'Close all folds',
      },
      {
        'zK',
        function()
          local winid = require('ufo').peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end,
      },
    },
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('ufo').setup {
        enable_get_fold_virt_text = true,
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
        fold_virt_text_handler = fold_handler,
        preview = {
          win_config = { border = 'rounded', winblend = 0 },
        },
      }
    end,
  },
}
