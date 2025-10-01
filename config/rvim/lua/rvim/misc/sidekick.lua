require('lze').load {
  {
    'sidekick-nvim',
    event = { 'DeferredUIEnter' },
    keys = {
      {
        '<tab>',
        function()
          if not require('sidekick').nes_jump_or_apply() then
            return '<Tab>'
          end
        end,
        expr = true,
        desc = 'Goto/Apply Next Edit Suggestion',
      },
    },
    after = function(_)
      require('sidekick').setup {
        cli = {
          win = {
            layout = 'float',
            float = {
              width = 0.9,
              height = 0.9,
            },
          },
        },
      }
    end,
  },
}
