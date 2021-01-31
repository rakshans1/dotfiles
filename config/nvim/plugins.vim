call functions#PlugLoad()
call plug#begin('~/.config/nvim/plugged')

" colorscheme
Plug 'cocopon/iceberg.vim'
Plug 'logico/typewriter-vim'

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/vim-peekaboo'
Plug 'junegunn/vim-easy-align'

" File search
Plug '~/.fzf/'
Plug 'junegunn/fzf.vim'

" Edit
Plug 'tpope/vim-repeat'
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
Plug 'AndrewRadev/splitjoin.vim'
Plug 'metakirby5/codi.vim'
" Plug 'wellle/targets.vim'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'neovim/nvim-lspconfig'
Plug 'mattn/emmet-vim'
Plug 'liuchengxu/vista.vim'

" telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/telescope.nvim'

" debugger
" Plug 'puremourning/vimspector'

" Plug 'tpope/vim-vinegar'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'scrooloose/nerdcommenter'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb' " :Gbrowse for gihub
Plug 'shumphrey/fugitive-gitlab.vim' " :Gbrowse for gitlab
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
Plug 'easymotion/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
" Plug 'dense-analysis/ale'  Replaced with coc-eslint
" Plug 'raimondi/delimitmate'

" syntax
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'maxmellon/vim-jsx-pretty', { 'for': 'javascript' }
Plug 'moll/vim-node', { 'for': 'javascript' }
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }
Plug 'norcalli/nvim-colorizer.lua' " show hex/rgb colors in bg
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'ianks/vim-tsx', { 'for': 'typescript' }
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go' }
Plug 'rescript-lang/vim-rescript'
Plug 'reasonml-editor/vim-reason-plus'
Plug 'editorconfig/editorconfig-vim'
" Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} 

Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }

Plug 'ekalinin/Dockerfile.vim', { 'for': 'Dockerfile' }


Plug 'tpope/vim-dadbod'

Plug 'janko/vim-test'

Plug 'wakatime/vim-wakatime'
call plug#end()
