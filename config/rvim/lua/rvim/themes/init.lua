vim.cmd [[colorscheme iceberg-dark]]
vim.defer_fn(function()
  vim.api.nvim_set_hl(0, 'NormalFloat', { fg = '#c7c9d1', bg = '#161822' })
  vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#6c7189', bg = '#161822' })
  vim.api.nvim_set_hl(
    0,
    'SnacksPickerPrompt',
    { fg = '#6c7189', bg = '#161822' }
  )
  vim.api.nvim_set_hl(0, 'SignColumn', { fg = '#454d73', bg = '#161822' })
  vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#6c7189', bg = '#1f2233' })
  vim.api.nvim_set_hl(0, 'LineNr', { fg = '#6c7189', bg = nil })
  vim.api.nvim_set_hl(0, 'LineNrAbove', { fg = '#6c7189', bg = nil })
  vim.api.nvim_set_hl(0, 'LineNrBelow', { fg = '#6c7189', bg = nil })
  vim.api.nvim_set_hl(0, 'Pmenu', { fg = '#c7c9d1', bg = nil })
  vim.api.nvim_set_hl(0, 'PmenuSel', { fg = '#c7c9d1', bg = '#1f2233' })
  vim.api.nvim_set_hl(0, 'SnacksPickerTree', { fg = '#454d73', bg = nil })
end, 100)
