local M = {}
local utils = require "utils"

M.load_options = function()
  local default_options = {
    backup = false,
    clipboard = "unnamedplus",
    cmdheight = 2,
    colorcolumn = "99999",
    completeopt = { "menuone", "noselect" },
    conceallevel = 0,
    fileencoding = "utf-8",
    foldmethod = "manual",
    foldexpr = "",
    guifont = "monospace:h17",
    hidden = true,
    hlsearch = true,
    ignorecase = true,
    mouse = "a",
    pumheight = 10,
    showmode = false,
    showtabline = 1,
    smartcase = true,
    smartindent = true,
    splitbelow = true,
    splitright = true,
    swapfile = false,
    termguicolors = true,
    timeoutlen = 500,
    title = true,
    undodir = utils.join_paths(get_cache_dir(), "undo"),
    undofile = true,
    updatetime = 300,
    writebackup = false,
    expandtab = true,
    shiftwidth = 2,
    tabstop = 2,
    cursorline = true,
    number = true,
    relativenumber = false,
    numberwidth = 4,
    signcolumn = "yes",
    wrap = false,
    spell = false,
    spelllang = "en",
    scrolloff = 8,
    sidescrolloff = 8,
  }

  ---  SETTINGS  ---

  vim.opt.shortmess:append "c"

  for k, v in pairs(default_options) do
    vim.opt[k] = v
  end
end

M.load_commands = function()
  local cmd = vim.cmd
  if rvim.line_wrap_cursor_movement then
    cmd "set whichwrap+=<,>,[,],h,l"
  end
end

return M
