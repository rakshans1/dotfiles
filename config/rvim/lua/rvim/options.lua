vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Clipboard
vim.opt.clipboard = { 'unnamedplus' }

-- General
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.backup = false
vim.opt.cmdheight = 1
vim.opt.conceallevel = 0
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.title = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.opt.inccommand = 'split'
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = 'cursor'
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.o.timeoutlen = 300
vim.opt.writebackup = false
vim.opt.autoread = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.laststatus = 3
vim.opt.signcolumn = 'yes'
vim.opt.wrap = true
vim.opt.scrolloff = 8
vim.opt.guifont = 'FiraCode Nerd Font Mono:h13'
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.list = true
vim.opt.showbreak = '↪ '
vim.opt.foldnestmax = 20
vim.opt.foldminlines = 2
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.o.foldenable = true
vim.o.foldcolumn = '0'
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.tabclose = 'uselast'

vim.o.completeopt = 'menu,preview,noselect'

vim.o.showtabline = 2
vim.opt.sessionoptions =
  'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- Undercurl
vim.cmd [[let &t_Cs = "\e[4:3m"]]
vim.cmd [[let &t_Ce = "\e[4:0m"]]

-- Auto-reload files when changed externally
vim.api.nvim_create_autocmd(
  { 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' },
  {
    pattern = '*',
    command = "if mode() != 'c' | checktime | endif",
  }
)
