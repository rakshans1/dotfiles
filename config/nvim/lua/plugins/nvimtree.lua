local utils = require 'utils'
local nnoremap = utils.nnoremap

vim.g.nvim_tree_ignore = { '.git', 'node_modules', '.cache' }
vim.g.nvim_tree_auto_ignore_ft = {'startify'}
vim.g.nvim_tree_quit_on_open = 1
vim.g.nvim_tree_indent_markers = 0
vim.g.nvim_tree_hide_dotfiles = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_root_folder_modifier = ':~'
vim.g.nvim_tree_width_allow_resize  = 1
vim.g.nvim_tree_add_trailing = 1
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1
  }

vim.g.nvim_tree_icons = {
   default= '',
   symlink= '',
   git= {
     unstaged= "✗",
     staged= "✓",
     unmerged= "",
     renamed= "➜",
     untracked= "★"
   },
   folder= {
     default= "",
     open= "",
     empty= "",
     empty_open= "",
     symlink= "",
     symlink_open= "",
   }
}

local tree_cb = require'nvim-tree.config'.nvim_tree_callback

require'nvim-tree'.setup {
  disable_netrw = false,
  auto_close = true,
  tab_open = false,
  update_focused_file = {
    enable = true,
  },
  view = {
    auto_resize = true,
    mappings = {
      list = {
        {key = "s", cb = tree_cb("vsplit")},
        {key = "t", cb = tree_cb("tabnew")},
      }
    }
  }
}


nnoremap('<C-n>',':NvimTreeToggle<CR>')
