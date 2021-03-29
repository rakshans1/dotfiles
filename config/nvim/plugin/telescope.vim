if !has('nvim')
  finish
endif

if !v:lua.plugin_loaded("telescope.nvim")
  finish
endif

if !v:lua.plugin_loaded("nvim-lspconfig")
  finish
endif


" Remap keys for gotos
nmap <silent> gr <cmd>lua require('telescope.builtin').lsp_references()<CR>

nmap <leader> o <cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>
