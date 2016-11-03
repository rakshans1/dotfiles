set nocompatible              		  " be iMproved, required


so ~/.vim/plugins.vim


syntax enable


set backspace=indent,eol,start             "Make backspace behave like every other editor.
let mapleader = ','                        "Default Leader is \, but a comma is mush better
set number                                 "Let's activate line number
set linespace=15                           "Gui Specific Line Height
set noerrorbells visualbell t_vb= 	   "No bells!
set autowriteall                           "Automatically write files when switching buffer 
set complete=.,w,b,u                       " Set our desired autocomplete 

"----------Visuals------"

colorscheme atom-dark-256
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R

"Make linenumber side bar sam ecolor as background color
hi LineNr ctermbg=bg

"vertical split border color 
hi vertsplit ctermbg=bg ctermfg=bg 
"----------Searching------"
set hlsearch
set incsearch

"----------Split Mapping------"
set splitbelow
set splitright

nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>
nmap <C-H> <C-W><C-H>
nmap <C-L> <C-W><C-L>
"----------Mapping------"

"Make it easy to edit vimrc file.
nmap <Leader>ev :tabedit $MYVIMRC<cr>

"Make NERDTree easier to toggle
nmap <C-\> :NERDTreeToggle<cr> 

"Make ctrl+s work
nmap <c-s> :w<cr>
imap <c-s> <esc>:w<cr>a

"----------Plugins------"

"/
"/ CtrlP
"/
let g:ctrlp_custom_ignore = 'node_modules\|git'
let g:ctrlp_match_window = 'top,order:ttb,min:1,max30,results:30'

"search files in buffer
nmap <c-R> :CtrlPBufTag<cr>                
"search recent used files
nmap <c-E> :CtrlPMRUFiles<cr>             
"/
"/ NERDTree
"/
let NERDTreeHijackNetrw = 0
"/
"/ Airline
"/
let g:airline#extensions#tabline#enable = 1
let laststatus=2
let g:airline_powerline_fonts = 1
"-------Auto-Commands------"

"Automaticaly source the Vimrc file on save
augroup autosourcing
	autocmd!
	autocmd BufwritePost .vimrc source %
augroup END

"Add simple  highlight to removal
nmap <Leader><space> :nohlsearch<cr>
