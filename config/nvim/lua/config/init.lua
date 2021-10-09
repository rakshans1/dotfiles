local M = {}

function M:init(opts)
  opts = opts or {}
  local utils = require "utils"

  require "config.defaults"


  local builtins = require "core.builtins"
  builtins.config(self)

  local settings = require "config.settings"
  settings.load_options()

  local rvim_lsp_config = require "lsp.config"
  rvim.lsp = vim.deepcopy(rvim_lsp_config)

  local supported_languages = {
    "bash",
    "c",
    "c_sharp",
    "cmake",
    "comment",
    "cpp",
    "cs",
    "css",
    "dart",
    "dockerfile",
    "emmet",
    "go",
    "graphql",
    "haskell",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "lua",
    "markdown",
    "nginx",
    "python",
    "regex",
    "rust",
    "scss",
    "sh",
    "tailwindcss",
    "tsx",
    "typescript",
    "typescriptreact",
    "vim",
    "yaml",
  }

  -- require("lsp.manager").init_defaults(supported_languages)
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load(config_path)
  local autocmds = require "core.autocmds"

  autocmds.define_augroups(rvim.autocommands)

  local settings = require "config.settings"
  settings.load_commands()
end

return M
