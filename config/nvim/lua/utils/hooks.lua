local M = {}

local Log = require "core.log"
local in_headless = #vim.api.nvim_list_uis() == 0
local plugin_loader = require "plugin-loader"

function M.run_pre_update()
  Log:debug "Starting pre-update hook"
end

function M.run_pre_reload()
  Log:debug "Starting pre-reload hook"
end

function M.run_on_packer_complete()
  Log:debug "Packer operation complete"
  vim.api.nvim_exec_autocmds("User", { pattern = "PackerComplete" })

  if M._reload_triggered then
    if not in_headless then
      vim.schedule(function()
        pcall(vim.cmd.colorscheme, rvim.colorscheme)
      end)
    end
    Log:info "Reloaded configuration"
    M._reload_triggered = nil
  end
end

function M.run_post_reload()
  Log:debug "Starting post-reload hook"

  M.reset_cache()
  M._reload_triggered = true
end

---Reset any startup cache files used by Packer and Impatient
---It also forces regenerating any template ftplugin files
---Tip: Useful for clearing any outdated settings
function M.reset_cache()
  vim.cmd [[LuaCacheClear]]
  plugin_loader.recompile()
  local rvim_modules = {}
  for module, _ in pairs(package.loaded) do
    if module:match "core" or module:match "lsp" then
      package.loaded[module] = nil
      table.insert(rvim_modules, module)
    end
  end
  Log:trace(string.format("Cache invalidated for core modules: { %s }", table.concat(rvim_modules, ", ")))
  require("lsp.templates").generate_templates()
end

function M.run_post_update()
  Log:debug "Starting post-update hook"
  M.reset_cache()

  Log:debug "Syncing core plugins"
  plugin_loader.sync_core_plugins()

  if not in_headless then
    vim.schedule(function()
      if package.loaded["nvim-treesitter"] then
        vim.cmd [[ TSUpdateSync ]]
      end
      -- TODO: add a changelog
      vim.notify("Update complete", vim.log.levels.INFO)
    end)
  end
end

return M
