vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  callback = function()
    vim.cmd 'set formatoptions-=cro'
  end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = {
    'netrw',
    'Jaq',
    'qf',
    'git',
    'help',
    'man',
    'lspinfo',
    'oil',
    'alpha',
    'spectre_panel',
    'lir',
    'DressingSelect',
    '',
  },
  callback = function()
    vim.cmd [[
      nnoremap <silent> <buffer> q :close<CR>
      set nobuflisted
    ]]
  end,
})

vim.api.nvim_create_autocmd({ 'CmdWinEnter' }, {
  callback = function()
    vim.cmd 'quit'
  end,
})

local auto_resize_group =
  vim.api.nvim_create_augroup('_auto_resize', { clear = true })
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  group = auto_resize_group,
  pattern = '*',
  command = [[
          let _auto_resize_current_tab = tabpagenr()
          tabdo wincmd =
          execute 'tabnext' _auto_resize_current_tab
        ]],
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = {
    'netrw',
    'Jaq',
    'qf',
    'git',
    'help',
    'man',
    'lspinfo',
    'oil',
    'spectre_panel',
    'lir',
    'DressingSelect',
    'neogitstatus',
    'alpha',
    'notify',
    'dashboard',
    'Trouble',
    'toggleterm',
    '',
  },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

vim.api.nvim_create_autocmd({ 'WinEnter', 'WinNew' }, {
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(win)
    -- Only adjust floating windows (those with a non-empty 'relative' field)
    if config.relative ~= '' then
      vim.api.nvim_set_option_value('winblend', 0, { win = win })
    end
  end,
})

local claude_term_group =
  vim.api.nvim_create_augroup('_claude_term_mouse', { clear = true })

local saved_mouse = nil

local function is_claude_term(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return false end
  if vim.bo[buf].buftype ~= 'terminal' then return false end
  local title = (vim.b[buf].term_title or ''):lower()
  return title:find 'claude' ~= nil
end

local function refresh_claude_mouse()
  local buf = vim.api.nvim_get_current_buf()
  if is_claude_term(buf) then
    if saved_mouse == nil then
      saved_mouse = vim.o.mouse
      vim.opt.mouse = ''
    end
  elseif saved_mouse ~= nil then
    vim.opt.mouse = saved_mouse
    saved_mouse = nil
  end
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'TermRequest', 'TermLeave' }, {
  group = claude_term_group,
  callback = vim.schedule_wrap(refresh_claude_mouse),
})
