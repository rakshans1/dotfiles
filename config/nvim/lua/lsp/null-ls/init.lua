local M = {}

local Log = require "core.log"
local formatters = require "lsp.null-ls.formatters"
local linters = require "lsp.null-ls.linters"

function M:setup()
  local status_ok, null_ls = pcall(require, "null-ls")
  if not status_ok then
    Log:error "Missing null-ls dependency"
    return
  end

  null_ls.config()
  require("lspconfig")["null-ls"].setup(rvim.lsp.null_ls.setup)
  for filetype, config in pairs(rvim.lang) do
    if not vim.tbl_isempty(config.formatters) then
      vim.tbl_map(function(c)
        c.filetypes = { filetype }
      end, config.formatters)
      formatters.setup(config.formatters)
    end
    if not vim.tbl_isempty(config.linters) then
      vim.tbl_map(function (c)
        c.filtypes = { filetype }
      end, config.formatters)
      linters.setup(config.linters)
    end
  end
end

return M
