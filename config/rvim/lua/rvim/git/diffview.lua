require('lze').load {
  {
    'diffview.nvim',
    event = { 'DeferredUIEnter' },
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewFileHistory',
    },
    after = function(_)
      require('diffview').setup {
        enhanced_diff_hl = true,
        view = {
          default = {
            layout = 'diff2_horizontal',
          },
          merge_tool = {
            layout = 'diff3_horizontal',
          },
        },
        file_panel = {
          listing_style = 'tree',
          win_config = {
            position = 'left',
            width = 35,
          },
        },
        file_history_panel = {
          win_config = {
            position = 'left',
            width = 35,
          },
        },
      }
    end,
  },
}
