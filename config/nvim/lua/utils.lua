local fn = vim.fn
local utils = {}

function utils.nmap_options(key, action, options)
  fn.nvim_set_keymap('n', key, action, options)
end

function utils.nmap(key, action)
  utils.nmap_options(key, action, {})
end

function utils.imap(key, action)
  fn.nvim_set_keymap('i', key, action, {})
end

function utils.vmap(key, action)
  fn.nvim_set_keymap('v', key, action, {})
end

function utils.inoremap(key, action)
  fn.nvim_set_keymap('i', key, action, { noremap = true })
end

function utils.xnoremap(key, action)
  fn.nvim_set_keymap('x', key, action, { noremap = true })
end

function utils.nnoremap(key, action)
  utils.nmap_options(key, action, { noremap = true, silent= true })
end

function utils.noremap(key, action)
  utils.nmap_options(key, action, { noremap = true })
end

function utils.xmap(key, action)
  fn.nvim_set_keymap('x', key, action, {})
end

function utils.xnoremap(key, action)
  fn.nvim_set_keymap('x', key, action, { noremap = true })
end

function utils.isOneOf(list, x)
  for _, v in pairs(list) do
    if v == x then return true end
  end
  return false
end

return utils
