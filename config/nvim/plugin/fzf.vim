let g:fzf_layout = { 'up': '~40%' }
let g:fzf_history_dir = '~/.local/share/fzf-history'

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

function s:fzf_buf_in() abort
  echo
  set laststatus=0
  set noruler
  set nonumber
  set norelativenumber
  set signcolumn=no
endfunction

function s:fzf_buf_out() abort
  set laststatus=2
  set ruler
endfunction

augroup FzfStateLine
  autocmd!
  autocmd FileType fzf call s:fzf_buf_in()
  autocmd BufEnter \v[0-9]+;#FZF$ call s:fzf_buf_in()
  autocmd BufLeave \v[0-9]+;#FZF$ call s:fzf_buf_out()
  autocmd TermClose \v[0-9]+;#FZF$ call s:fzf_buf_out()
augroup END

function! s:fzf_statusline()
  highlight fzf1 ctermfg=255 ctermbg=255
  setlocal statusline=%#fzf1#\  
endfunction

autocmd! User FzfStatusLine call <SID>fzf_statusline()

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

" Recently edited files
command! FZFMru call fzf#run({
\ 'source':  reverse(s:all_files()),
\ 'sink':    'edit',
\ 'options': '-m -x +s',
\ 'up':    '40%' })

function! s:all_files()
  return extend(
  \ filter(copy(v:oldfiles),
  \        "v:val !~ 'fugitive:\\|NERD_tree\\|^/tmp/\\|.git/'"),
  \ map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'))
endfunction

" Search Tags accross files
function! s:tags_sink(line)
  let parts = split(a:line, '\t\zs')
  let excmd = matchstr(parts[2:], '^.*\ze;"\t')
  execute 'silent e' parts[1][:-2]
  let [magic, &magic] = [&magic, 0]
  execute excmd
  let &magic = magic
endfunction

function! s:tags()
  if empty(tagfiles())
    echohl WarningMsg
    echom 'Preparing tags'
    echohl None
    call system('ctags -R')
  endif

  call fzf#run({
  \ 'source':  'cat '.join(map(tagfiles(), 'fnamemodify(v:val, ":S")')).
  \            '| grep -v -a ^!',
  \ 'options': '+m -d "\t" --with-nth 1,4.. -n 1 --tiebreak=index',
  \ 'down':    '40%',
  \ 'sink':    function('s:tags_sink')})
endfunction

command! Tags call s:tags()

" Ctrlp for file search
nnoremap <silent> <expr> <C-p> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"
" Find files in current directory of file currently edited
nnoremap <silent> <Leader>. :Files <C-r>=expand("%:h")<CR>/<CR>
" Navigate between buffers
nnoremap <silent> <Leader>b :Buffers<CR>
" Recent Files
map <leader>r :FZFMru<CR>
" Folder Search
map <leader>p :RG<CR>

" Advanced Rg integration to restart search if query changes
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --hidden --smart-case --fixed-strings %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec, 'right:50%:hidden', '?'), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

" Find and replace in directory
function! Substitute(query, fullscreen)
  call RipgrepFzf(a:query, a:fullscreen)
  " Call substitute with new query
  " :cfdo %s/new query/ / \| update
endfunction

command! -nargs=* -bang SUBSTITUTE call Substitute(<q-args>, <bang>0)

nnoremap <Leader>S
  \ :SUBSTITUTE <C-R><C-W><CR>

