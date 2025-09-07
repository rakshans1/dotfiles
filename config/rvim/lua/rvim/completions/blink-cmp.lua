require('lze').load {
  {
    'blink.compat',
    event = { 'DeferredUIEnter' },
  },
  {
    'blink.cmp',
    event = { 'DeferredUIEnter' },
    on_require = 'blink',
    load = function(name)
      require('lzextras').loaders.multi {
        name,
        'lazydev.nvim',
        'mini.snippets',
        'blink-cmp-avante',
      }
    end,
    after = function(_)
      require('blink.cmp').setup {
        appearance = { nerd_font_variant = 'normal' },
        snippets = { preset = 'mini_snippets' },
        keymap = {
          preset = 'enter',
          ['<Tab>'] = {},
          ['<S-Tab>'] = {},
          ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
          ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
          ['<C-j>'] = { 'snippet_forward', 'fallback' },
          ['<C-k>'] = { 'snippet_backward', 'fallback' },
        },
        signature = {
          enabled = false,
          window = {
            show_documentation = true,
            border = {
              { '󰙎', 'WarningMsg' },
              '─',
              '╮',
              '│',
              '╯',
              '─',
              '╰',
              '│',
            },
            winhighlight = 'Normal:Pmenu,CursorLine:PmenuSel,Search:None',
          },
        },
        cmdline = {
          enabled = true,
          keymap = { preset = 'inherit' },
          completion = {
            list = { selection = { preselect = false } },
            menu = { auto_show = true },
            ghost_text = { enabled = false },
          },
        },
        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = false,
            },
          },
          menu = {
            border = {
              { '󱐋', 'WarningMsg' },
              '─',
              '╮',
              '│',
              '╯',
              '─',
              '╰',
              '│',
            },
            winhighlight = 'Normal:Pmenu,CursorLine:PmenuSel,Search:None',
          },
          documentation = {
            auto_show = true,
            window = {
              border = {
                { '󰙎', 'WarningMsg' },
                '─',
                '╮',
                '│',
                '╯',
                '─',
                '╰',
                '│',
              },
              winhighlight = 'Normal:Pmenu,CursorLine:PmenuSel,Search:None',
            },
          },
          ghost_text = { enabled = false },
          accept = {
            auto_brackets = {
              enabled = true,
              semantic_token_resolution = { enabled = true },
            },
          },
        },
        sources = {
          default = {
            'avante',
            'lazydev',
            'lsp',
            'path',
            'snippets',
            'buffer',
          },
          providers = {
            snippets = {
              should_show_items = function(ctx)
                return ctx.trigger.initial_kind ~= 'trigger_character'
              end,
            },
            lazydev = {
              name = 'LazyDev',
              module = 'lazydev.integrations.blink',
              score_offset = 100,
            },
            avante = {
              module = 'blink-cmp-avante',
              name = 'Avante',
            },
          },
        },
      }
    end,
  },
  {
    'friendly-snippets',
    dep_of = { 'blink.cmp' },
  },
}
