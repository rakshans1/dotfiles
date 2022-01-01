local M = {}

function M.config()
  rvim.builtin.notify = {
    active = true,
    on_config_done = nil,
    -- TODO: update after https://github.com/rcarriga/nvim-notify/pull/24
    opts = {
      ---@usage Animation style one of { "fade", "slide", "fade_in_slide_out", "static" }
      stages = "slide",

      ---@usage timeout for notifications in ms, default 5000
      timeout = 5000,


      ---@usage Icons for the different levels
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "✎",
      },
    },
  }
end

M.params_injecter = function(_, entry)
  -- FIXME: this is currently getting ignored or is not passed correctly
  for key, value in pairs(lvim.builtin.notify.opts) do
    entry[key] = value
  end
  return entry
end

M.default_namer = function(logger, entry)
  entry["title"] = logger.name
  return entry
end

return M
