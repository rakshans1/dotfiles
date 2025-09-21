require('lze').load {
  {
    'better-escape.nvim',
    after = function(_)
      require('better_escape').setup {
        default_mappings = false,
        mappings = {
          c = { j = { k = '<Esc>' } },
          i = { j = { k = '<Esc>' } },
          s = { j = { k = '<Esc>' } },
          v = { j = { k = '<Esc>' } },
        },
      }
    end,
  },
  {
    'guess-indent.nvim',
    after = function(_)
      require('guess-indent').setup {
        auto_cmd = true,
        override_editorconfig = false,
      }
    end,
  },
  {
    'nvim-autopairs',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('nvim-autopairs').setup {
        check_ts = true,
      }
    end,
  },
  {
    'treesj',
    keys = {
      {
        'gs',
        '<cmd>lua require("treesj").toggle()<CR>',
        desc = 'Toggle treesj',
      },
    },
    after = function(_)
      require('treesj').setup {
        use_default_keymaps = false,
      }
    end,
  },
  {
    'vim-repeat',
  },
  {
    'outline.nvim',
    cmd = { 'Outline', 'OutlineOpen' },
    keys = {
      {
        'go',
        '<cmd>Outline<CR>',
        desc = 'Toggle Outline',
      },
    },
    load = function(name)
      require('lzextras').loaders.multi {
        name,
        'lspkind.nvim',
      }
    end,
    after = function(_)
      require('outline').setup {
        symbols = {
          icon_source = 'lspkind',
          filter = {
            default = { 'String', 'Variable', exclude = true },
          },
        },
        keymaps = {
          goto_location = 'e',
          peek_location = '<Cr>',
          fold = 'h',
          unfold = 'l',
          fold_toggle = 'o',
        },
      }
    end,
  },
  {
    'navigator-nvim',
    cmd = { 'NavigatorLeft', 'NavigatorRight', 'NavigatorUp', 'NavigatorDown' },
    event = { 'DeferredUIEnter' },
    keys = {
      {
        '<C-h>',
        '<CMD>NavigatorLeft<CR>',
        desc = 'Move to left pane',
      },
      {
        '<C-j>',
        '<CMD>NavigatorDown<CR>',
        desc = 'Move to down pane',
      },
      {
        '<C-k>',
        '<CMD>NavigatorUp<CR>',
        desc = 'Move to up pane',
      },
      {
        '<C-l>',
        '<CMD>NavigatorRight<CR>',
        desc = 'Move to right pane',
      },
    },
    after = function(_)
      require('Navigator').setup {
        auto_save = nil,
        disable_on_zoom = true,
        mux = 'auto',
      }
    end,
  },
  {
    'trouble.nvim',
    cmd = { 'Trouble', 'TroubleToggle' },
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<CR>',
        desc = 'Trouble diagnostics toggle (buffer)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle focus=true<CR>',
        desc = 'Trouble diagnostics toggle',
      },
      {
        '<leader>xl',
        '<cmd>Trouble lsp toggle focus=true win.position=bottom<cr>',
        desc = 'Trouble LSP toggle',
      },
      { '<leader>xL', '<cmd>Trouble loclist<cr>', desc = 'Trouble loclist' },
      {
        '<leader>xs',
        '<cmd>Trouble symbols toggle focus=true win.position=bottom<cr>',
        desc = 'Trouble symbols toggle',
      },
      {
        '<leader>xq',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Trouble qflist toggle',
      },
      {
        '<leader>xt',
        '<cmd>Trouble todo toggle filter.buf=0 focus=true<cr>',
        desc = 'Trouble todo toggle (buffer)',
      },
      {
        '<leader>xT',
        '<cmd>Trouble todo toggle focus=true<cr>',
        desc = 'Trouble todo toggle',
      },
    },
    after = function(_)
      require('trouble').setup {
        keys = {
          o = 'jump',
          ['<cr>'] = 'jump_close',
        },
      }
    end,
  },
  {
    'todo-comments.nvim',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('todo-comments').setup {
        merge_keywords = true,
        gui_style = {
          bg = 'BOLD',
          fg = 'BOLD',
        },
        highlight = {
          before = '',
          after = '',
          keyword = 'wide_fg',
        },
        keywords = {
          QUESTION = { icon = '' },
        },
      }
    end,
  },
  {
    'nvim-bqf',
    after = function(_)
      require('bqf').setup {
        auto_enable = true,
      }
    end,
  },
  {
    'marks.nvim',
    event = { 'DeferredUIEnter' },
    keys = {
      {
        '<leader>xm',
        '<cmd>MarksListBuf<CR>',
        desc = 'Quickfix marks (buffer)',
      },
      {
        '<leader>xM',
        '<cmd>MarksListAll<CR>',
        desc = 'Quickfix marks (all)',
      },
    },
    after = function(_)
      require('marks').setup {
        default_mappings = true,
      }
    end,
  },
  {
    'markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
  },
  {
    'cloak.nvim',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('cloak').setup {
        enabled = true,
      }
    end,
  },
  {
    'git-conflict.nvim',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('git-conflict').setup {
        default_commands = true,
        default_mappings = true,
      }
    end,
  },
  {
    'early-retirement-nvim',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('early-retirement').setup {}
    end,
  },
  {
    'maximize-nvim',
    event = { 'DeferredUIEnter' },
    keys = {
      {
        '<leader>wm',
        '<cmd>Maximize<CR>',
        desc = 'Window maximize toggle',
      },
    },
    after = function(_)
      require('maximize').setup {}
    end,
  },
  {
    'nvim-scissors',
    cmd = { 'ScissorsAddNewSnippet', 'ScissorsEditSnippet' },
    keys = {
      {
        '<leader>se',
        '<cmd>ScissorsEditSnippet<CR>',
        desc = 'Edit snippet',
      },
      {
        '<leader>sa',
        '<cmd>ScissorsAddNewSnippet<CR>',
        desc = 'Add new snippet',
      },
    },
    after = function(_)
      local snippetDir = vim.fn.expand '~/dotfiles/config/rvim/snippets'
      require('scissors').setup {
        snippetDir = snippetDir,
      }
    end,
  },
  {
    'timber-nvim',
    event = { 'DeferredUIEnter' },
    after = function(_)
      require('timber').setup {}
    end,
  },
  -- {
  --   'custom-theme-nvim',
  --   event = { 'DeferredUIEnter' },
  --   after = function(_)
  --     require('custom-theme').setup {}
  --   end,
  -- },
  {
    'vim-wakatime',
    event = { 'DeferredUIEnter' },
  },
}
