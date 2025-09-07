require('lze').load {
  {
    'obsidian-nvim',
    event = { 'DeferredUIEnter' },
    ft = { 'markdown' },
    after = function(_)
      require('obsidian').setup {
        disable_frontmatter = true,
        legacy_commands = false,
        workspaces = {
          {
            name = 'LifeOS',
            path = '~/Documents/LifeOS',
          },
        },
        new_notes_location = 'notes_subdir',
        notes_subdir = '00_Inbox',
        preferred_link_style = 'wiki',
        note_id_func = function(title)
          return title
        end,
        daily_notes = {
          folder = '01_TimeFrames/011_Daily',
          date_format = '%Y-%m-%d',
          template = '_Templates/timeframes/DailyTemplate.md',
        },
        templates = {
          folder = '_Templates',
          date_format = '%Y-%m-%d',
          time_format = '%H:%M',
          substitutions = {},
        },
        completion = {
          min_chars = 2,
          nvim_cmp = false,
          blink = true,
        },
        picker = { name = 'snacks.pick' },
        ui = { enable = false },
        attachments = {
          img_folder = '_Assets',
        },
      }
    end,
  },
}

local function map(mode, key, action, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, key, action, options)
end

map('n', '<leader>nn', '<cmd>ObsidianNew<cr>', { desc = 'Obsidian new note' })
map(
  'n',
  '<leader>nf',
  '<cmd>ObsidianQuickSwitch<cr>',
  { desc = 'Obsidian quick switch' }
)
map('n', '<leader>nd', '<cmd>ObsidianToday<cr>', { desc = 'Obsidian today' })
map(
  'n',
  '<leader>nt',
  '<cmd>ObsidianTemplate<cr>',
  { desc = 'Obsidian template' }
)
map('v', '<leader>nk', '<cmd>ObsidianLink<cr>', { desc = 'Obsidian link' })
map(
  'n',
  '<leader>nb',
  '<cmd>ObsidianBacklinks<cr>',
  { desc = 'Obsidian backlinks' }
)
map('n', '<leader>nl', '<cmd>ObsidianLinks<cr>', { desc = 'Obsidian links' })
map('n', '<leader>nr', '<cmd>ObsidianRename<cr>', { desc = 'Obsidian rename' })
map(
  'n',
  '<leader>no',
  '<cmd>ObsidianTOC<cr>',
  { desc = 'Obsidian table of contents' }
)
