local cmd = vim.api.nvim_command

local apply_options = function(opts)
  for k, v in pairs(opts) do
    if v == true then
      cmd('set ' .. k)
    elseif v == false then
      cmd(string.format('set no%s', k))
    else
      cmd(string.format('set %s=%s', k, v))
    end
  end
end

vim.g.mapleader = " "
cmd("set clipboard+=unnamedplus")
cmd("set complete-=i")
cmd("set shortmess+=c")
-- change cwd to current directory
cmd("cd %:p:h")

-- Highlight yank area
vim.cmd("au TextYankPost * silent! lua vim.highlight.on_yank('Substitute', 300)")

local options = {
	autoindent = true,
	backup = false,
	writebackup = false,
	ruler = true,
	ttimeout = true,
	termguicolors = true,
	swapfile = false,
	mouse = "a", -- enable mouse support
	backspace = "indent,eol,start",
	timeoutlen = 500, -- timeout for mapped sequence
	ttimeoutlen = 100,
	colorcolumn = 120,
    lazyredraw = true,
    smarttab = true,

	-- tabs
	tabstop = 4,
	expandtab = true,
	softtabstop = 2,
	shiftwidth = 2,
    completeopt = 'menu,menuone,noinsert,noselect',

	-- visual
	foldmethod = "syntax",
	foldenable = false,
    showmode = false,
	number = true,
    relativenumber = true,
	wrap = true,
	laststatus = 2,
	hidden = true, -- Switch between buffers without having to save first
	cmdheight = 2,
	updatetime = 100,
	wildmenu = true,
	signcolumn = "yes",

	-- searching
	ignorecase = true,
	smartcase = true,
	hlsearch = true,
	incsearch = true,
	inccommand = "nosplit",

    -- split
    splitbelow = true,
    splitright = true,

}

apply_options(options)
