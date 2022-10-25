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
      diagnostics = {
        enable = true,
        show_on_dirs = false,
        icons = {
          hint = rvim.icons.diagnostics.BoldHint,
          info = rvim.icons.diagnostics.BoldInformation,
          warning = rvim.icons.diagnostics.BoldWarning,
          error = rvim.icons.diagnostics.BoldError,
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
            default = rvim.icons.ui.Text,
            symlink = rvim.icons.ui.FileSymlink,
            git = {
              deleted = rvim.icons.git.FileDeleted,
              ignored = rvim.icons.git.FileIgnored,
              renamed = rvim.icons.git.FileRenamed,
              staged = rvim.icons.git.FileStaged,
              unmerged = rvim.icons.git.FileUnmerged,
              unstaged = rvim.icons.git.FileUnstaged,
              untracked = rvim.icons.git.FileUntracked,
            },
            folder = {
              default = rvim.icons.ui.Folder,
              empty = rvim.icons.ui.EmptyFolder,
              empty_open = rvim.icons.ui.EmptyFolderOpen,
              open = rvim.icons.ui.FolderOpen,
              symlink = rvim.icons.ui.FolderSymlink,
            },
          },
        },
        highlight_git = true,
        group_empty = false,
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
