local conditions = require "core.lualine.conditions"
local colors = require "core.lualine.colors"

local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

local cursorline_hl = vim.api.nvim_get_hl_by_name("CursorLine", true)

local location_color = nil
local branch = rvim.icons.git.Branch
local separator = rvim.icons.ui.LineMiddle

if rvim.colorscheme == "tokyonight" then
  location_color = "SLBranchName"
  branch = "%#SLGitIcon#" .. rvim.icons.git.Branch .. "%*" .. "%#SLBranchName#"

  local status_ok, tnc = pcall(require, "tokyonight.colors")
  if status_ok then
    local tncolors = tnc.setup { transform = true }
    vim.api.nvim_set_hl(0, "SLSeparator", { fg = cursorline_hl.background, bg = tncolors.black })
    separator = "%#SLSeparator#" .. rvim.icons.ui.LineMiddle .. "%*"
  end
end

return {
  mode = {
    function()
      return " " .. rvim.icons.ui.Target .. " "
    end,
    padding = { left = 0, right = 0 },
    color = {},
    cond = nil,
  },
  branch = {
    "b:gitsigns_head",
    icon = branch,
    color = { gui = "bold" },
  },
  filename = {
    "filename",
    color = {},
    cond = nil,
  },
  diff = {
    "diff",
    source = diff_source,
    symbols = {
      added = rvim.icons.git.LineAdded .. " ",
      modified = rvim.icons.git.LineModified .. " ",
      removed = rvim.icons.git.LineRemoved .. " ",
    },
    padding = { left = 2, right = 1 },
    diff_color = {
      added = { fg = colors.green },
      modified = { fg = colors.yellow },
      removed = { fg = colors.red },
    },
    cond = nil,
  },
  python_env = {
    function()
      local utils = require "rvim.core.lualine.utils"
      if vim.bo.filetype == "python" then
        local venv = os.getenv "CONDA_DEFAULT_ENV" or os.getenv "VIRTUAL_ENV"
        if venv then
          local icons = require "nvim-web-devicons"
          local py_icon, _ = icons.get_icon ".py"
          return string.format(" " .. py_icon .. " (%s)", utils.env_cleanup(venv))
        end
      end
      return ""
    end,
    color = { fg = colors.green },
    cond = conditions.hide_in_width,
  },
  diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = {
      error = rvim.icons.diagnostics.BoldError .. " ",
      warn = rvim.icons.diagnostics.BoldWarning .. " ",
      info = rvim.icons.diagnostics.BoldInformation .. " ",
      hint = rvim.icons.diagnostics.BoldHint .. " ",
    },
    -- cond = conditions.hide_in_width,
  },
  treesitter = {
    function()
      return rvim.icons.ui.Tree
    end,
    color = function()
      local buf = vim.api.nvim_get_current_buf()
      local ts = vim.treesitter.highlighter.active[buf]
      return { fg = ts and not vim.tbl_isempty(ts) and colors.green or colors.red }
    end,
    cond = conditions.hide_in_width,
  },
  lsp = {
    function(msg)
      msg = msg or "LS Inactive"
      local buf_clients = vim.lsp.buf_get_clients()
      if next(buf_clients) == nil then
        -- TODO: clean up this if statement
        if type(msg) == "boolean" or #msg == 0 then
          return "LS Inactive"
        end
        return msg
      end
      local buf_ft = vim.bo.filetype
      local buf_client_names = {}
      local copilot_active = false

      -- add client
      for _, client in pairs(buf_clients) do
        if client.name ~= "null-ls" and client.name ~= "copilot" then
          table.insert(buf_client_names, client.name)
        end

        if client.name == "copilot" then
          copilot_active = true
        end
      end

      -- add formatter
      local formatters = require "rvim.lsp.null-ls.formatters"
      local supported_formatters = formatters.list_registered(buf_ft)
      vim.list_extend(buf_client_names, supported_formatters)

      -- add linter
      local linters = require "rvim.lsp.null-ls.linters"
      local supported_linters = linters.list_registered(buf_ft)
      vim.list_extend(buf_client_names, supported_linters)

      local unique_client_names = vim.fn.uniq(buf_client_names)

      local language_servers = "[" .. table.concat(unique_client_names, ", ") .. "]"

      if copilot_active then
        language_servers = language_servers .. "%#SLCopilot#" .. " " .. rvim.icons.git.Octoface .. "%*"
      end

      return language_servers
    end,
    separator = separator,
    color = { gui = "bold" },
    cond = conditions.hide_in_width,
  },
  location = { "location", color = location_color },
  progress = {
    "progress",
    fmt = function()
      return "%P/%L"
    end,
    color = {},
  },

  spaces = {
    function()
      local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")
      return rvim.icons.ui.Tab .. " " .. shiftwidth
    end,
    separator = separator,
    padding = 1,
  },
  encoding = {
    "o:encoding",
    fmt = string.upper,
    color = {},
    cond = conditions.hide_in_width,
  },
  filetype = { "filetype", cond = nil, padding = { left = 1, right = 1 } },
  scrollbar = {
    function()
      local current_line = vim.fn.line "."
      local total_lines = vim.fn.line "$"
      local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
      local line_ratio = current_line / total_lines
      local index = math.ceil(line_ratio * #chars)
      return chars[index]
    end,
    padding = { left = 0, right = 0 },
    color = "SLProgress",
    cond = nil,
  },
}
