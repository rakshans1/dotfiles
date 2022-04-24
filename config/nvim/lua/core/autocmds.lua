local M = {}
local Log = require "core.log"

--- Load the default set of autogroups and autocommands.
function M.load_augroups()
  local user_config_file = require("config"):get_user_config_path()

  if vim.loop.os_uname().version:match "Windows" then
    -- autocmds require forward slashes even on windows
    user_config_file = user_config_file:gsub("\\", "/")
  end

  return {
    _general_settings = {
      { "FileType", "qf,help,man", "nnoremap <silent> <buffer> q :close<CR>" },
      {
        "TextYankPost",
        "*",
        "lua require('vim.highlight').on_yank({higroup = 'Search', timeout = 200})",
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
      { "FileType", "qf", "set nobuflisted" },
    },
    _formatoptions = {
      {
        "BufWinEnter,BufRead,BufNewFile",
        "*",
        "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
      },
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
      {'BufEnter,FocusGained,InsertLeave', 'NvimTree', 'set nonumber norelativenumber'},
      {'BufLeave,FocusLost,InsertEnter', 'NvimTree', 'set nonumber norelativenumber'},
    },
    custom_groups = {},
  }
end

local get_format_on_save_opts = function()
  local defaults = require("config.defaults").format_on_save
  -- accept a basic boolean `rvim.format_on_save=true`
  if type(rvim.format_on_save) ~= "table" then
    return defaults
  end

  return {
    pattern = rvim.format_on_save.pattern or defaults.pattern,
    timeout = rvim.format_on_save.timeout or defaults.timeout,
  }
end

function M.enable_format_on_save(opts)
  local fmd_cmd = string.format(":silent lua vim.lsp.buf.formatting_sync({}, %s)", opts.timeout)
  M.define_augroups {
    format_on_save = { { "BufWritePre", opts.pattern, fmd_cmd } },
  }
  Log:debug "enabled format-on-save"
end

function M.disable_format_on_save()
  M.disable_augroup "format_on_save"
  Log:debug "disabled format-on-save"
end

function M.configure_format_on_save()
  if rvim.format_on_save then
    local opts = get_format_on_save_opts()
    M.enable_format_on_save(opts)
  else
    M.disable_format_on_save()
  end
end

function M.toggle_format_on_save()
  if vim.fn.exists "#format_on_save#BufWritePre" == 0 then
    local opts = get_format_on_save_opts()
    M.enable_format_on_save(opts)
  else
    M.disable_format_on_save()
  end
end

function M.enable_lsp_document_highlight(client_id)
  M.define_augroups({
    lsp_document_highlight = {
      {
        "CursorHold",
        "<buffer>",
        string.format("lua require('lsp.utils').conditional_document_highlight(%d)", client_id),
      },
      {
        "CursorMoved",
        "<buffer>",
        "lua vim.lsp.buf.clear_references()",
      },
    },
  }, true)
end

function M.disable_lsp_document_highlight()
  M.disable_augroup "lsp_document_highlight"
end

function M.enable_code_lens_refresh()
  M.define_augroups({
    lsp_code_lens_refresh = {
      {
        "InsertLeave ",
        "<buffer>",
        "lua vim.lsp.codelens.refresh()",
      },
      {
        "InsertLeave ",
        "<buffer>",
        "lua vim.lsp.codelens.display()",
      },
    },
  }, true)
end

function M.disable_code_lens_refresh()
  M.disable_augroup "lsp_code_lens_refresh"
end

function M.enable_transparent_mode()
  vim.cmd "au ColorScheme * hi Normal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi SignColumn ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NormalNC ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi MsgArea ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi TelescopeBorder ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi EndOfBuffer ctermbg=none guibg=none"
  vim.cmd "let &fcs='eob: '"
end

--- Disable autocommand groups if it exists
--- This is more reliable than trying to delete the augroup itself
---@param name string the augroup name
function M.disable_augroup(name)
  -- defer the function in case the autocommand is still in-use
  vim.schedule(function()
    if vim.fn.exists("#" .. name) == 1 then
      vim.cmd("augroup " .. name)
      vim.cmd "autocmd!"
      vim.cmd "augroup END"
    end
  end)
end

--- Create autocommand groups based on the passed definitions
---@param definitions table contains trigger, pattern and text. The key will be used as a group name
---@param buffer boolean indicate if the augroup should be local to the buffer
function M.define_augroups(definitions, buffer)
  for group_name, definition in pairs(definitions) do
    vim.cmd("augroup " .. group_name)
    if buffer then
      vim.cmd [[autocmd! * <buffer>]]
    else
      vim.cmd [[autocmd!]]
    end

    for _, def in pairs(definition) do
      local command = table.concat(vim.tbl_flatten { "autocmd", def }, " ")
      vim.cmd(command)
    end

    vim.cmd "augroup END"
  end
end

return M
