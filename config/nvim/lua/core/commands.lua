local M = {}

M.defaults = {
  [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
  ]],
  [[ command! RvimInfo lua require('core.info').toggle_popup(vim.bo.filetype) ]],
  [[ command! RvimCacheReset lua require('utils.hooks').reset_cache() ]],
}

M.load = function(commands)
  for _, command in ipairs(commands) do
    vim.cmd(command)
  end
end

return M
