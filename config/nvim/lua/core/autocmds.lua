local M = {}
local Log = require "core.log"

--- Load the default set of autogroups and autocommands.
function M.load_defaults()
  local user_config_file = require("config"):get_user_config_path()

  if vim.loop.os_uname().version:match "Windows" then
    -- autocmds require forward slashes even on windows
    user_config_file = user_config_file:gsub("\\", "/")
  end

  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = {
      "Jaq",
      "qf",
      "help",
      "man",
      "lspinfo",
      "spectre_panel",
      "lir",
      "DressingSelect",
      "tsplayground",
      "Markdown",
    },
    callback = function()
      vim.cmd [[
      nnoremap <silent> <buffer> q :close<CR>
      nnoremap <silent> <buffer> <esc> :close<CR>
      set nobuflisted
    ]]
    end,
  })

  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "lir" },
    callback = function()
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    end,
  })

  local definitions = {
    {
      "TextYankPost",
      {
        group = "_general_settings",
        pattern = "*",
        desc = "Highlight text no yank",
        callback = function()
          require("vim.highlight").on_yank { higroup = "Search", timeout = 100 }
        end
      }
    },
    {
      "BufWinEnter",
      {
        group = "_general_settings",
        pattern = "dashboard",
        command = "setlocal cursorline signcolumn=yes cursorcolumn nonumber norelativenumber"
      }
    },
    {
      "FileType",
      {
        group = "_buffer_mappings",
        pattern = { "qf", "help", "man", "floaterm", "lspinfo", "lsp-installer", "null-ls-info", "dashboard" },
        command = "nnoremap <silent> <buffer> q :close<CR>",
      },
    },
    {
      "BufRead",
      {
        pattern = "*",
        command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o"
      }
    },
    {
      "BufNewFile",
      {
        pattern = "*",
        command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o"
      }
    },
    {
      "FileType",
      {
        group = "_filetype_settings",
        pattern = "qf",
        command = "set nobuflisted",
      },
    },
    {
      { "BufWinEnter", "BufRead", "BufNewFile" },
      {
        group = "_format_options",
        pattern = "*",
        command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
      },
    },
    {
      { "BufWinEnter", "BufRead", "BufNewFile" },
      {
        group = "_filetypechanges",
        pattern = ".zsh",
        command = "setlocal filetype=sh",
      },
    },
    {
      "FileType",
      {
        group = "_filetype_settings",
        pattern = "gitcommit",
        command = "setlocal wrap spell"
      }
    },
    {
      "FileType",
      {
        group = "_filetype_settings",
        pattern = "markdown",
        command = "setlocal wrap spell nofoldenable"
      }
    },
    {
      "VimResized",
      {
        group = "_auto_resize",
        pattern = "*",
        command = "tabdo wincmd =",
      },
    },
    {
      "CursorHold",
      {
        group = "_auto_read",
        pattern = "*",
        command = "silent! checktime"
      }
    },
    {
      { "BufEnter", "FocusGained", "InsertLeave" },
      {
        group = "_mode_switching",
        pattern = "*",
        command = "set number relativenumber"
      }
    },
    {
      { "BufLeave", "FocusLost", "InsertLeave" },
      {
        group = "_mode_switching",
        pattern = "*",
        command = "set number norelativenumber"
      }
    },
    {
      { "BufEnter", "FocusGained", "InsertLeave" },
      {
        group = "_mode_switching",
        pattern = "NvimTree",
        command = "set nonumber relativenumber"
      }
    },
    {
      { "BufLeave", "FocusLost", "InsertEnter" },
      {
        group = "_mode_switching",
        pattern = "NvimTree",
        command = "set nonumber norelativenumber"
      }
    }
  }

  M.define_autocmds(definitions)
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

function M.enable_format_on_save()
  local opts = get_format_on_save_opts()
  vim.api.nvim_create_augroup("lsp_format_on_save", {})
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = "lsp_format_on_save",
    pattern = opts.pattern,
    callback = function()
      require("lsp.utils").format { timeout_ms = opts.timeout, filter = opts.filter }
    end,
  })
  Log:debug "enabled format-on-save"
end

function M.disable_format_on_save()
  M.clear_augroup "lsp_format_on_save"
  Log:debug "disabled format-on-save"
end

function M.configure_format_on_save()
  if rvim.format_on_save then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

function M.toggle_format_on_save()
  local exists, autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = "lsp_format_on_save",
    event = "BufWritePre",
  })
  if not exists or #autocmds == 0 then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

function M.enable_transparent_mode()
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      local hl_groups = {
        "Normal",
        "SignColumn",
        "NormalNC",
        "TelescopeBorder",
        "NvimTreeNormal",
        "EndOfBuffer",
        "MsgArea",
      }
      for _, name in ipairs(hl_groups) do
        vim.cmd(string.format("highlight %s ctermbg=none guibg=none", name))
      end
    end,
  })
  vim.opt.fillchars = "eob: "
end

--- Clean autocommand in a group if it exists
--- This is safer than trying to delete the augroup itself
---@param name string the augroup name
function M.clear_augroup(name)
  -- defer the function in case the autocommand is still in-use
  Log:debug("request to clear autocmds  " .. name)
  vim.schedule(function()
    pcall(function()
      vim.api.nvim_clear_autocmds { group = name }
    end)
  end)
end

--- Create autocommand groups based on the passed definitions
--- Also creates the augroup automatically if it doesn't exist
---@param definitions table contains a tuple of event, opts, see `:h nvim_create_autocmd`
function M.define_autocmds(definitions)
  for _, entry in ipairs(definitions) do
    local event = entry[1]
    local opts = entry[2]
    if type(opts.group) == "string" and opts.group ~= "" then
      local exists, _ = pcall(vim.api.nvim_get_autocmds, { group = opts.group })
      if not exists then
        vim.api.nvim_create_augroup(opts.group, {})
      end
    end
    vim.api.nvim_create_autocmd(event, opts)
  end
end

return M
