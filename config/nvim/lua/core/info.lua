local M = {
  banner = {
    "",
  },
}

local fmt = string.format
local text = require "interface.text"
local lsp_utils = require "lsp.utils"

local function str_list(list)
  return fmt("[ %s ]", table.concat(list, ", "))
end

local function make_formatters_info(ft)
  local null_formatters = require "lsp.null-ls.formatters"
  local registered_formatters = null_formatters.list_registered(ft)
  local supported_formatters = null_formatters.list_supported(ft)

  local section = {
    "Formatters info",
    fmt(
      "* Active: %s%s",
      table.concat(registered_formatters, "  , "),
      vim.tbl_count(registered_formatters) > 0 and "  " or ""
    ),
    fmt("* Supported: %s", str_list(supported_formatters)),
  }

  return section
end

local function make_code_actions_info(ft)
  local null_actions = require "lsp.null-ls.code_actions"
  local registered_actions = null_actions.list_registered(ft)
  local section = {
    "Code actions info",
    fmt(
      "* Active: %s%s",
      table.concat(registered_actions, "  , "),
      vim.tbl_count(registered_actions) > 0 and "  " or ""
    ),
    fmt("* Supported: %s", str_list(supported_actions)),
  }

  return section
end

local function make_linters_info(ft)
  local null_linters = require "lsp.null-ls.linters"
  local supported_linters = null_linters.list_supported(ft)
  local registered_linters = null_linters.list_registered(ft)
  local section = {
    "Linters info",
    fmt(
      "* Active: %s%s",
      table.concat(registered_linters, "  , "),
      vim.tbl_count(registered_linters) > 0 and "  " or ""
    ),
    fmt("* Supported: %s", str_list(supported_linters)),
  }

  return section
end

local function tbl_set_highlight(terms, highlight_group)
  for _, v in pairs(terms) do
    vim.cmd('let m=matchadd("' .. highlight_group .. '", "' .. v .. "[ ,│']\")")
  end
end

local function make_client_info(client)
  local client_enabled_caps = lsp_utils.get_client_capabilities(client.id)
  local name = client.name
  local id = client.id
  local filetypes = lsp_utils.get_supported_filetypes(name)
  local document_formatting = client.resolved_capabilities.document_formatting
  local attached_buffers_list = table.concat(vim.lsp.get_buffers_by_client_id(client.id), ", ")
  local client_info = {
    fmt("* Name:                      %s", name),
    fmt("* Id:                        [%s]", tostring(id)),
    fmt("* filetype(s):               [%s]", table.concat(filetypes, ", ")),
    fmt("* Attached buffers:          [%s]", tostring(attached_buffers_list)),
    fmt("* Supports formatting:       %s", tostring(document_formatting)),
  }
  if not vim.tbl_isempty(client_enabled_caps) then
    local caps_text = "* Capabilities list:         "
    local caps_text_len = caps_text:len()
    local enabled_caps = text.format_table(client_enabled_caps, 3, " | ")
    enabled_caps = text.shift_right(enabled_caps, caps_text_len)
    enabled_caps[1] = fmt("%s%s", caps_text, enabled_caps[1]:sub(caps_text_len + 1))
    vim.list_extend(client_info, enabled_caps)
  end

  return client_info
end

function M.toggle_popup(ft)
  local clients = lsp_utils.get_active_clients_by_ft(ft)
  local client_names = {}
  local bufnr = vim.api.nvim_get_current_buf()
  local ts_active_buffers = vim.tbl_keys(vim.treesitter.highlighter.active)
  local is_treesitter_active = function()
    local status = "inactive"
    if vim.tbl_contains(ts_active_buffers, bufnr) then
      status = "active"
    end
    return status
  end
  local header = {
    fmt("Detected filetype:           %s", ft),
    fmt("Current buffer number:       [%s]", bufnr),
  }

  local ts_info = {
    "Treesitter info",
    fmt("* current buffer:            %s", is_treesitter_active()),
    fmt("* list:                      [%s]", table.concat(ts_active_buffers, ", ")),
  }

  local lsp_info = {
    "Language Server Protocol (LSP) info",
    fmt "* Active server(s):",
  }

  for _, client in pairs(clients) do
    vim.list_extend(lsp_info, make_client_info(client))
    table.insert(client_names, client.name)
  end

  local formatters_info = make_formatters_info(ft)

  local linters_info = make_linters_info(ft)

  local code_actions_info = make_code_actions_info(ft)

  local content_provider = function(popup)
    local content = {}

    for _, section in ipairs {
      M.banner,
      { "" },
      { "" },
      header,
      { "" },
      ts_info,
      { "" },
      lsp_info,
      { "" },
      formatters_info,
      { "" },
      linters_info,
      { "" },
      code_actions_info,
    } do
      vim.list_extend(content, section)
    end

    return text.align_left(popup, content, 0.5)
  end

  local function set_syntax_hl()
    vim.cmd [[highlight rvimInfoIdentifier gui=bold]]
    vim.cmd [[highlight link rvimInfoHeader Type]]
    vim.fn.matchadd("rvimInfoHeader", "Treesitter info")
    vim.fn.matchadd("rvimInfoHeader", "Language Server Protocol (LSP) info")
    vim.fn.matchadd("rvimInfoHeader", "Formatters info")
    vim.fn.matchadd("rvimInfoHeader", "Linters info")
    vim.fn.matchadd("rvimInfoHeader", "Code actions info")
    vim.fn.matchadd("rvimInfoIdentifier", " " .. ft .. "$")
    vim.fn.matchadd("string", "true")
    vim.fn.matchadd("string", "active")
    vim.fn.matchadd("string", "")
    vim.fn.matchadd("boolean", "inactive")
    vim.fn.matchadd("error", "false")
    tbl_set_highlight(require("lsp.null-ls.formatters").list_registered(ft), "rvimInfoIdentifier")
    tbl_set_highlight(require("lsp.null-ls.linters").list_registered(ft), "rvimInfoIdentifier")
    tbl_set_highlight(require("lsp.null-ls.code_actions").list_registered(ft), "rvimInfoIdentifier")
  end

  local Popup = require("interface.popup"):new {
    win_opts = { number = false },
    buf_opts = { modifiable = false, filetype = "lspinfo" },
  }
  Popup:display(content_provider)
  set_syntax_hl()

  return Popup
end
return M
