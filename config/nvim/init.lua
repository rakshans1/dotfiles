require("bootstrap"):init()

local config = require "config"
config:load()

local plugins = require "plugins"
require("plugin-loader"):load { plugins, rvim.plugins }

vim.g.colors_name = rvim.colorscheme
vim.cmd("colorscheme " .. rvim.colorscheme)

vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.base16colorspace = 256
vim.go.t_Co = "256"

if vim.fn.has("termguicolors") then
    vim.go.t_8f = "[[38;2;%lu;%lu;%lum"
    vim.go.t_8b = "[[48;2;%lu;%lu;%lum"
    vim.go.t_SI = "[[5 q" -- insert mode vertical line
    vim.go.t_EI = "[[1 q" -- command mode block
end

local commands = require "core.commands"
commands.load(commands.defaults)

require("keymappings").setup()

require("lsp").setup()
