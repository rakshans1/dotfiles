local M = {}
local utils = require "utils"

M.config = function(config)
  rvim.builtin.dashboard = {
    active = true,
    on_config_done = nil,
    search_handler = "telescope",
    disable_at_vim_enter = 0,
    session_directory = utils.join_paths(get_cache_dir(), "sessions"),
    custom_header = {
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    },

    custom_section = {
      a = {
        description = { "  Find File          " },
        command = "Telescope find_files",
      },
      b = {
        description = { "  Recent Projects    " },
        command = "Telescope projects",
      },
      c = {
        description = { "  Recently Used Files" },
        command = "Telescope oldfiles",
      },
      d = {
        description = { "  Find Word          " },
        command = "Telescope live_grep",
      },
    },

  }
end

M.setup = function()
  vim.g.dashboard_disable_at_vimenter = rvim.builtin.dashboard.disable_at_vim_enter

  vim.g.dashboard_custom_header = rvim.builtin.dashboard.custom_header

  vim.g.dashboard_default_executive = rvim.builtin.dashboard.search_handler

  vim.g.dashboard_custom_section = rvim.builtin.dashboard.custom_section

  rvim.builtin.which_key.mappings[";"] = { "<cmd>Dashboard<CR>", "Dashboard" }

  vim.g.dashboard_session_directory = rvim.builtin.dashboard.session_directory

  local num_plugins_loaded = #vim.fn.globpath(get_runtime_dir() .. "/site/pack/packer/start", "*", 0, 1)

  local footer = {
    "Loaded " .. num_plugins_loaded .. " plugins ",
  }

  local text = require "interface.text"
  vim.g.dashboard_custom_footer = text.align_center({ width = 0 }, footer, 0.49)

  require("core.autocmds").define_autocmds {
    {
      "FileType",
      {
        group = "_dashboard",
        pattern = "dashboard",
        command = "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell  nolist  nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs= "
      }
    },

    {
      "FileType",
      {
        group = "_dashboard",
        pattern = "dashboard",
        command = "set showtabline=0 | autocmd BufLeave <buffer> set showtabline="  .. vim.opt.showtabline._value,
      }
    }
  }
end

return M
