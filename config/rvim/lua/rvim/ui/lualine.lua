local colors = {
  color2 = '#161821',
  color3 = '#b4be82',
  color4 = '#c6c8d1',
  color5 = '#2e313f',
  color8 = '#e2a478',
  color9 = '#3e445e',
  color10 = '#0f1117',
  color11 = '#17171b',
  color12 = '#818596',
  color15 = '#84a0c6',
}
local hide_in_width = function()
  return vim.fn.winwidth(0) > 80
end
local mode = {
  'mode',
  fmt = function(str)
    return '[' .. str:sub(1, 3) .. ']'
  end,
  padding = { left = 1, right = 1 },
}
local branch = {
  'b:gitsigns_head',
  icons_enabled = true,
  icon = '',
  separator = '',
  padding = { left = 1, right = 1 },
  color = { gui = 'bold,italic' },
}
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
local diff = {
  'diff',
  colored = true,
  cond = hide_in_width,
  update_in_insert = true,
  always_visible = true,
  source = diff_source,
  padding = { left = 0, right = 1 },
}

local icononly_filetype = {
  'filetype',
  colored = true,
  color = {
    fg = colors.color12,
    bg = colors.color10,
  },
  icon_only = true,
  separator = { left = '' },
  padding = { left = 1, right = 0 },
}
local filename = {
  'filename',
  file_status = true,
  path = 1,
  color = {
    fg = colors.color12,
    bg = colors.color10,
  },
  symbols = {
    modified = '',
    readonly = ' ',
    unnamed = '[No Name]',
    newfile = '[New]',
  },
  separator = '',
  padding = { left = 0, right = 0 },
}

local diagnostics = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  sections = { 'error', 'warn' },
  colored = true,
  update_in_insert = false,
  always_visible = false,
  padding = { left = 1, right = 1 },
}

local progress = {
  'progress',
  padding = { left = 0, right = 0 },
}

local location = {
  'location',
  separator = { left = ' ' },
  padding = { left = 1, right = 0 },
}

require('lze').load {
  {
    'lualine.nvim',
    load = function(name)
      require('lzextras').loaders.multi {
        name,
        'noice.nvim',
      }
    end,
    event = { 'DeferredUIEnter' },
    after = function(_)
      local macro = {
        require('noice').api.statusline.mode.get,
        cond = require('noice').api.statusline.mode.has,
        padding = { left = 0, right = 1 },
      }
      require('lualine').setup {
        options = {
          icons_enabled = true,
          globalstatus = true,
          theme = {
            visual = {
              a = { fg = colors.color2, bg = colors.color3, gui = 'bold' },
              b = { fg = colors.color4, bg = colors.color5 },
            },
            replace = {
              a = { fg = colors.color2, bg = colors.color8, gui = 'bold' },
              b = { fg = colors.color4, bg = colors.color5 },
            },
            inactive = {
              a = { fg = colors.color9, bg = colors.color10, gui = 'bold' },
              b = { fg = colors.color9, bg = colors.color10 },
              c = { fg = colors.color9, bg = colors.color10 },
            },
            normal = {
              a = { fg = colors.color11, bg = colors.color12 },
              b = { fg = colors.color4, bg = colors.color5 },
              c = { fg = colors.color4, bg = colors.color10 },
            },
            insert = {
              a = { fg = colors.color5, bg = colors.color4 },
              b = { fg = colors.color4, bg = colors.color5 },
            },
          },
          disabled_filetypes = {
            'alpha',
            'snacks_dashboard',
            'NvimTree',
            'Outline',
          },
          ignore_focus = {
            'snacks_terminal',
            'snacks_picker_input',
            'snacks_picker_list',
            'DiffviewFiles',
            'DiffviewFileHistory',
          },
        },
        sections = {
          lualine_a = { mode },
          lualine_b = { branch, diff },
          lualine_c = {},
          lualine_x = {},
          lualine_y = {
            macro,
            diagnostics,
          },
          lualine_z = { progress, location },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { icononly_filetype, filename },
          lualine_x = { location },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {
          lualine_a = { icononly_filetype, filename },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { 'tabs' },
        },
        winbar = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        winb = {},
        extensions = { 'quickfix', 'toggleterm' },
      }
    end,
  },
}
