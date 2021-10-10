local M = {}

M.config = function()
  rvim.builtin.colorizer = {
    active = true,
    on_config_done = nil,
  }
end


M.setup = function()
  require 'colorizer'.setup {'css';'scss';'javascript';html = { mode = 'foreground'; }}
end

return M

