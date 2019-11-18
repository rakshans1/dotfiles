syntax enable                              "Allow syntax highlight
set mouse=a                                "Use mouse for scrolling
set backspace=indent,eol,start             "Make backspace behave like every other editor.
let mapleader = ' '                        "Default Leader is \, but a space is much better
set noswapfile
set number                                 "Let's activate line number
set ruler                                  "show cursor position all the time
set autoread                               "Reload files changed outside vim
set noerrorbells visualbell t_vb= 	       "No bells!
set tm=500
set tabstop=4
set expandtab
set softtabstop=2
set shiftwidth=2
nnoremap <C-x> :q!<cr>

"----------Visuals------"
set t_Co=256

"----------Searching------"
set ignorecase                            " If search string contains only lowercase letters search is case insensitive.
set smartcase                             " If search string contains capital letters search is case sensative
set hlsearch
set incsearch
