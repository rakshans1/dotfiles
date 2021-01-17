if !has('nvim')
  finish
endif

if !has_key(plugs, "telescope.nvim")
   finish
endif

" Ctrlp for file search
nnoremap <silent> <expr> <C-p> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Telescope find_files\<cr>"

" Folder Search
map <leader>p :Telescope live_grep<CR>

if !has_key(plugs, "nvim-lspconfig")
   finish
endif


" Remap keys for gotos
nmap <silent> gr <cmd>lua require('telescope.builtin').lsp_references()<CR>

nmap <leader> o <cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>
