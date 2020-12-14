if !has('nvim')
  finish
endif

if !has_key(plugs, "nvim-lspconfig")
   finish
endif

lua <<EOF
  local lspconfig = require'lspconfig'
  -- lspconfig.vimls.setup{}
  lspconfig.dockerls.setup{}
  lspconfig.cssls.setup{}
  -- lspconfig.html.setup{}
  -- lspconfig.jsonls.setup{}
  -- lspconfig.gopls.setup{}
EOF

function! s:ConfigureLSP()
  " Remap keys for gotos
  nnoremap <buffer> <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
  nnoremap <buffer> <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
  nnoremap <buffer> <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
  " nnoremap <buffer> <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>


  " Find symbol of current document
  " nnoremap <silent> <space>o    <cmd>lua vim.lsp.buf.document_symbol()<CR>
  " Search workspace symbols
  " nnoremap <silent> <space>t   <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

  setlocal omnifunc=v:lua.vim.lsp.omnifunc
endfunction


autocmd FileType docker,vim,scss,css,json,html,go call s:ConfigureLSP()


lua <<EOF
 -- organize imports sync
function go_organize_imports_sync(timeout_ms)
  local context = { source = { organizeImports = true } }
  vim.validate { context = { context, 't', true } }
  local params = vim.lsp.util.make_range_params()
  params.context = context

  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
  if not result then return end
  result = result[1].result
  if not result then return end
  edit = result[1].edit
  vim.lsp.util.apply_workspace_edit(edit)
end

vim.api.nvim_command("au BufWritePre *.go lua go_organize_imports_sync(1000)")
EOF
