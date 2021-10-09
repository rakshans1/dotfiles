local M = {}

M.config = function()
  rvim.builtin.bufferline = {
    active = true,
    on_config_done = nil,
    keymap = {
      normal_mode = {
        ["<S-l>"] = ":BufferNext<CR>",
        ["<S-h>"] = ":BufferPrevious<CR>",
      },
    },
    setup = {
      auto_hide = true,
      tabpages = true
    }
  }
end

M.setup = function()
  local keymap = require "keymappings"
  keymap.append_to_defaults(rvim.builtin.bufferline.keymap)
  vim.g.bufferline = rvim.builtin.bufferline.setup
end

return M
