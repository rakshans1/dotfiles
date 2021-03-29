if !has('nvim')
  finish
endif

if !v:lua.plugin_loaded("nvim-treesitter")
  finish
endif

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"go", "javascript", "php"},
  highlight = {
    enable = true,
  },
}
EOF
