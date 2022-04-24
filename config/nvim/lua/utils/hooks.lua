local M = {}

local Log = require "core.log"
local in_headless = #vim.api.nvim_list_uis() == 0

function M.run_pre_update()
  Log:debug "Starting pre-update hook"
end

function M.run_pre_reload()
  Log:debug "Starting pre-reload hook"
end

function M.run_on_packer_complete()
   vim.schedule(function()
    if not in_headless then
      -- colorscheme must get called after plugins are loaded or it will break new installs.
      vim.g.colors_name = rvim.colorscheme
      vim.cmd("colorscheme " .. rvim.colorscheme)
    else
      Log:debug "Packer operation complete"
    end
  end)
end

function M.run_post_reload()
  Log:debug "Starting post-reload hook"

  M.reset_cache()
  vim.schedule(function()
    if not in_headless then
      Log:info "Reloaded configuration"
    end
  end)
end

---Reset any startup cache files used by Packer and Impatient
---It also forces regenerating any template ftplugin files
---Tip: Useful for clearing any outdated settings
function M.reset_cache()
  local impatient = _G.__luacache
  if impatient then
    impatient.clear_cache()
  end
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
  require("plugin-loader").sync_core_plugins()

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
