if !has_key(plugs, "coc.nvim")
   finish
endif

let g:vista_sidebar_width = 50
let g:vista_default_executive = 'coc'
let g:vista_echo_cursor = 0
let g:vista_blink = [0,0]
let g:vista_top_level_blink = [0,0]
let g:vista_keep_fzf_colors = 1
let g:airline#extensions#vista#enabled = 0

let g:vista_executive_for = {
  \ 'go': 'nvim_lsp',
  \ 'docker': 'nvim_lsp',
  \ 'sh': 'nvim_lsp',
  \ 'vim': 'nvim_lsp',
  \ 'scss': 'nvim_lsp',
  \ 'json': 'nvim_lsp',
  \ 'html': 'nvim_lsp',
  \ }

" let g:vista_fzf_preview = ['right:50%']

let g:vista#renderer#enable_icon = 1

let g:vista#renderer#icons = {
\        "keyword": "\uf1de",
\        "variable": "\ue79b",
\        "value": "\uf89f",
\        "operator": "\u03a8",
\        "function": "\u0192",
\        "reference": "\ufa46",
\        "constant": "\uf8fe",
\        "method": "\uf09a",
\        "struct": "\ufb44",
\        "class": "\uf0e8",
\        "interface": "\uf417",
\        "text": "\ue612",
\        "enum": "\uf435",
\        "enumMember": "\uf02b",
\        "module": "\uf40d",
\        "color": "\ue22b",
\        "property": "\ue624",
\        "field": "\uf9be",
\        "unit": "\uf475",
\        "event": "\ufacd",
\        "file": "\uf723",
\        "folder": "\uf114",
\        "snippet": "\ue60b",
\        "typeParameter": "\uf728",
\        "default": "\uf29c",
\  }

" Find symbol of current document
nnoremap <silent> <space>o  :Vista finder coc<cr>
