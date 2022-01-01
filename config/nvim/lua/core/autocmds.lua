local autocommands = {}
local config = require "config"

rvim.autocommands = {
  _general_settings = {
    {
      "Filetype",
      "*",
      "lua require('utils.ft').do_filetype(vim.fn.expand(\"<amatch>\"))",
    },
    {
      "FileType",
      "qf",
      "nnoremap <silent> <buffer> q :q<CR>",
    },
    {
      "FileType",
      "lsp-installer",
      "nnoremap <silent> <buffer> q :q<CR>",
    },
    {
      "TextYankPost",
      "*",
      "lua require('vim.highlight').on_yank({higroup = 'Search', timeout = 200})",
    },
    {
      "BufWinEnter",
      "*",
      "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
    },
    {
      "BufWinEnter",
      "dashboard",
      "setlocal cursorline signcolumn=yes cursorcolumn nonumber norelativenumber",
    },
    {
      "BufRead",
      "*",
      "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
    },
    {
      "BufNewFile",
      "*",
      "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
    },
    { "BufWritePost", config.path, "lua require('utils').reload_config()" },
    {
      "FileType",
      "qf",
      "set nobuflisted",
    },
    -- { "VimLeavePre", "*", "set title set titleold=" },
  },
  _filetypechanges = {
    { "BufWinEnter", ".zsh", "setlocal filetype=sh" },
    { "BufRead", "*.zsh", "setlocal filetype=sh" },
    { "BufNewFile", "*.zsh", "setlocal filetype=sh" },
  },
  _git = {
    { "FileType", "gitcommit", "setlocal wrap" },
    { "FileType", "gitcommit", "setlocal spell" },
  },
  _markdown = {
    { "FileType", "markdown", "setlocal wrap" },
    { "FileType", "markdown", "setlocal spell" },
  },
  _buffer_bindings = {
    { "FileType", "floaterm", "nnoremap <silent> <buffer> q :q<CR>" },
  },
  _auto_resize = {
    -- will cause split windows to be resized evenly if main window is resized
    { "VimResized", "*", "wincmd =" },
  },
  _auto_read = {
    { "CursorHold", "*", "silent! checktime" },
  },
  _general_lsp = {
    { "FileType", "lspinfo", "nnoremap <silent> <buffer> q :q<CR>" },
  },
  _mode_switching = {
    -- will switch between absolute and relative line numbers depending on mode
    {'BufEnter,FocusGained,InsertLeave', '*', 'set number relativenumber'},
    {'BufLeave,FocusLost,InsertEnter', '*', 'set number norelativenumber'},
  },
  custom_groups = {},
}

function autocommands.define_augroups(definitions) -- {{{1
  -- Create autocommand groups based on the passed definitions
  --
  -- The key will be the name of the group, and each definition
  -- within the group should have:
  --    1. Trigger
  --    2. Pattern
  --    3. Text
  -- just like how they would normally be defined from Vim itself
  for group_name, definition in pairs(definitions) do
    vim.cmd("augroup " .. group_name)
    vim.cmd "autocmd!"

    for _, def in pairs(definition) do
      local command = table.concat(vim.tbl_flatten { "autocmd", def }, " ")
      vim.cmd(command)
    end

    vim.cmd "augroup END"
  end
end

return autocommands
