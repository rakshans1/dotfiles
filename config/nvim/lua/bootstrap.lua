local M = {}

package.loaded["utils.hooks"] = nil

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
  local uv = vim.loop
  local path_sep = "/"
  local result = table.concat({ ... }, path_sep)
  return result
end

---Get the full path to runtime dir
---@return string
function _G.get_runtime_dir()
    -- when nvim is used directly
    return vim.fn.stdpath "data"
end

---Get the full path to config dir
---@return string
function _G.get_config_dir()
  return vim.fn.stdpath "config"
end

---Get the full path to cache dir
---@return string
function _G.get_cache_dir()
  return vim.fn.stdpath "cache"
end

---Get the full path to the currently installed repo
---@return string
local function get_install_path()
  return vim.fn.stdpath "config"
end

---Initialize the `&runtimepath` variables and prepare for startup
---@return table
function M:init()
  self.runtime_dir = get_runtime_dir()
  self.config_dir = get_config_dir()
  self.cache_path = get_cache_dir()
  self.install_path = get_install_path()

  self.pack_dir = join_paths(self.runtime_dir, "site", "pack")
  self.packer_install_dir = join_paths(self.runtime_dir, "site", "pack", "packer", "start", "packer.nvim")
  self.packer_cache_path = join_paths(self.config_dir, "plugin", "packer_compiled.lua")

  vim.fn.mkdir(vim.fn.stdpath "cache", "p")

  local config = require "config"
  config:init {
    path = join_paths(self.config_dir, "config.lua"),
  }

  require("plugin-loader"):init {
    package_root = self.pack_dir,
    install_path = self.packer_install_dir,
  }

  return self
end

return M