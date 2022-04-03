local M = {}
local Log = require "core.log"

function M.config()
  rvim.builtin.nvimtree = {
    active = true,
    on_config_done = nil,
    setup = {
      disable_netrw = true,
      hijack_netrw = true,
      open_on_setup = false,
      ignore_ft_on_setup = {
        "startify",
        "dashboard",
        "alpha",
      },
      update_to_buf_dir = {
        enable = false,
        auto_open = true,
      },
      auto_close = true,
      open_on_tab = false,
      hijack_cursor = false,
      update_cwd = false,
      diagnostics = {
        enable = true,
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
        auto_resize = false,
        mappings = {
          custom_only = false,
          list = {},
        },
      },
      filters = {
        dotfiles = false,
        custom = { "node_modules", ".cache" },
      },
    },
    show_icons = {
      git = 1,
      folders = 1,
      files = 1,
      folder_arrows = 1,
      tree_width = 30,
    },
    quit_on_open = 0,
    git_hl = 1,
    disable_window_picker = 0,
    root_folder_modifier = ":t",
    icons = {
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
  }
end

function M.setup()
  local status_ok, nvim_tree_config = pcall(require, "nvim-tree.config")
  if not status_ok then
    Log:error "Failed to load nvim-tree.config"
    return
  end

  for opt, val in pairs(rvim.builtin.nvimtree) do
    vim.g["nvim_tree_" .. opt] = val
  end

  -- Add useful keymaps
  local tree_cb = nvim_tree_config.nvim_tree_callback
  if #rvim.builtin.nvimtree.setup.view.mappings.list == 0 then
    rvim.builtin.nvimtree.setup.view.mappings.list = {
      { key = { "l", "<CR>", "o" }, cb = tree_cb "edit" },
      { key = "h", cb = tree_cb "close_node" },
      { key = "s", cb = tree_cb "vsplit" },
    { key = "t", cb = tree_cb("tabnew")},
      { key = "C", cb = tree_cb "cd" },
      { key = "gtf", cb = "<cmd>lua require'core.nvimtree'.start_telescope('find_files')<cr>" },
      { key = "gtg", cb = "<cmd>lua require'core.nvimtree'.start_telescope('live_grep')<cr>" },
    }
  end

  local function on_open()
    if package.loaded["bufferline.state"] and rvim.builtin.nvimtree.setup.view.side == "left" then
      require("bufferline.state").set_offset(rvim.builtin.nvimtree.setup.view.width + 1, "")
    end
  end

  local function on_close()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
    if ft == "NvimTree" and package.loaded["bufferline.state"] then
      require("bufferline.state").set_offset(0)
    end
  end

  local tree_view = require "nvim-tree.view"
  local default_open = tree_view.open
  local default_close = tree_view.close

  tree_view.open = function()
    on_open()
    default_open()
  end

  tree_view.close = function()
    on_close()
    default_close()
  end

  if rvim.builtin.nvimtree.on_config_done then
    rvim.builtin.nvimtree.on_config_done(nvim_tree_config)
  end

  require("nvim-tree").setup(rvim.builtin.nvimtree.setup)
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
