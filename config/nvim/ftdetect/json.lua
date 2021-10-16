vim.cmd [[
  au BufRead,BufNewFile tsconfig.json set filetype=jsonc
  autocmd BufRead .babelrc set filetype=json
  autocmd BufRead .eslintrc set filetype=json
  autocmd BufRead .tslintrc set filetype=json
]]
