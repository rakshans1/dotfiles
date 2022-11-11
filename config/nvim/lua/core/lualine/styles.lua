local M = {}
local components = require "core.lualine.components"

local styles = {
  default = nil,
}

styles.default = {
  style = "rvim",
  options = {
    icons_enabled = true,
    component_separators = {
      left = rvim.icons.ui.DividerRight,
      right = rvim.icons.ui.DividerLeft,
    },
    section_separators = {
      left = rvim.icons.ui.BoldDividerRight,
      right = rvim.icons.ui.BoldDividerLeft,
    },
    disabled_filetypes = { "dashboard", "NvimTree", "Outline" },
  },
  sections = {
    lualine_a = {
      components.mode,
    },
    lualine_b = {
      components.branch,
      components.filename,
    },
    lualine_c = {
      components.diff,
    },
    lualine_x = {
      components.diagnostics,
      components.treesitter,
      components.lsp,
      components.filetype,
    },
    lualine_y = {},
    lualine_z = {
      components.scrollbar,
    },
  },
  inactive_sections = {
    lualine_a = {
      "filename",
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {
    lualine_a = {
      components.filenameTab
    },
    lualine_b = nil,
    lualine_c = nil,
    lualine_x = nil,
    lualine_y = nil,
    lualine_z = { 'tabs' }
  },
  extensions = { "nvim-tree" },
}

function M.get_style(style)
  local style_keys = vim.tbl_keys(styles)
  if not vim.tbl_contains(style_keys, style) then
    local Log = require "core.log"
    Log:error(
      "Invalid lualine style",
      string.format('"%s"', style),
      "options are: ",
      string.format('"%s"', table.concat(style_keys, '", "'))
    )
    Log:debug '"rvim" style is applied.'
    style = "rvim"
  end

  return vim.deepcopy(styles[style])
end

function M.update()
  local style = M.get_style(rvim.builtin.lualine.style)

  rvim.builtin.lualine = vim.tbl_deep_extend("keep", rvim.builtin.lualine, style)
end

return M
