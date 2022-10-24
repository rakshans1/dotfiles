local M = {}

vim.cmd [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]]

M.defaults = {
  {
    name = "BufferKill",
    fn = function()
      require("core.bufferline").buf_kill "bd"
    end,
  },
  {
    name = "RvimToggleFormatOnSave",
    fn = function()
      require("core.autocmds").toggle_format_on_save()
    end,
  },
  {
    name = "RvimInfo",
    fn = function()
      require("core.info").toggle_popup(vim.bo.filetype)
    end,
  },
  {
    name = "RvimCacheReset",
    fn = function()
      require("utils.hooks").reset_cache()
    end,
  },
  {
    name = "RvimReload",
    fn = function()
      require("config"):reload()
    end,
  },
  {
    name = "RvimOpenlog",
    fn = function()
      vim.fn.execute("edit " .. require("core.log").get_path())
    end,
  },
}

function M.load(collection)
  local common_opts = { force = true }
  for _, cmd in pairs(collection) do
    local opts = vim.tbl_deep_extend("force", common_opts, cmd.opts or {})
    vim.api.nvim_create_user_command(cmd.name, cmd.fn, opts)
  end
end

return M
