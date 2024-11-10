vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.relativenumber = true
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.base16colorspace = 256
vim.opt.backup = false
vim.opt.clipboard = "unnamedplus"
vim.opt.foldexpr = ""
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.mouse = "a"

lvim.log.level = "info"
lvim.format_on_save = {
  enabled = true,
  pattern = "*.lua",
  timeout = 1000,
}

lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

lvim.keys.normal_mode["<C-x>"] = ":q!<CR>"
lvim.keys.normal_mode["<C-n>"] = ":NvimTreeToggle<CR>"
lvim.keys.normal_mode["<C-_>"] = "<Plug>(comment_toggle_linewise_current)"
lvim.keys.normal_mode["<C-p>"] = "<cmd>Telescope find_files<CR>"
lvim.builtin.which_key.mappings["p"] = { "<cmd>Telescope live_grep<CR>", "Text" }

lvim.colorscheme = "iceberg"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.builtin.nvimtree.setup.tab.sync.close = true


lvim.builtin.telescope.defaults.layout_strategy = "horizontal"
lvim.builtin.telescope.defaults.layout_config.prompt_position = "bottom"
lvim.builtin.telescope.defaults.layout_config.width = 0.95
lvim.builtin.telescope.defaults.layout_config.preview_cutoff = 120
lvim.builtin.telescope.defaults.sorting_strategy = "descending"
lvim.builtin.telescope.defaults.layout_config.height = 0.75


lvim.builtin.bufferline.options.mode = "tabs"

local ok, actions = pcall(require, "telescope.actions")
if ok then
  lvim.builtin.telescope.defaults.mappings = {
    i = {
      ["<C-j>"] = actions.move_selection_next,
      ["<C-k>"] = actions.move_selection_previous,
      ["<C-c>"] = actions.close,
      ["<C-n>"] = actions.cycle_history_next,
      ["<C-p>"] = actions.cycle_history_prev,
      ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
      ["<CR>"] = actions.select_default,
      ["<C-d>"] = require("telescope.actions").delete_buffer,
    },
    n = {
      ["<C-n>"] = actions.move_selection_next,
      ["<C-p>"] = actions.move_selection_previous,
      ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
    },
  }
end

lvim.builtin.treesitter.auto_install = true

lvim.plugins = {
  { "cocopon/iceberg.vim" },
  { "zbirenbaum/copilot.lua",
    event = { "VimEnter" },
    config = function()
      vim.defer_fn(function()
        require("copilot").setup {}
      end, 100)
    end,
  },
  { "zbirenbaum/copilot-cmp",
    after = { "copilot.lua", "nvim-cmp" },
  },
  { "wakatime/vim-wakatime" }
}
lvim.builtin.cmp.formatting.source_names["copilot"] = "(Copilot)"
table.insert(lvim.builtin.cmp.sources, 1, { name = "copilot" })
