-- Helper function for key mappings
local function map(mode, key, action, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, key, action, options)
end

-- LSP (keymaps)
map(
  'n',
  'gI',
  '<cmd>lua vim.lsp.buf.implementation()<cr>',
  { desc = 'Type [D]efinition' }
)
map(
  'n',
  '<leader>le',
  '<cmd>lua vim.diagnostic.open_float()<CR>',
  { desc = 'LSP diagnostics at cursor' }
)
map(
  'n',
  '<leader>la',
  '<cmd>Lspsaga code_action<cr>',
  { desc = 'Lspsaga code action' }
)
map(
  'n',
  '<leader>lp',
  '<cmd>Lspsaga peek_definition<cr>',
  { desc = 'Lspsaga peek definition' }
)
map('n', '<leader>lf', '<cmd>Lspsaga finder<cr>', { desc = 'Lspsaga finder' })
map('n', '<leader>li', '<cmd>LspInfo<cr>', { desc = 'LSP info' })
map(
  'n',
  ']d',
  '<cmd>Lspsaga diagnostic_jump_next<CR>',
  { desc = 'next Lspsaga diagnostic' }
)
map(
  'n',
  '[d',
  '<cmd>Lspsaga diagnostic_jump_prev<cr>',
  { desc = 'previous Lspsaga diagnostic' }
)
map(
  'n',
  '<leader>ll',
  '<cmd>lua vim.lsp.codelens.run()<cr>',
  { desc = 'Run code lens' }
)
map('n', '<leader>lo', '<cmd>Lspsaga outline<cr>', { desc = 'Lspsaga outline' })
map(
  'n',
  '<leader>lI',
  '<cmd>Lspsaga incoming_calls<cr>',
  { desc = 'Lspsaga incoming calls' }
)
map(
  'n',
  '<leader>lO',
  '<cmd>Lspsaga outgoing_calls<cr>',
  { desc = 'Lspsaga outgoing calls' }
)
map(
  'n',
  'gd',
  '<cmd>Lspsaga goto_definition<cr>',
  { desc = 'Lspsaga goto definition' }
)
map(
  'n',
  'gD',
  '<cmd>vsplit | lua vim.lsp.buf.definition()<cr>',
  { desc = 'Lspsaga goto definition' }
)
-- LSP (rename)
map('n', '<Leader>lr', ':IncRename ', { desc = 'Incremental rename' })
-- LSP (documentation generation)
map('n', '<Leader>lg', "<cmd>lua require('neogen').generate()<CR>", {
  desc = 'Generate documentation (neogen)',
})
-- Getting highlights at cursor
map(
  'n',
  '<leader>lh',
  '<cmd>lua vim.notify(vim.inspect(vim.treesitter.get_captures_at_cursor(0)))<CR>',
  { desc = 'Get highlight at cursor' }
)
-- disable LSP (diagnostics) in current buffer
map(
  'n',
  '<leader>lD',
  '<cmd>lua vim.diagnostic.enable(false)<CR>',
  { desc = 'Disable LSP in current buffer' }
)
-- Noice LSP documentation scrolling
vim.keymap.set({ 'n', 'i', 's' }, '<c-f>', function()
  if not require('noice.lsp').scroll(4) then
    return '<c-f>'
  end
end, { silent = true, expr = true })

-- vim.keymap.set({ 'n', 'i', 's' }, '<c-b>', function()
--   if not require('noice.lsp').scroll(-4) then
--     return '<c-b>'
--   end
-- end, { silent = true, expr = true })

-- sessions ([P]ossession)
map(
  'n',
  '<leader>pl',
  '<cmd>PossessionLoadCwd<cr>',
  { desc = 'Possession Load' }
)
map('n', '<leader>ps', '<cmd>PossessionSave<cr>', { desc = 'Possession Save' })
map(
  'n',
  '<leader>pr',
  '<cmd>PossessionRename<cr>',
  { desc = 'Possession Rename' }
)
map('n', '<leader>pq', '<cmd>PossessionClose<cr>', { desc = 'Possession Quit' })
map(
  'n',
  '<leader>pd',
  '<cmd>PossessionDelete<cr>',
  { desc = 'Possession Delete' }
)
map('n', '<leader>pp', '<cmd>PossessionPick<cr>', { desc = 'Possession Pick' })
map(
  'n',
  '<leader>e',
  '<cmd>lua MiniSnippets.expand()<cr>',
  { desc = 'MiniSnippets expand' }
)
