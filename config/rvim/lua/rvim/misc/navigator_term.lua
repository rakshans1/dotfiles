-- Navigator.nvim mux for term (~/projects/swift/frnk): at the edge of nvim's
-- windows, move focus to the neighbouring term split via term-ctl, the way the
-- tmux mux runs `tmux select-pane`.
local M = {}

local CTL = vim.env.HOME .. '/Applications/Frnk.app/Contents/MacOS/term-ctl'

-- True inside a term pane (and not inside tmux, which keeps its own mux).
function M.active()
  return vim.env.TMUX == nil and vim.env.TERM_PANE ~= nil and vim.fn.executable(CTL) == 1
end

function M.new()
  local Term = require('Navigator.mux.vi'):new()
  local direction = { h = 'left', j = 'down', k = 'up', l = 'right' }

  function Term:zoomed()
    local out = vim.fn.system { CTL, 'state' }
    return vim.v.shell_error == 0 and out:find('"zoomed"%s*:%s*true') ~= nil
  end

  function Term:navigate(dir)
    if dir == 'p' then
      vim.fn.system { CTL, 'next-pane' }
    elseif direction[dir] then
      vim.fn.system { CTL, 'focus', direction[dir] }
    end
    return self
  end

  return Term
end

return M
