local utils = require 'utils'
local nmap = utils.nmap
local exec = vim.api.nvim_command

local coc = {
  extensions = {
    'coc-tsserver',
    'coc-git',
    'coc-eslint',
    'coc-tslint-plugin',
    'coc-emmet',
    'coc-prettier',
    'coc-ultisnips',
    'coc-snippets',
    'coc-yaml',
    'coc-json',
    'coc-angular',
    'coc-pyright',
    'coc-tailwindcss',
  }
}

vim.g.coc_global_extensions = coc.extensions

-- Use K to show documentation in preview window
function show_documentation()
  if utils.isOneOf({'vim','help'}, vim.bo.filetype) then
    exec [[execute 'h '.expand('<cword>')]]
  else
    exec [[call CocActionAsync('doHover')]]
  end
end
nmap('K', ':lua show_documentation()<cr>')

-- Highlight symbol under cursor on CursorHold
exec [[autocmd CursorHold * silent call CocActionAsync('highlight')]]

-- Remap for rename current word
nmap('<leader>rn', '<Plug>(coc-rename)')
