syntax enable                              "Allow syntax highlight
set mouse=a                                "Use mouse for scrolling
set backspace=indent,eol,start             "Make backspace behave like every other editor.
let mapleader = ' '                        "Default Leader is \, but a space is much better
set noswapfile
set ruler                                  "show cursor position all the time
set autoread                               "Reload files changed outside vim
set noerrorbells visualbell t_vb= 	       "No bells!
set tm=500
nnoremap <C-x> :q!<cr>

"----------Tab control------"
set tabstop=4
set expandtab
set softtabstop=2
set shiftwidth=2

"----------Visuals------"
set t_Co=256
set number                                 "Let's activate line number
set wrap " turn on line wrapping
colorscheme iceberg

"Toggle relative numbering, and set to absolute on loss of focus or insert
"mode
set rnu
function! ToggleNumberOn()
  set nu!
  set rnu
endfunction
function! ToggleRelativeOn()
  set rnu!
  set nu
endfunction
autocmd FocusLost * call ToggleRelativeOn()
autocmd FocusGained * call ToggleRelativeOn()
autocmd InsertEnter * call ToggleRelativeOn()
autocmd InsertLeave * call ToggleRelativeOn()

"----------Tabs------"
" CTRL-Tab is next tab
"nnoremap <C-S-tab> :tabprevious<CR>
"nnoremap <C-tab>   :tabnext<CR>
"nnoremap <C-t>     :tabnew<CR>
" CTRL-SHIFT-Tab is previous tab
"inoremap <C-S-tab> <Esc>:tabprevious<CR>i
"inoremap <C-tab>   <Esc>:tabnext<CR>i
"inoremap <C-t>     <Esc>:tabnew<CR>
"nmap <C-w> :tabclose<CR>

"----------Buffer------"
" Switch between opened files in buffer with ctrl-j and crtl-k
nnoremap <C-j> :bprev<CR>
nnoremap <C-k> :bnext<CR>

"----------Searching------"
set ignorecase                            " If search string contains only lowercase letters search is case insensitive.
set smartcase                             " If search string contains capital letters search is case sensative
set hlsearch
set incsearch
