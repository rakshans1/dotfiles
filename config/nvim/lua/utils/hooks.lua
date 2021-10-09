local M = {}

---Reset any startup cache files used by Packer and Impatient
---Tip: Useful for clearing any outdated settings
function M.reset_cache()
  _G.__luacache.clear_cache()
  require("plugin-loader"):cache_reset()
end

return M
