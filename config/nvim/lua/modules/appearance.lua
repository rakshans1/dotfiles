vim.cmd('colorscheme iceberg')

vim.o.background = "dark"
vim.g.base16colorspace = 256
vim.o.t_Co = "256"

if vim.fn.has("termguicolors") then
    vim.o.t_8f = "[[38;2;%lu;%lu;%lum"
    vim.o.t_8b = "[[48;2;%lu;%lu;%lum"
    vim.o.t_SI = "[[5 q" -- insert mode vertical line
    vim.o.t_EI = "[[1 q" -- command mode block
end
