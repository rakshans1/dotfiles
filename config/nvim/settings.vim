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
set laststatus=2 " show the status line all the time
set hidden " current buffer can be put into background
set nobackup
set nowritebackup
set cmdheight=1
set updatetime=300
set shortmess+=c
set signcolumn=yes
"Toggle relative numbering, and set to absolute on loss of focus or insert
"mode
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

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

"----------Split Mapping------"
set splitbelow
set splitright

nmap <C-j> <C-W><C-J> " Move to bottom window
nmap <C-k> <C-W><C-K> " Move to top window
nmap <C-h> <C-W><C-H> " Move to left window
nmap <C-l> <C-W><C-L> " Move to right window

nnoremap <silent> + :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> - :exe "resize " . (winheight(0) * 2/3)<CR>

"Make ctrl+s work
nmap <c-s> :w<cr>
imap <c-s> <esc>:w<cr>a
