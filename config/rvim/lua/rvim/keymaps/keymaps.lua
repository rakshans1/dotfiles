-- Set global leaders
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Helper function for key mappings
local function map(mode, key, action, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, key, action, options)
end

-- Disable Space (noop)
map('n', '<Space>', '<Nop>')

-- -- Paste keymaps (HACK: Avoid being overwritten)
-- map('n', 'p', 'p')
-- map('n', 'P', 'P')

-- Window splitting
map('n', '<Leader>wv', '<cmd>vsplit<CR>', { desc = 'Vertical split' })
map('n', '<Leader>ws', '<cmd>split<CR>', { desc = 'Horizontal split' })

-- Window navigation
map('n', '<C-h>', '<C-w>h', { desc = 'Move to the window on the left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Move to the window below' })
map('n', '<C-k>', '<C-w>k', { desc = 'Move to the window above' })
map('n', '<C-l>', '<C-w>l', { desc = 'Move to the window on the right' })

-- Set/unset options
map('n', '<Leader>uw', '<cmd>set wrap!<CR>', { desc = 'Toggle wrap' })
map('n', '<Leader>us', '<cmd>set spell!<CR>', { desc = 'Toggle spell check' })

-- Tab navigation
map('n', '[t', '<cmd>tabprevious<CR>', { desc = 'Previous tab' })
map('n', ']t', '<cmd>tabnext<CR>', { desc = 'Next tab' })

-- Resize window with Ctrl + arrow keys
map('n', '<C-Up>', '<cmd>resize +4<CR>', { desc = 'Increase window height' })
map('n', '<C-Down>', '<cmd>resize -4<CR>', { desc = 'Decrease window height' })
map(
  'n',
  '<C-Left>',
  '<cmd>vertical resize +4<CR>',
  { desc = 'Increase window width' }
)
map(
  'n',
  '<C-Right>',
  '<cmd>vertical resize -4<CR>',
  { desc = 'Decrease window width' }
)
map(
  'n',
  '<Leader>w=',
  '<cmd>tabdo wincmd =<CR>',
  { desc = 'Window auto resize' }
)

-- Navigate buffers
map('n', '[b', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
map('n', ']b', '<cmd>bnext<CR>', { desc = 'Next buffer' })

-- Tab management
map('n', '<C-t>', '<cmd>tabnew<CR>', { desc = 'New tab' })

-- Turn off search highlight
map('n', '<C-n>', '<cmd>nohl<CR>', { desc = 'Clear search highlight' })

-- Save files
map('n', '<C-s>', '<cmd>w<CR>', { desc = 'Save file' })

-- Close buffers, windows and tabs
map(
  'n',
  '<Leader>qb',
  "<cmd>lua require('snacks').bufdelete()<CR>",
  { desc = 'Delete buffer' }
)
map(
  'n',
  '<Leader>qB',
  "<cmd>lua require('snacks').bufdelete.all()<CR>",
  { desc = 'Delete all buffers' }
)
map('n', '<Leader>qw', '<cmd>q<CR>', { desc = 'Close window' })
map('n', '<Leader>qt', '<cmd>tabclose<CR>', { desc = 'Close tab' })
map('n', '<Leader>qa', '<cmd>qa<CR>', { desc = 'Close all and quit' })

-- Stay in visual mode while indenting
map('v', '<', '<gv', { desc = 'Indent left' })
map('v', '>', '>gv', { desc = 'Indent right' })

-- Macros
map('n', 'Q', '@qj', { desc = 'Run q macro' })
map('x', 'Q', ':norm @q<CR>', { desc = 'Run q macro' })
