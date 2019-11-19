call functions#PlugLoad()
call plug#begin('~/.config/nvim/plugged')

" colorscheme
Plug 'cocopon/iceberg.vim'
Plug 'arcticicestudio/nord-vim'

" autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Plug 'tpope/vim-vinegar'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
Plug 'easymotion/vim-easymotion'
" Plug 'vim-syntastic/syntastic'
" Plug 'w0rp/ale'
" Plug 'raimondi/delimitmate'

" syntax
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'mxw/vim-jsx', { 'for': 'javascript' }
Plug 'moll/vim-node', { 'for': 'javascript' }
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }
" show hex/rgb colors in bg
Plug 'norcalli/nvim-colorizer.lua'
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'ianks/vim-tsx', { 'for': 'typescript' }

Plug 'editorconfig/editorconfig-vim'

Plug 'ekalinin/Dockerfile.vim', { 'for': 'Dockerfile' }

Plug 'Quramy/tsuquyomi'

call plug#end()
