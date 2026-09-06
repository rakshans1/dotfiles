-- On macOS nvim resolves symlinks in buffer names (fix_fname uses realpath on
-- case-insensitive filesystems), so a file opened through a cwd-level symlink
-- (e.g. a feature-workspace member pointing at a git worktree) gets a buffer
-- name outside the cwd and the snacks explorer's follow_file can't reveal it.
-- Translate such resolved paths back to their symlink form under the cwd.
local M = {}

---@param file string normalized absolute buffer path
---@return string? path rewritten through a cwd-level symlink, nil if n/a
function M.translate(file)
  if not file or file == '' then
    return nil
  end
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  if file:sub(1, #cwd + 1) == cwd .. '/' then
    return nil -- already inside cwd
  end
  local ok, iter = pcall(vim.fs.dir, cwd)
  if not ok then
    return nil
  end
  for name, t in iter do
    if t == 'link' then
      local real = vim.uv.fs_realpath(cwd .. '/' .. name)
      if real then
        real = vim.fs.normalize(real)
        if file == real then
          return cwd .. '/' .. name
        end
        if file:sub(1, #real + 1) == real .. '/' then
          return cwd .. '/' .. name .. file:sub(#real + 1)
        end
      end
    end
  end
  return nil
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('rvim_symlink_follow', { clear = true }),
  callback = function(ev)
    vim.schedule(function()
      if ev.buf ~= vim.api.nvim_get_current_buf() then
        return
      end
      local explorer = require('snacks').picker.get({ source = 'explorer' })[1]
      if not explorer or explorer.closed or explorer:is_focused() then
        return
      end
      local file =
        M.translate(vim.fs.normalize(vim.api.nvim_buf_get_name(ev.buf)))
      if file then
        require('snacks').explorer.reveal { file = file }
      end
    end)
  end,
})

return M
