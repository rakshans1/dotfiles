require('lze').load {
  {
    'mini.ai',
    after = function(_)
      require('mini.ai').setup {}
    end,
  },
  {
    'mini.animate',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('mini.animate').setup {
        cursor = { enable = false },
        scroll = { enable = false },
        resize = { enable = false },
        open = { enable = true },
        close = { enable = true },
      }
    end,
  },
  {
    'mini.basics',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('mini.basics').setup {
        options = { extra_ui = true },
        autocommands = {
          basic = true,
          relnum_in_visual_mode = false,
        },
      }
    end,
  },
  {
    'mini.icons',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('mini.icons').setup {
        style = 'glpyh',
      }
    end,
  },
  {
    'mini.move',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('mini.move').setup {}
    end,
  },
  {
    'mini.operators',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('mini.operators').setup {
        exchange = { prefix = 'ge' },
        sort = { prefix = 'gS' },
      }
    end,
  },
  {
    'mini.surround',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('mini.surround').setup {
        respect_selection_type = true,
        search_method = 'cover_or_nearest',
      }
    end,
  },
}
