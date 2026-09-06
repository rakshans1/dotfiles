-- Hot-reload rvim config modules from the live dotfiles tree.
--
-- The nixCats build bakes the config into the nix store, so a running
-- instance never sees edits to ~/dotfiles/config/rvim until a rebuild +
-- restart. This reloads config modules straight from dotfiles instead:
--
--   :RvimReload                  reload the current buffer's module
--   :RvimReload rvim.ui.snacks   reload a specific module
--   :RvimReloadAuto              toggle reload-on-save (on by default)
--
-- Re-running a module replays its side effects. Keymaps, user commands and
-- augroups with `clear = true` are idempotent; `lze` specs may warn about
-- duplicate registration — harmless, but restart for a clean slate.

local M = {}

local src_root = vim.fs.normalize(vim.fn.expand '~/dotfiles/config/rvim/lua')

---@param file string absolute path of a lua file
---@return string? module name, if the file is a config module
function M.module_name(file)
  file = vim.fs.normalize(file)
  local roots = { src_root }
  local ok, nixcats = pcall(require, 'nixCats')
  if ok then
    table.insert(roots, vim.fs.normalize(nixcats.configDir .. '/lua'))
  end
  for _, root in ipairs(roots) do
    if file:sub(1, #root + 1) == root .. '/' and file:sub(-4) == '.lua' then
      local rel = file:sub(#root + 2, -5):gsub('/init$', '')
      return (rel:gsub('/', '.'))
    end
  end
end

---@param mod string module name, e.g. 'rvim.ui.snacks'
function M.reload(mod)
  local base = src_root .. '/' .. mod:gsub('%.', '/')
  local file = base .. '.lua'
  if not vim.uv.fs_stat(file) then
    file = base .. '/init.lua'
  end
  local chunk, err = loadfile(file)
  if not chunk then
    vim.notify(('hot-reload: %s'):format(err), vim.log.levels.ERROR)
    return
  end
  local ok, res = pcall(chunk)
  if not ok then
    vim.notify(('hot-reload %s failed: %s'):format(mod, res), vim.log.levels.ERROR)
    return
  end
  package.loaded[mod] = res == nil and true or res
  vim.notify('hot-reloaded ' .. mod)
end

M.auto = true

vim.api.nvim_create_user_command('RvimReload', function(cmd)
  local mod = cmd.args ~= '' and cmd.args
    or M.module_name(vim.api.nvim_buf_get_name(0))
  if not mod then
    vim.notify('hot-reload: not a config module', vim.log.levels.WARN)
    return
  end
  M.reload(mod)
end, {
  nargs = '?',
  complete = function(lead)
    return vim.tbl_filter(function(m)
      return m:find(lead, 1, true) == 1
    end, vim.tbl_keys(package.loaded))
  end,
  desc = 'Reload a config module from dotfiles',
})

vim.api.nvim_create_user_command('RvimReloadAuto', function()
  M.auto = not M.auto
  vim.notify('hot-reload on save: ' .. (M.auto and 'on' or 'off'))
end, { desc = 'Toggle config hot-reload on save' })

vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('rvim_hot_reload', { clear = true }),
  pattern = '*.lua',
  callback = function(ev)
    if not M.auto then
      return
    end
    local file = vim.fs.normalize(ev.match)
    if file:sub(1, #src_root + 1) ~= src_root .. '/' then
      return
    end
    local mod = M.module_name(file)
    if mod then
      M.reload(mod)
    end
  end,
})

return M
