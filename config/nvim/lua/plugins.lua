return {
  { "wbthomason/packer.nvim" },
  -- Theme
  {"cocopon/iceberg.vim"},
  {
    "folke/lsp-colors.nvim",
    event = "BufRead",
  },

	-- Registers
	{ "junegunn/vim-peekaboo"},

	-- Edit
	{ "tpope/vim-repeat"},
	{ "mbbill/undotree", cmd = "UndotreeToggle"},
	{ "plasticboy/vim-markdown"},


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
        ft = {"fugitive"}
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
  { "sindrets/diffview.nvim"},
  { "tpope/vim-surround",
    keys = {"c", "d", "y"}
  },

  { "norcalli/nvim-colorizer.lua"},
  { "editorconfig/editorconfig-vim"},
  { "iamcco/markdown-preview.nvim", run = "cd app && yarn install", cmd = "MarkdownPreview"},
  { "wakatime/vim-wakatime"},
  { "softoika/ngswitcher.vim"},
  -- Packer can manage itself as an optional plugin
  { "neovim/nvim-lspconfig" },
  { "tamago324/nlsp-settings.nvim" },
  { "jose-elias-alvarez/null-ls.nvim" },
  { "antoinemadec/FixCursorHold.nvim" }, -- Needed while issue https://github.com/neovim/neovim/issues/12587 is still open
  {
    "williamboman/nvim-lsp-installer",
  },
  {
    "folke/trouble.nvim",
      cmd = "TroubleToggle",
  },

  { "nvim-lua/popup.nvim" },
  { "nvim-lua/plenary.nvim" },
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
    run = 'make',
    disable = not rvim.builtin.telescope.active,
  },
  { "nvim-telescope/telescope-github.nvim" },
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

  -- Install nvim-cmp, and buffer source as a dependency
  {
    "hrsh7th/nvim-cmp",
    config = function()
      require("core.cmp").setup()
    end,
    requires = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
    },
    run = function()
      -- cmp's config requires cmp to be installed to run the first time
      if not rvim.builtin.cmp then
        require("core.cmp").config()
      end
    end,
  },
  {
    "rafamadriz/friendly-snippets",
    -- event = "InsertCharPre",
    -- disable = not rvim.builtin.compe.active,
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
    branch = "0.5-compat",
    -- run = ":TSUpdate",
    config = function()
      require("core.treesitter").setup()
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "BufRead",
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
    disable = not rvim.builtin.which_key.active,
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
  { "kyazdani42/nvim-web-devicons" },

  -- Status Line and Bufferline
  {
    "shadmansaleh/lualine.nvim",
    config = function()
      require("core.lualine").setup()
    end,
    disable = not rvim.builtin.lualine.active,
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
    "Pocco81/DAPInstall.nvim",
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
    config = function()
      require("core.terminal").setup()
    end,
    disable = not rvim.builtin.terminal.active,
  },

  {
    "vuki656/package-info.nvim",
    requires = "MunifTanjim/nui.nvim",
  },
}
