syntax enable                              "Allow syntax highlight
set mouse=a                                "Use mouse for scrolling
set backspace=indent,eol,start             "Make backspace behave like every other editor.
let mapleader = ' '                        "Default Leader is \, but a space is much better
set noswapfile
set ruler                                  "show cursor position all the time
set autoindent                             " Indent according to previous line.
set noerrorbells visualbell t_vb= 	       "No bells!
set tm=500
nnoremap <C-x> :q!<cr>
set complete-=i
set smarttab
set nrformats-=octal
set cc=120

if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif

" Enable true color
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Enable loading {ftdetect,ftplugin,indent}/*.vim files.
filetype plugin indent on

"----------Tab control------"
set tabstop=4
set expandtab
set softtabstop=2
set shiftwidth=2

"----------Visuals------"
set t_Co=256
set foldmethod=syntax  " Foldmethod 
set nofoldenable
set number                                 "Let's activate line number
set wrap " turn on line wrapping
colorscheme iceberg
set laststatus=2 " show the status line all the time
set hidden " Switch between buffers without having to save first.
set nobackup
set nowritebackup
set cmdheight=2
set updatetime=300
set shortmess+=c
set wildmenu
set signcolumn=yes
nmap <leader>z <Plug>Zoom
" switch cursor to line when in insert mode, and block when not
let &t_SI = "\e[5 q" " insert mode vertical line
let &t_EI = "\e[1 q" " command mode block

"Toggle relative numbering, and set to absolute on loss of focus or insert
"mode
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set number relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set number norelativenumber
augroup END

" Highlight yank area
if exists('##TextYankPost')
  autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank('Substitute',300)
endif

"----------Behaviour------"
set clipboard+=unnamedplus
" jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"Reload files changed outside vim
set autoread                               
augroup autoRead
    autocmd!
    autocmd CursorHold * silent! checktime
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
" Switch between buffer
nnoremap [b :bprev<CR>
nnoremap ]b :bnext<CR>

"----------Searching------"
set ignorecase                            " If search string contains only lowercase letters search is case insensitive.
set smartcase                             " If search string contains capital letters search is case sensative
set hlsearch
set incsearch
" Live preview substitute command
if has("nvim")
    set inccommand=nosplit
endif
" clear highlighted search
noremap <leader>c :set hlsearch! hlsearch?<cr>
" Find and replace in current file
nnoremap <leader>h :let @s=expand('<cword>')<CR>:%s/\<<C-r>s\>/<C-r>s/<Left>
xnoremap <leader>h "sy:%s/<C-r>s//<Left>

"----------Split Mapping------"
set splitbelow
set splitright

nmap <C-j> <C-W><C-J> " Move to bottom window
nmap <C-k> <C-W><C-K> " Move to top window
nmap <C-h> <C-W><C-H> " Move to left window
nmap <C-l> <C-W><C-L> " Move to right window

nnoremap <silent> + :exe "vertical resize +5"<CR>
nnoremap <silent> - :exe "vertical resize -5"<CR>

"Make ctrl+s work
nmap <c-s> :w<cr>
imap <c-s> <esc>:w<cr>a


"----------Mapping------"
" keep visual selection when indenting/outdenting
vmap < <gv
vmap > >gv

" Movement in insert mode
inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>a
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k

" Moving lines
xnoremap <silent> <C-j> :move'>+<cr>gv
xnoremap <silent> <C-k> :move-2<cr>gv

" Open file in sublime
command! Subl :call system('nohup "subl" '.expand('%:p').'> /dev/null 2>&1 < /dev/null &')<cr>
