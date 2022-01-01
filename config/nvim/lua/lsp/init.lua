
local M = {}
local Log = require "core.log"
local utils = require "utils"

local function lsp_highlight_document(client)
  if rvim.lsp.document_highlight == false then
    return -- we don't need further
  end
  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec(
      [[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
      false
    )
  end
end

local function lsp_code_lens_refresh(client)
  if rvim.lsp.code_lens_refresh == false then
    return
  end

  if client.resolved_capabilities.code_lens then
    vim.api.nvim_exec(
      [[
      augroup lsp_code_lens_refresh
        autocmd! * <buffer>
        autocmd InsertLeave <buffer> lua vim.lsp.codelens.refresh()
        autocmd InsertLeave <buffer> lua vim.lsp.codelens.display()
      augroup END
    ]],
      false
    )
  end
end

local function add_lsp_buffer_keybindings(bufnr)
  local mappings = {
    normal_mode = "n",
    insert_mode = "i",
    visual_mode = "v",
  }

  if rvim.builtin.which_key.active then
    -- Remap using which_key
    local status_ok, wk = pcall(require, "which-key")
    if not status_ok then
      return
    end
    for mode_name, mode_char in pairs(mappings) do
      wk.register(rvim.lsp.buffer_mappings[mode_name], { mode = mode_char, buffer = bufnr })
    end
  else
    -- Remap using nvim api
    for mode_name, mode_char in pairs(mappings) do
      for key, remap in pairs(rvim.lsp.buffer_mappings[mode_name]) do
        vim.api.nvim_buf_set_keymap(bufnr, mode_char, key, remap[1], { noremap = true, silent = true })
      end
    end
  end
end

function M.common_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }

  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
  end

  return capabilities
end

local function select_default_formater(client)
  if client.name == "null-ls" or not client.resolved_capabilities.document_formatting then
    return
  end
  Log:debug("Checking for formatter overriding for " .. client.name)
  local formatters = require "lsp.null-ls.formatters"
  local client_filetypes = client.config.filetypes or {}
  for _, filetype in ipairs(client_filetypes) do
    if #vim.tbl_keys(formatters.list_registered_providers(filetype)) > 0 then
      Log:debug("Formatter overriding detected. Disabling formatting capabilities for " .. client.name)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  end
end

function M.common_on_init(client, bufnr)
  if rvim.lsp.on_init_callback then
    rvim.lsp.on_init_callback(client, bufnr)
    Log:debug "Called lsp.on_init_callback"
    return
  end
  select_default_formater(client)
end

function M.common_on_attach(client, bufnr)
  if rvim.lsp.on_attach_callback then
    rvim.lsp.on_attach_callback(client, bufnr)
    Log:debug "Called lsp.on_attach_callback"
  end
  lsp_highlight_document(client)
  lsp_code_lens_refresh(client)
  add_lsp_buffer_keybindings(bufnr)
end

local function bootstrap_nlsp(opts)
  opts = opts or {}
  local lsp_settings_status_ok, lsp_settings = pcall(require, "nlspsettings")
  if lsp_settings_status_ok then
    lsp_settings.setup(opts)
  end
end

function M.get_common_opts()
  return {
    on_attach = M.common_on_attach,
    on_init = M.common_on_init,
    capabilities = M.common_capabilities(),
  }
end

local LSP_DEPRECATED_SIGN_MAP = {
  ["DiagnosticSignError"] = "LspDiagnosticsSignError",
  ["DiagnosticSignWarn"] = "LspDiagnosticsSignWarning",
  ["DiagnosticSignHint"] = "LspDiagnosticsSignHint",
  ["DiagnosticSignInfo"] = "LspDiagnosticsSignInformation",
}

function M.setup()
  Log:debug "Setting up LSP support"

  local lsp_status_ok, _ = pcall(require, "lspconfig")
  if not lsp_status_ok then
    return
  end

  local is_neovim_5 = vim.fn.has "nvim-0.6" ~= 1

  for _, sign in ipairs(rvim.lsp.diagnostics.signs.values) do
    local lsp_sign_name = LSP_DEPRECATED_SIGN_MAP[sign.name]
    if is_neovim_5 and lsp_sign_name then
      vim.fn.sign_define(lsp_sign_name, { texthl = lsp_sign_name, text = sign.text, numhl = lsp_sign_name })
    end
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end

  require("lsp.handlers").setup()

  if not utils.is_directory(rvim.lsp.templates_dir) then
    require("lsp.templates").generate_templates()
  end

  bootstrap_nlsp { config_home = utils.join_paths(get_config_dir(), "lsp-settings") }

  require("lsp.null-ls").setup()

  require("core.autocmds").configure_format_on_save()
end

return M

