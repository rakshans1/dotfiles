lua << EOF
  require('settings')
  require('modules.appearance')
  require('modules.mappings')
EOF

" Enable loading {ftdetect,ftplugin,indent}/*.vim files.
filetype plugin indent on

"Toggle relative numbering, and set to absolute on loss of focus or insert
"mode
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set number relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set number norelativenumber
augroup END

"----------Behaviour------"
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

" Open file in sublime
command! Subl :call system('nohup "subl" '.expand('%:p').'> /dev/null 2>&1 < /dev/null &')<cr>

