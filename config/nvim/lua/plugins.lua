local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute 'packadd packer.nvim'
end

function _G.plugin_loaded(plugin_name)
  local p = _G.packer_plugins
  return p ~= nil and p[plugin_name] ~= nil and p[plugin_name].loaded
end

vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile' -- Auto compile when there are changes in plugins.lua
require('packer').init({display = {auto_clean = false}})

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

	use 'mhinz/vim-startify'

	-- colorscheme
	use 'cocopon/iceberg.vim'
	use 'logico/typewriter-vim'

	use 'junegunn/goyo.vim'
	use 'junegunn/limelight.vim'

	-- Registers
	use 'junegunn/vim-peekaboo'

	-- Prettification
	use 'junegunn/vim-easy-align'

	-- File search
use { 'junegunn/fzf', run = function() vim.fn['fzf#install']() end }
	use 'junegunn/fzf.vim'

	-- Edit
	use 'tpope/vim-repeat'
	use {'mbbill/undotree', cmd = 'UndotreeToggle'}
	use 'AndrewRadev/splitjoin.vim'
	use 'metakirby5/codi.vim'
	-- use 'wellle/targets.vim'
	use 'godlygeek/tabular'
	use 'plasticboy/vim-markdown'

	-- autocomplete
	use {'neoclide/coc.nvim', branch = 'release'}
	use 'neovim/nvim-lspconfig'
	use 'mattn/emmet-vim'
	use {'liuchengxu/vista.vim', cmd = 'Vista'}

	-- Search
	use {'nvim-lua/telescope.nvim', requires = {'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim'}}

	-- debugger
	-- use 'puremourning/vimspector'

	-- use 'tpope/vim-vinegar'
	use {'scrooloose/nerdtree', cmd =  {'NERDTreeToggle', 'NERDTreeFind'} }
	use 'scrooloose/nerdcommenter'
	use 'kyazdani42/nvim-tree.lua'
	use 'kyazdani42/nvim-web-devicons'
	use 'Xuyuanp/nerdtree-git-plugin'
	use 'ryanoasis/vim-devicons'
	use 'tiagofumo/vim-nerdtree-syntax-highlight'

	-- use 'vim-airline/vim-airline'
	use 'tpope/vim-fugitive'
	use 'tpope/vim-rhubarb' -- :Gbrowse for github
	use 'shumphrey/fugitive-gitlab.vim' -- :Gbrowse for gitlab
	use 'tpope/vim-surround'
	use 'airblade/vim-gitgutter'
	use 'easymotion/vim-easymotion'
	use 'jiangmiao/auto-pairs'

	-- syntax
	use {'pangloss/vim-javascript', ft = 'javascript' }
	use {'maxmellon/vim-jsx-pretty', ft = 'javascript' }
	use {'moll/vim-node', ft = 'javascript' }
	use {'hail2u/vim-css3-syntax', ft = 'css' }
	use 'norcalli/nvim-colorizer.lua' -- show hex/rgb colors in bg
	use {'leafgarland/typescript-vim', ft = 'typescript' }
	use {'ianks/vim-tsx', ft =  'typescript' }
	-- use 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go' }
	use 'rescript-lang/vim-rescript'
	use 'reasonml-editor/vim-reason-plus'
	use 'editorconfig/editorconfig-vim'
	use { 'nvim-treesitter/nvim-treesitter' }

	use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'}

	use {'ekalinin/Dockerfile.vim', ft = 'Dockerfile' }


	use 'tpope/vim-dadbod'

	use 'janko/vim-test'

	use 'wakatime/vim-wakatime'

	use 'softoika/ngswitcher.vim'
end)

