local Log = require "core.log"

local core_plugins = {
  { "folke/lazy.nvim", tag = "stable" },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    dependencies = { "mason-lspconfig.nvim", "nlsp-settings.nvim" },
  },
  { "williamboman/mason-lspconfig.nvim", lazy = true },
  { "tamago324/nlsp-settings.nvim", lazy = true },
  { "jose-elias-alvarez/null-ls.nvim", lazy = true },
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
    dependencies = { "telescope-fzf-native.nvim" },
    lazy = true,
    cmd = "Telescope",
    enabled = rvim.builtin.telescope.active,
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true, enabled = rvim.builtin.telescope.active },

  { "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      vim.defer_fn(function()
        require("copilot").setup {
          plugin_manager_path = get_runtime_dir() .. "/site/pack/packer",
          suggestion = { enabled = false },
          panel = { enabled = false },
        }
      end, 100)
    end,
  },

  { "zbirenbaum/copilot-cmp",
    after = { "copilot.lua", "nvim-cmp" },
    config = function()
      require("copilot_cmp").setup()
    end
  },

  -- Install nvim-cmp, and buffer source as a dependency
  {
    "hrsh7th/nvim-cmp",
    config = function()
      if rvim.builtin.cmp then
        require("core.cmp").setup()
      end
    end,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "cmp-nvim-lsp",
      "cmp_luasnip",
      "cmp-buffer",
      "cmp-path",
    },
  },
  { "hrsh7th/cmp-nvim-lsp", lazy = true },
  { "saadparwaiz1/cmp_luasnip", lazy = true },
  { "hrsh7th/cmp-buffer", lazy = true },
  { "hrsh7th/cmp-path", lazy = true },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local utils = require "utils"
      local paths = {}
      if rvim.builtin.luasnip.sources.friendly_snippets then
        paths[#paths + 1] = utils.join_paths(get_runtime_dir(), "site", "pack", "lazy", "opt", "friendly-snippets")
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
    event = "InsertEnter",
    dependencies = {
      "friendly-snippets",
    },
  },
  { "rafamadriz/friendly-snippets", lazy = true, cond = rvim.builtin.luasnip.sources.friendly_snippets },
  {
    "folke/neodev.nvim",
    lazy = true
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("core.autopairs").setup()
    end,
    enabled = rvim.builtin.autopairs.active,
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
    event = "VeryLazy",
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
    enabled = rvim.builtin.nvimtree.active,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("core.gitsigns").setup()
    end,
    event = "BufRead",
    enable = rvim.builtin.gitsigns.active,
  },

  -- Whichkey
  {
    "folke/which-key.nvim",
    config = function()
      require("core.which-key").setup()
    end,
    event = "VeryLazy",
    enabled = rvim.builtin.which_key.active,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    event = "BufRead",
    config = function()
      require("core.comment").setup()
    end,
    enable = rvim.builtin.comment.active,
  },

  -- Icons
  { "kyazdani42/nvim-web-devicons", },

  -- Status Line and Bufferline
  {
    -- "hoob3rt/lualine.nvim",
    "nvim-lualine/lualine.nvim",
    config = function()
      require("core.lualine").setup()
    end,
    enable = rvim.builtin.lualine.active,
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
    enabled = rvim.builtin.bufferline.active,
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    -- event = "BufWinEnter",
    config = function()
      require("core.dap").setup()
    end,
    enable = rvim.builtin.dap.active,
  },

  -- Debugger management
  {
    "Pocco81/dap-buddy.nvim",
    branch = "dev",
    -- event = "BufWinEnter",
    -- event = "BufRead",
    enable = rvim.builtin.dap.active,
  },

  -- Dashboard
  {
    "ChristianChiarulli/dashboard-nvim",
    event = "BufWinEnter",
    config = function()
      require("core.dashboard").setup()
    end,
    enable = rvim.builtin.dashboard.active,
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    branch = "main",
    config = function()
      require("core.terminal").setup()
    end,
    enable = rvim.builtin.terminal.active,
  },

  {
    "vuki656/package-info.nvim",
    requires = "MunifTanjim/nui.nvim",
  },

  -- SchemaStore
  {
    "b0o/schemastore.nvim",
    lazy = true
  },
  {
    "RRethy/vim-illuminate",
    setup = function()
      require("core.illuminate").setup()
    end,
    event = "VeryLazy",
    enabled = rvim.builtin.illuminate.active,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("core.indentlines").setup()
    end,
    enabled = rvim.builtin.indentlines.active,
  },
}

local default_snapshot_path = join_paths(get_config_dir(), "snapshots", "default.json")
local content = vim.fn.readfile(default_snapshot_path)
local default_sha1 = assert(vim.fn.json_decode(content))

-- taken form <https://github.com/folke/lazy.nvim/blob/c7122d64cdf16766433588486adcee67571de6d0/lua/lazy/core/plugin.lua#L27>
local get_short_name = function(long_name)
  local name = long_name:sub(-4) == ".git" and long_name:sub(1, -5) or long_name
  local slash = name:reverse():find("/", 1, true) --[[@as number?]]
  return slash and name:sub(#name - slash + 2) or long_name:gsub("%W+", "_")
end

local get_default_sha1 = function(spec)
  local short_name = get_short_name(spec[1])
  return default_sha1[short_name] and default_sha1[short_name].commit
end

for _, spec in ipairs(core_plugins) do
  if not vim.env.RVIM_DEV_MODE then
    -- Manually lock the commit hash since Packer's snapshots are unreliable in headless mode
    spec["commit"] = get_default_sha1(spec)
  end
end


return core_plugins;
