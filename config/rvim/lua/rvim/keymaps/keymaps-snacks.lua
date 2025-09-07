-- Helper function for key mappings
local function map(mode, key, action, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, key, action, options)
end

-- Snacks pickers (find) [f]
map(
  'n',
  '<leader>o',
  '<cmd>lua Snacks.picker.git_files({untracked=true})<cr>',
  { desc = 'Find git files' }
)
map(
  'n',
  '<leader>b',
  '<cmd>lua Snacks.picker.buffers()<cr>',
  { desc = 'Find buffers' }
)
map(
  'n',
  '<leader>ff',
  '<cmd>lua Snacks.picker.files()<cr>',
  { desc = 'Find files' }
)
map(
  'n',
  '<leader>fb',
  '<cmd>lua Snacks.picker.buffers()<cr>',
  { desc = 'Find buffers' }
)
map(
  'n',
  '<leader>fg',
  '<cmd>lua Snacks.picker.git_files()<cr>',
  { desc = 'Find git files' }
)
map(
  'n',
  '<leader>fp',
  '<cmd>lua Snacks.picker.projects()<cr>',
  { desc = 'Find projects' }
)
map(
  'n',
  '<leader>fj',
  '<cmd>lua Snacks.picker.jumps()<cr>',
  { desc = 'Snacks jumplist' }
)
map(
  'n',
  '<leader>fm',
  '<cmd>lua Snacks.picker.marks()<cr>',
  { desc = 'Snacks marks' }
)

-- Snacks pickers (git) [g]
map(
  'n',
  '<leader>gL',
  '<cmd>lua Snacks.picker.git_log()<cr>',
  { desc = 'Git Log' }
)
map(
  'n',
  '<leader>gf',
  '<cmd>lua Snacks.picker.git_log_file()<cr>',
  { desc = 'Git log file' }
)
map(
  'n',
  '<leader>gb',
  '<cmd>lua Snacks.git.blame_line()<cr>',
  { desc = 'Git blame line' }
)
map(
  'n',
  '<leader>gl',
  '<cmd>lua Snacks.lazygit.open()<CR>',
  { desc = 'LazyGit' }
)
map(
  'n',
  '<leader>go',
  '"<cmd>lua Snacks.gitbrowse()<CR>"',
  { desc = 'Git browse' }
)

-- Snacks pickers (search) [s]
map(
  'n',
  '<leader>sg',
  '<cmd>lua Snacks.picker.grep()<cr>',
  { desc = 'Grep search (all)' }
)
map(
  'n',
  '<leader>sf',
  '<cmd>lua Snacks.picker.lines()<cr>',
  { desc = 'Grep search (current file)' }
)
map(
  'n',
  '<leader>sb',
  '<cmd>lua Snacks.picker.grep_buffers()<cr>',
  { desc = 'Grep search (buffers)' }
)
map(
  'n',
  '<leader>st',
  '<cmd>lua Snacks.picker.todo_comments()<cr>',
  { desc = 'Find todos' }
)

-- Snacks pickers (misc) [t]
map(
  'n',
  '<leader>tc',
  '<cmd>lua Snacks.picker.command_history()<cr>',
  { desc = 'Search command history' }
)
map(
  'n',
  '<leader>tr',
  '<cmd>lua Snacks.picker.registers()<cr>',
  { desc = 'Search registers' }
)
map(
  'n',
  '<leader>tu',
  '<cmd>lua Snacks.picker.undo()<cr>',
  { desc = 'Snacks undo' }
)
map(
  'n',
  '<leader>th',
  '<cmd>lua Snacks.picker.help()<cr>',
  { desc = 'Search help' }
)
map(
  'n',
  '<leader>tH',
  '<cmd>lua Snacks.picker.highlights()<cr>',
  { desc = 'Search highlights' }
)
map(
  'n',
  '<leader>ti',
  '<cmd>lua Snacks.picker.icons()<cr>',
  { desc = 'Search icons' }
)
map(
  'n',
  '<leader>tk',
  '<cmd>lua Snacks.picker.keymaps()<cr>',
  { desc = 'Search keymaps' }
)
map(
  'n',
  '<leader>ty',
  '<cmd>YankyRingHistory<cr>',
  { desc = 'Search yank history' }
)

-- Snacks pickers (lsp) [l]
map(
  'n',
  '<leader>ld',
  '<cmd>lua Snacks.picker.diagnostics()<cr>',
  { desc = 'Snacks diagnostics' }
)
map(
  'n',
  '<leader>ls',
  '<cmd>lua Snacks.picker.lsp_symbols()<cr>',
  { desc = 'LSP symbols' }
)

-- Other keymaps
map(
  'n',
  '<leader>rr',
  '<cmd>lua Snacks.rename.rename_file()<cr>',
  { desc = 'Rename file' }
)
map(
  'n',
  '<leader>ns',
  '<cmd>lua Snacks.scratch.select()<cr>',
  { desc = 'Toggle scratch buffer' }
)
map(
  'n',
  '<leader>T',
  '<cmd>lua Snacks.terminal.toggle()<cr>',
  { desc = 'Toggle Snacks terminal' }
)
map(
  'n',
  '<Leader>tn',
  '<cmd>lua Snacks.notifier.show_history()<CR>',
  { desc = 'View notifications' }
)
