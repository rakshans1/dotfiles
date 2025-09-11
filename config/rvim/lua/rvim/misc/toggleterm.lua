local backslash_timer
local esc_timer

require('lze').load {
  {
    'toggleterm.nvim',
    cmd = {
      'ToggleTerm',
      'TermNew',
      'TermSelect',
      'ToggleTermSetName',
      'ToggleTermSendCurrentLine',
      'ToggleTermSendVisualLines',
      'ToggleTermSendVisualSelection',
    },
    keys = {
      {
        '<leader>tt',
        '<cmd>ToggleTerm direction=tab<cr>',
        desc = 'Toggle Terminal',
      },
      {
        '\\',
        '<cmd>ToggleTerm direction=tab<cr>',
        desc = 'Double backslash to toggle terminal',
      },
      {
        '<leader>tN',
        '<cmd>TermNew direction=horizontal<cr>',
        desc = 'New Terminal (Horizontal)',
      },
      {
        '<esc>',
        function()
          esc_timer = esc_timer or (vim.uv or vim.loop).new_timer()
          if esc_timer:is_active() then
            esc_timer:stop()
            vim.cmd 'stopinsert'
          else
            esc_timer:start(200, 0, function() end)
            return '<esc>'
          end
        end,
        mode = 't',
        desc = 'Double escape to normal mode',
        expr = true,
      },
    },
    after = function(_)
      require('toggleterm').setup {
        open_mapping = [[<c-\>]],
        direction = 'tab',
        shade_terminals = false,
      }
    end,
  },
}
