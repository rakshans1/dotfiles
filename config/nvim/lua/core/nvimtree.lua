local M = {}

function M.config()
  rvim.builtin.nvimtree = {
    active = true,
    on_config_done = nil,
    setup = {
      disable_netrw = true,
      hijack_netrw = true,
      open_on_setup = false,
      auto_close = true,
      open_on_tab = false,
      update_focused_file = {
        enable = true,
      },
      diagnostics = {
        enable = true,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },
      view = {
        width = 30,
        side = "left",
        auto_resize = false,
        mappings = {
          custom_only = false,
        },
      },
    },
    show_icons = {
      git = true,
      folders = true,
      files = true,
      folder_arrows = true,
      tree_width = 30,
    },
    ignore = { ".git", "node_modules", ".cache" },
    quit_on_open = false,
    hide_dotfiles = true,
    git_hl = true,
    root_folder_modifier = ":~",
    allow_resize = true,
    ignore_ft_on_setup  = {"dashboard"},
    auto_ignore_ft = { "dashboard" },
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
  local tree_cb = require'nvim-tree.config'.nvim_tree_callback

  rvim.builtin.nvimtree.setup.view.mappings.list = {
    { key = { "l", "<CR>", "o" }, cb = tree_cb "edit" },
    { key = "h", cb = tree_cb "close_node" },
    { key = "s", cb = tree_cb "vsplit" },
    { key = "t", cb = tree_cb("tabnew")},
    }

  rvim.builtin.which_key.mappings["<C-n>"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" }

  require("nvim-tree").setup(rvim.builtin.nvimtree.setup)
end

function M.on_open()
  if package.loaded["bufferline.state"] and rvim.builtin.nvimtree.setup.view.side == "left" then
    require("bufferline.state").set_offset(rvim.builtin.nvimtree.setup.view.width + 1, "")
  end
end

function M.on_close()
  local buf = tonumber(vim.fn.expand "<abuf>")
  local ft = vim.api.nvim_buf_get_option(buf, "filetype")
  if ft == "NvimTree" and package.loaded["bufferline.state"] then
    require("bufferline.state").set_offset(0)
  end
end

function M.change_tree_dir(dir)
  local lib_status_ok, lib = pcall(require, "nvim-tree.lib")
  if lib_status_ok then
    lib.change_dir(dir)
  end
end

return M
