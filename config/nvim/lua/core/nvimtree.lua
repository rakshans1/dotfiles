local M = {}
local Log = require "core.log"

function M.config()
  rvim.builtin.nvimtree = {
    active = true,
    on_config_done = nil,
    setup = {
      ignore_ft_on_setup = {
        "startify",
        "dashboard",
        "alpha",
      },
      auto_reload_on_write = true,
      hijack_directories = {
        enable = false,
        auto_open = true,
      },
      update_cwd = true,
      update_to_buf_dir = {
        enable = false,
        auto_open = true,
      },
      diagnostics = {
        enable = true,
        show_on_dirs = false,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },
      update_focused_file = {
        enable = true,
        update_cwd = true,
        ignore_list = {},
      },
      system_open = {
        cmd = nil,
        args = {},
      },
      git = {
        enable = true,
        ignore = false,
        timeout = 200,
      },
      view = {
        width = 30,
        height = 30,
        hide_root_folder = false,
        side = "left",
        mappings = {
          custom_only = false,
          list = {},
        },
        number = false,
        relativenumber = false,
      },
      renderer = {
        indent_markers = {
          enable = false,
          icons = {
            corner = "└",
            edge = "│",
            item = "│",
            none = " ",
          },
        },
        icons = {
          webdev_colors = true,
          show = {
            git = true,
            folder = true,
            file = true,
            folder_arrow = true
          },
          glyphs = {
            default = "",
            symlink = "",
            git = {
              unstaged = "",
              staged = "S",
              unmerged = "",
              renamed = "➜",
              deleted = "",
              untracked = "U",
              ignored = "◌",
            },
            folder = {
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
            },
          },
        },
        highlight_git = true,
        root_folder_modifier = ":t",
      },
      filters = {
        dotfiles = false,
        custom = { "node_modules", "\\.cache" },
        exclude = {},
      },
      log = {
        enable = false,
        truncate = false,
        types = {
          all = false,
          config = false,
          copy_paste = false,
          diagnostics = false,
          git = false,
          profile = false,
        },
      },
      actions = {
        use_system_clipboard = true,
        change_dir = {
          enable = true,
          global = false,
          restrict_above_cwd = false,
        },
        open_file = {
          quit_on_open = false,
          resize_window = false,
          window_picker = {
            enable = true,
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            exclude = {
              filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
              buftype = { "nofile", "terminal", "help" },
            },
          }
        },
      },
    },
    quit_on_open = 0,
    disable_window_picker = 0,
  }
end

function M.setup()
  local status_ok, nvim_tree = pcall(require, "nvim-tree")
  if not status_ok then
    Log:error "Failed to load nvim-tree"
    return
  end

  local status_ok_1, utils = pcall(require, "nvim-tree.utils")
  if not status_ok_1 then
    return
  end

  local function notify_level()
    return function(msg)
      vim.schedule(function()
        vim.api.nvim_echo({ { msg, "WarningMsg" } }, false, {})
      end)
    end
  end

  utils.notify.warn = notify_level(vim.log.levels.WARN)
  utils.notify.error = notify_level(vim.log.levels.ERROR)
  utils.notify.info = notify_level(vim.log.levels.INFO)
  utils.notify.debug = notify_level(vim.log.levels.DEBUG)

  if rvim.builtin.nvimtree._setup_called then
    Log:debug "ignoring repeated setup call for nvim-tree"
    return
  end

  rvim.builtin.nvimtree._setup_called = true

  local function telescope_find_files(_)
    require("core.nvimtree").start_telescope "find_files"
  end

  local function telescope_live_grep(_)
    require("core.nvimtree").start_telescope "live_grep"
  end

  -- Add useful keymaps
  if #rvim.builtin.nvimtree.setup.view.mappings.list == 0 then
    rvim.builtin.nvimtree.setup.view.mappings.list = {
      { key = { "l", "<CR>", "o" }, action = "edit" },
      { key = "h", action = "close_node" },
      { key = "s", action = "vsplit" },
      { key = "t", action = "tabnew" },
      { key = "C", action = "cd" },
      { key = "gtf", action = "telescope_find_files", action_cb = telescope_find_files },
      { key = "gtg", action = "telescope_live_grep", action_cb = telescope_live_grep },
    }
  end

  nvim_tree.setup(rvim.builtin.nvimtree.setup)

  if rvim.builtin.nvimtree.on_config_done then
    rvim.builtin.nvimtree.on_config_done(nvim_tree)
  end
end

function M.start_telescope(telescope_mode)
  local node = require("nvim-tree.lib").get_node_at_cursor()
  local abspath = node.link_to or node.absolute_path
  local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  require("telescope.builtin")[telescope_mode] {
    cwd = basedir,
  }
end

return M
