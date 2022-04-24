local utils = require "utils"
local Log = require "core.log"

local M = {}
local user_config_dir = get_config_dir()
local user_config_file = utils.join_paths(user_config_dir, "config.lua")

local function apply_defaults(configs, defaults)
  configs = configs or {}
  return vim.tbl_deep_extend("keep", configs, defaults)
end

---Get the full path to the user configuration file
---@return string
function M:get_user_config_path()
  return user_config_file
end

--- Initialize rvim default configuration
-- Define rvim global variable
function M:init()
  if vim.tbl_isempty(rvim or {}) then
    rvim = vim.deepcopy(require "config.defaults")
    local home_dir = vim.loop.os_homedir()
    rvim.vsnip_dir = utils.join_paths(home_dir, ".config", "snippets")
    rvim.database = { save_location = utils.join_paths(home_dir, ".config", "lunarvim_db"), auto_execute = 1 }
  end

  require("keymappings").load_defaults()

  local builtins = require "core.builtins"
  builtins.config { user_config_file = user_config_file }

  local settings = require "config.settings"
  settings.load_options()

  local autocmds = require "core.autocmds"
  rvim.autocommands = apply_defaults(rvim.autocommands, autocmds.load_augroups())

  local rvim_lsp_config = require "lsp.config"
  rvim.lsp = apply_defaults(rvim.lsp, vim.deepcopy(rvim_lsp_config))

  require("lsp.manager").init_defaults()
end


--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load(config_path)
  local autocmds = require "core.autocmds"

  autocmds.define_augroups(rvim.autocommands)

  vim.g.mapleader = (rvim.leader == "space" and " ") or rvim.leader

  require("keymappings").load(rvim.keys)

  if rvim.transparent_window then
    autocmds.enable_transparent_mode()
  end
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:reload()
  vim.schedule(function()
    require_clean("utils.hooks").run_pre_reload()

    M:init()
    M:load()

    require("core.autocmds").configure_format_on_save()

    local plugins = require "plugins"
    local plugin_loader = require "plugin-loader"

    plugin_loader.reload { plugins, rvim.plugins }
    require_clean("utils.hooks").run_post_reload()
  end)
end

return M
