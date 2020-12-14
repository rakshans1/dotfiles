if !has('nvim')
  finish
endif

if !has_key(plugs, "telescope.nvim")
   finish
endif

if !has_key(plugs, "nvim-lspconfig")
   finish
endif


" Remap keys for gotos
nmap <silent> gr <cmd>lua require('telescope.builtin').lsp_references()<CR>

nmap <leader> o <cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>
