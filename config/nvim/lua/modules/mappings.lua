local utils = require 'utils'
local nmap = utils.nmap
local nnoremap = utils.nnoremap
local noremap = utils.noremap
local xnoremap = utils.xnoremap
local vmap = utils.vmap
local inoremap = utils.inoremap
local imap = utils.imap

nmap('<leader>z', '<Plug>Zoom')
nnoremap ('<C-x>', ':q!<CR>')

-- ----------Buffer------
--  Switch between buffer
nnoremap('[b', ':bprev<CR>')
nnoremap(']b', ':bnext<CR>')

local function t(str)
    -- Adjust boolean arguments as needed
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- ----------Searching------
-- clear highlighted search
noremap('<leader>c',':set hlsearch! hlsearch?<cr>')
-- Find and replace in current file
nnoremap('<leader>h', ":let @s=expand('<cword>')<CR>:%s/<C-r>s/<C-r>s/<Left>")
xnoremap('<leader>h', '"sy:%s/<C-r>s//<Left>')

-- yank till end
nnoremap("Y", "y$")


-- ----------Split Mapping------
nmap('<C-j>','<C-W><C-J>') -- Move to bottom window
nmap('<C-k>','<C-W><C-K>') -- Move to top window
nmap('<C-h>','<C-W><C-H>') -- Move to left window
nmap('<C-l>','<C-W><C-L>') -- Move to right window

nnoremap('+',':exe "vertical resize +5"<CR>')
nnoremap('-',':exe "vertical resize -5"<CR>')

-- Make ctrl+s work
nmap('<c-s>',':w<cr>')
imap('<c-s>','<esc>:w<cr>a')


-- ----------Mapping------
-- keep visual selection when indenting/outdenting
vmap('<','<gv')
vmap('>','>gv')

-- Movement in insert mode
inoremap('<C-h>','<C-o>h')
inoremap('<C-l>','<C-o>a')
inoremap('<C-j>','<C-o>j')
inoremap('<C-k>','<C-o>k')

-- Moving lines
xnoremap('<C-j>', ":move'>+<cr>gv")
xnoremap('<C-k>', ':move-2<cr>gv')
