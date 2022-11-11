local M = {}

M.config = function()
  rvim.builtin.indentlines = {
    active = true,
    on_config_done = nil,
    options = {
      enabled = true,
      buftype_exclude = { "terminal", "nofile" },
      filetype_exclude = {
        "help",
        "startify",
        "dashboard",
        "packer",
        "neogitstatus",
        "NvimTree",
        "Trouble",
        "text",
      },
      char = rvim.icons.ui.LineLeft,
      show_trailing_blankline_indent = false,
      show_first_indent_level = false,
      use_treesitter = true,
      show_current_context = true,
    },
  }
end

M.setup = function()
  local status_ok, indent_blankline = pcall(require, "indent_blankline")
  if not status_ok then
    return
  end

  indent_blankline.setup(rvim.builtin.indentlines.options)

  if rvim.builtin.indentlines.on_config_done then
    rvim.builtin.indentlines.on_config_done()
  end
end

return M
