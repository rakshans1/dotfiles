local M = {}
local join_paths = require("utils").join_paths

M.load_default_options = function()
  local utils = require "utils"

  local undodir = join_paths(get_cache_dir(), "undo")

  if not utils.is_directory(undodir) then
    vim.fn.mkdir(undodir, "p")
  end



  local default_options = {
    backup = false,
    clipboard = "unnamedplus",
    cmdheight = 1,
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
    showtabline = 2,
    smartcase = true,
    splitbelow = true,
    splitright = true,
    swapfile = false,
    termguicolors = true,
    timeoutlen = 1000,
    title = true,
    undodir = undodir,
    undofile = true,
    updatetime = 100,
    writebackup = false,
    expandtab = true,
    shiftwidth = 2,
    tabstop = 2,
    cursorline = true,
    number = true,
    numberwidth = 4,
    signcolumn = "yes",
    wrap = false,
    scrolloff = 8,
    sidescrolloff = 8,
  }

  ---  SETTINGS  ---

  vim.opt.shortmess:append "c"
  vim.opt.shortmess:append "I"
  vim.opt.whichwrap:append "<,>,[,],h,l"

  for k, v in pairs(default_options) do
    vim.opt[k] = v
  end
end

M.load_headless_options = function()
  vim.opt.shortmess = "" -- try to prevent echom from cutting messages off or prompting
  vim.opt.more = false -- don't pause listing when screen is filled
  vim.opt.cmdheight = 9999 -- helps avoiding |hit-enter| prompts.
  vim.opt.columns = 9999 -- set the widest screen possible
  vim.opt.swapfile = false -- don't use a swap file
end

M.load_defaults = function()
  if #vim.api.nvim_list_uis() == 0 then
    M.load_headless_options()
    return
  end
  M.load_default_options()
end

return M
