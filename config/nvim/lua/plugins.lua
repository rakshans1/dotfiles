local Log = require "core.log"

local core_plugins = {
  { "wbthomason/packer.nvim" },
  { "neovim/nvim-lspconfig" },
  { "tamago324/nlsp-settings.nvim" },
  {
    "jose-elias-alvarez/null-ls.nvim",
  },
  { "williamboman/mason-lspconfig.nvim" },
  {
    "williamboman/mason.nvim",
    config = function()
      require("core.mason").setup()
    end,
  },
  { "Tastyep/structlog.nvim", },
  { "nvim-lua/popup.nvim", },
  { "nvim-lua/plenary.nvim", },
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("core.telescope").setup()
    end,
    disable = not rvim.builtin.telescope.active,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make",
    disable = not rvim.builtin.telescope.active,
  },

  -- Install nvim-cmp, and buffer source as a dependency
  {
    "hrsh7th/nvim-cmp",
    config = function()
      if rvim.builtin.cmp then
        require("core.cmp").setup()
      end
    end,
    requires = {
      "L3MON4D3/LuaSnip",
    },
  },
  {
    "rafamadriz/friendly-snippets",
    disable = not rvim.builtin.luasnip.sources.friendly_snippets,
  },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local utils = require "utils"
      local paths = {}
      if rvim.builtin.luasnip.sources.friendly_snippets then
        paths[#paths + 1] = utils.join_paths(get_runtime_dir(), "site", "pack", "packer", "start", "friendly-snippets")
      end
      local user_snippets = utils.join_paths(get_config_dir(), "snippets")
      if utils.is_directory(user_snippets) then
        paths[#paths + 1] = user_snippets
      end
      require("luasnip.loaders.from_lua").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load {
        paths = paths,
      }
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "saadparwaiz1/cmp_luasnip",
  },
  {
    "hrsh7th/cmp-buffer",
  },
  {
    "hrsh7th/cmp-path",
  },
  {
    "folke/neodev.nvim",
    module = "neodev",
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    -- event = "InsertEnter",
    config = function()
      require("core.autopairs").setup()
    end,
    disable = not rvim.builtin.autopairs.active,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    -- run = ":TSUpdate",
    config = function()
      require("core.treesitter").setup()
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "BufReadPost",
  },

  {
    "ruifm/gitlinker.nvim",
    event = "BufRead",
    config = function()
      require("gitlinker").setup {
        opts = {
          add_current_line_on_normal_mode = true,
          action_callback = require("gitlinker.actions").copy_to_clipboard,
          print_url = false,
          mappings = "<leader>gy",
        },
      }
    end,
    requires = "nvim-lua/plenary.nvim",
  },
  {
    "pwntester/octo.nvim",
    config = function()
      require('octo').setup()
    end
  },


  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  { "nvim-treesitter/nvim-treesitter-textobjects" },

  -- NvimTree
  {
    "kyazdani42/nvim-tree.lua",
    config = function()
      require("core.nvimtree").setup()
    end,
    disable = not rvim.builtin.nvimtree.active,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("core.gitsigns").setup()
    end,
    event = "BufRead",
    disable = not rvim.builtin.gitsigns.active,
  },

  -- Whichkey
  {
    "folke/which-key.nvim",
    config = function()
      require("core.which-key").setup()
    end,
    event = "BufWinEnter",
    disable = false,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    event = "BufRead",
    config = function()
      require("core.comment").setup()
    end,
    disable = not rvim.builtin.comment.active,
  },

  -- Icons
  { "kyazdani42/nvim-web-devicons", },

  -- Status Line and Bufferline
  {
    -- "hoob3rt/lualine.nvim",
    "nvim-lualine/lualine.nvim",
    -- "Lunarvim/lualine.nvim",
    config = function()
      require("core.lualine").setup()
    end,
    disable = not rvim.builtin.lualine.active,
  },

  -- Theme
  { "cocopon/iceberg.vim" },
  {
    "folke/lsp-colors.nvim",
    event = "BufRead",
  },

  -- Registers
  { "junegunn/vim-peekaboo" },

  -- Edit
  { "tpope/vim-repeat" },
  { "mbbill/undotree", cmd = "UndotreeToggle" },
  { "plasticboy/vim-markdown" },


  { "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit"
    },
    ft = { "fugitive" }
  },
  {
    "ethanholz/nvim-lastplace",
    event = "BufRead",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = {
          "gitcommit", "gitrebase", "svn", "hgcommit",
        },
        lastplace_open_folds = true,
      })
    end,
  },
  { "sindrets/diffview.nvim" },
  { "tpope/vim-surround",
    keys = { "c", "d", "y" }
  },

  { "norcalli/nvim-colorizer.lua" },
  { "editorconfig/editorconfig-vim" },
  { "iamcco/markdown-preview.nvim", run = "cd app && yarn install", cmd = "MarkdownPreview" },
  { "wakatime/vim-wakatime" },
  { "softoika/ngswitcher.vim" },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },

  -- breadcrumbs
  {
    "SmiteshP/nvim-navic",
    config = function()
      require("core.breadcrumbs").setup()
    end,
  },

  {
    "akinsho/bufferline.nvim",
    config = function()
      require("core.bufferline").setup()
    end,
    branch = "main",
    event = "BufWinEnter",
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    -- event = "BufWinEnter",
    config = function()
      require("core.dap").setup()
    end,
    disable = not rvim.builtin.dap.active,
  },

  -- Debugger management
  {
    "Pocco81/dap-buddy.nvim",
    branch = "dev",
    -- event = "BufWinEnter",
    -- event = "BufRead",
    disable = not rvim.builtin.dap.active,
  },

  -- Dashboard
  {
    "ChristianChiarulli/dashboard-nvim",
    event = "BufWinEnter",
    config = function()
      require("core.dashboard").setup()
    end,
    disable = not rvim.builtin.dashboard.active,
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    event = "BufWinEnter",
    branch = "main",
    config = function()
      require("core.terminal").setup()
    end,
    disable = not rvim.builtin.terminal.active,
  },

  {
    "vuki656/package-info.nvim",
    requires = "MunifTanjim/nui.nvim",
  },

  -- SchemaStore
  {
    "b0o/schemastore.nvim",
  },
  {
    "RRethy/vim-illuminate",
    setup = function()
      require("core.illuminate").setup()
    end,
    disable = not rvim.builtin.illuminate.active,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("core.indentlines").setup()
    end,
    disable = not rvim.builtin.indentlines.active,
  },
}

local default_snapshot_path = join_paths(get_config_dir(), "snapshots", "default.json")
local content = vim.fn.readfile(default_snapshot_path)
local default_sha1 = vim.fn.json_decode(content)

local get_default_sha1 = function(spec)
  util = require("packer.util")
  local short_name, _ = util.get_plugin_short_name(spec)
  return default_sha1[short_name] and default_sha1[short_name].commit
end

for _, spec in ipairs(core_plugins) do
  if not vim.env.RVIM_DEV_MODE then
    -- Manually lock the commit hash since Packer's snapshots are unreliable in headless mode
    spec["commit"] = get_default_sha1(spec)
  end
end


return core_plugins;
