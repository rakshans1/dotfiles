local M = {}
M.config = function()
  rvim.builtin.lualine = {
    active = true,
    style = "default",
    options = {
      icons_enabled = nil,
      component_separators = nil,
      section_separators = nil,
      theme = nil,
      disabled_filetypes = nil,
    },
    sections = {
      lualine_a = nil,
      lualine_b = nil,
      lualine_c = nil,
      lualine_x = nil,
      lualine_y = nil,
      lualine_z = nil,
    },
    inactive_sections = {
      lualine_a = nil,
      lualine_b = nil,
      lualine_c = nil,
      lualine_x = nil,
      lualine_y = nil,
      lualine_z = nil,
    },
    tabline = {},
    extensions = nil,
  }
end

M.setup = function()
  require("core.lualine.styles").update()

  local lualine = require "lualine"
  lualine.setup(rvim.builtin.lualine)
end

return M
