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
  '<leader>n',
  '<cmd>lua Snacks.picker.explorer({ hidden = true })<cr>',
  { desc = 'Open Explorer with leader' }
)
map(
  'n',
  '<C-p>',
  '<cmd>lua Snacks.picker.files({ hidden = true })<cr>',
  { desc = 'Find git files' }
)
map(
  'n',
  '<leader>p',
  '<cmd>lua Snacks.picker.files({ hidden = true })<cr>',
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
  '<leader>fb',
  '<cmd>lua Snacks.picker.buffers()<cr>',
  { desc = 'Find buffers' }
)
map(
  'n',
  '<leader>fr',
  '<cmd>lua Snacks.picker.recents()<cr>',
  { desc = 'Snacks marks' }
)
map(
  'n',
  '<leader>fg',
  '<cmd>lua Snacks.picker.files({ hidden = true })<cr>',
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
-- map(
--   'n',
--   '<leader>gd',
--   '<cmd>lua Snacks.picker.git_diff()<cr>',
--   { desc = 'Git Diff' }
-- )
-- map(
--   'n',
--   '<leader>gL',
--   '<cmd>lua Snacks.picker.git_log()<cr>',
--   { desc = 'Git Log' }
-- )
-- map(
--   'n',
--   '<leader>gf',
--   '<cmd>lua Snacks.picker.git_log_file()<cr>',
--   { desc = 'Git log file' }
-- )
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
  '<cmd>lua Snacks.gitbrowse()<CR>',
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
  '<leader>sc',
  '<cmd>lua Snacks.picker.commands()<cr>',
  { desc = 'Search command' }
)
map(
  'n',
  '<leader>sC',
  '<cmd>lua Snacks.picker.command_history()<cr>',
  { desc = 'Search command history' }
)
map(
  'n',
  '<leader>vr',
  '<cmd>lua Snacks.picker.registers()<cr>',
  { desc = 'Search registers' }
)
map(
  'n',
  '<leader>vu',
  '<cmd>lua Snacks.picker.undo()<cr>',
  { desc = 'Snacks undo' }
)
map(
  'n',
  '<leader>sh',
  '<cmd>lua Snacks.picker.help()<cr>',
  { desc = 'Search help' }
)
map(
  'n',
  '<leader>vh',
  '<cmd>lua Snacks.picker.highlights()<cr>',
  { desc = 'Search highlights' }
)
map(
  'n',
  '<leader>vi',
  '<cmd>lua Snacks.picker.icons()<cr>',
  { desc = 'Search icons' }
)
map(
  'n',
  '<Leader>vn',
  '<cmd>lua Snacks.notifier.show_history()<CR>',
  { desc = 'View notifications' }
)
map(
  'n',
  '<leader>vk',
  '<cmd>lua Snacks.picker.keymaps()<cr>',
  { desc = 'Search keymaps' }
)
map('n', '<leader>vp', function()
  local file = vim.fn.expand '%:p'
  if file == '' then
    vim.notify('No file in current buffer', vim.log.levels.WARN)
    return
  end

  -- Get git root
  local git_root = vim.fn.systemlist(
    'git -C '
      .. vim.fn.shellescape(vim.fn.fnamemodify(file, ':h'))
      .. ' rev-parse --show-toplevel'
  )[1]

  if git_root and git_root ~= '' and not git_root:match '^fatal:' then
    local path_from_git_root = file:sub(#git_root + 2) -- +2 to skip the trailing slash
    vim.fn.setreg('+', path_from_git_root)
    require('snacks').notify.info('Yanked `' .. path_from_git_root .. '`')
  else
    vim.notify('Not in a git repository', vim.log.levels.WARN)
  end
end, { desc = 'Copy git root path' })
-- Snacks pickers (lsp) [l]
map(
  'n',
  '<leader>ld',
  '<cmd>lua Snacks.picker.diagnostics()<cr>',
  { desc = 'Snacks diagnostics' }
)
map(
  'n',
  '<leader>o',
  '<cmd>lua Snacks.picker.lsp_symbols()<cr>',
  { desc = 'Outline' }
)

-- Other keymaps
map(
  'n',
  '<leader>fR',
  '<cmd>lua Snacks.rename.rename_file()<cr>',
  { desc = 'Rename file' }
)
map(
  'n',
  '<leader>r',
  '<cmd>lua Snacks.picker.grep()<cr>',
  { desc = 'Grep Search' }
)

-- Snacks terminal keymaps [t]
-- map(
--   'n',
--   '<leader>tt',
--   '<cmd>lua Snacks.terminal()<cr>',
--   { desc = 'Toggle Terminal' }
-- )
-- map(
--   { 'n', 't' },
--   '\\',
--   '<cmd>lua Snacks.terminal()<cr>',
--   { desc = 'Open Terminal in Tab' }
-- )
-- map(
--   'n',
--   '<leader>tn',
--   '<cmd>lua Snacks.terminal.open(nil, { win = { position = "bottom" } })<cr>',
--   { desc = 'Open Terminal in Split' }
-- )
