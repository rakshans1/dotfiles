local M = {}

local servers = require 'rvim.lsps.servers'
local server_names = vim.tbl_keys(servers)
local server_set = {}
local configured = false

table.sort(server_names)

for _, name in ipairs(server_names) do
  server_set[name] = true
end

local function copilot_enabled()
  if not package.loaded['copilot.client'] then
    return false
  end

  return not require('copilot.client').is_disabled()
end

local function stop_uninitialized_clients()
  for _, client in ipairs(vim.lsp.get_clients { _uninitialized = true }) do
    if
      not client.initialized
      and (server_set[client.name] or client.name == 'copilot')
    then
      client:stop(true)
    end
  end
end

function M.configure()
  if configured then
    return
  end

  local default_config = {
    capabilities = require('blink.cmp').get_lsp_capabilities({}, true),
    on_attach = function(_, bufnr)
      vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        require('conform').format { async = true }
      end, { desc = 'Format current buffer using conform' })
    end,
  }

  for server_name, cfg in pairs(servers) do
    vim.lsp.config(
      server_name,
      vim.tbl_deep_extend('force', default_config, cfg or {})
    )
  end

  configured = true
end

function M.is_enabled()
  for _, name in ipairs(server_names) do
    if vim.lsp.is_enabled(name) then
      return true
    end
  end

  return copilot_enabled()
end

function M.enable()
  M.configure()
  vim.lsp.enable(server_names)

  if package.loaded.copilot then
    require('copilot.command').enable()
  else
    require('lze').trigger_load 'copilot.lua'
  end

  vim.notify 'LSP and Copilot enabled for this rvim instance'
end

function M.disable()
  vim.lsp.enable(server_names, false)

  if package.loaded.copilot then
    require('copilot.command').disable()
  end

  stop_uninitialized_clients()
  vim.notify 'LSP and Copilot disabled for this rvim instance'
end

function M.toggle()
  if M.is_enabled() then
    M.disable()
  else
    M.enable()
  end
end

function M.status()
  local enabled_count = 0
  local clients = {}

  for _, name in ipairs(server_names) do
    if vim.lsp.is_enabled(name) then
      enabled_count = enabled_count + 1
    end
  end

  for _, client in ipairs(vim.lsp.get_clients { _uninitialized = true }) do
    if server_set[client.name] or client.name == 'copilot' then
      clients[#clients + 1] = client.name
    end
  end

  table.sort(clients)

  vim.notify(
    ('LSP configs: %d/%d enabled\nCopilot: %s\nClients: %s'):format(
      enabled_count,
      #server_names,
      copilot_enabled() and 'enabled' or 'disabled',
      #clients > 0 and table.concat(clients, ', ') or 'none'
    )
  )
end

vim.api.nvim_create_user_command('RvimLspEnable', M.enable, {
  desc = 'Enable LSP and Copilot in this rvim instance',
})

vim.api.nvim_create_user_command('RvimLspDisable', M.disable, {
  desc = 'Disable LSP and Copilot in this rvim instance',
})

vim.api.nvim_create_user_command('RvimLspToggle', M.toggle, {
  desc = 'Toggle LSP and Copilot in this rvim instance',
})

vim.api.nvim_create_user_command('RvimLspStatus', M.status, {
  desc = 'Show LSP and Copilot status for this rvim instance',
})

return M
