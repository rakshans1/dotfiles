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
  vim.api.nvim_set_hl(0, 'SnacksPickerDir', { fg = '#6c7189', bg = nil })
  vim.api.nvim_set_hl(0, 'SnacksDashboardDir', { fg = '#6c7189', bg = nil })
  vim.api.nvim_set_hl(
    0,
    'RenderMarkdownCodeBorder',
    { fg = nil, bg = '#161822' }
  )
  vim.api.nvim_set_hl(0, 'RenderMarkdownH1', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH2', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH3', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH3Bg', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH4', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH4Bg', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH5', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH5Bg', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH6', { fg = nil, bg = '#161822' })
  vim.api.nvim_set_hl(0, 'RenderMarkdownH6Bg', { fg = nil, bg = '#161822' })

  -- Diff highlighting with better syntax visibility
  vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#404A37', fg = nil })
  vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#1a1a2a', fg = nil })
  vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#461A20', fg = '#3B3C44' })
  vim.api.nvim_set_hl(0, 'DiffText', { bg = '#2a2a3a', fg = nil })
end, 100)
