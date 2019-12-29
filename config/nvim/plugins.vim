call functions#PlugLoad()
call plug#begin('~/.config/nvim/plugged')

" colorscheme
Plug 'cocopon/iceberg.vim'
Plug 'arcticicestudio/nord-vim'

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/vim-peekaboo'

" File search
Plug '~/.fzf/'
Plug 'junegunn/fzf.vim'

" autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mattn/emmet-vim'

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
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go' }
Plug 'editorconfig/editorconfig-vim'

Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }

Plug 'ekalinin/Dockerfile.vim', { 'for': 'Dockerfile' }



Plug 'wakatime/vim-wakatime'
call plug#end()
