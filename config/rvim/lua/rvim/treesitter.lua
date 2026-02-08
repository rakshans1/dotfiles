require('lze').load {
  {
    'nvim-treesitter',
    event = 'DeferredUIEnter',
    dep_of = { 'render-markdown.nvim' },
    load = function(name)
      require('lzextras').loaders.multi {
        name,
        'nvim-treesitter-textobjects',
        'treesitter-context',
        'nvim-ts-autotag',
        'nvim-treesitter-endwise',
      }
    end,
    after = function(_)
      -- New nvim-treesitter API: highlighting is enabled via vim.treesitter.start()
      -- Create autocmd to enable treesitter highlighting for all filetypes with a parser
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if ok then
            -- Enable matchup integration
            vim.b[args.buf].matchup_matchparen_enabled = 1
          end
        end,
      })

      -- Setup nvim-treesitter-textobjects with new API
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
      }

      -- Textobject select keymaps
      local select = require('nvim-treesitter-textobjects.select')
      local select_maps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['al'] = '@loop.outer',
        ['il'] = '@loop.inner',
        ['as'] = '@conditional.outer',
        ['is'] = '@conditional.inner',
      }
      for key, query in pairs(select_maps) do
        vim.keymap.set({ 'x', 'o' }, key, function()
          select.select_textobject(query, 'textobjects')
        end, { desc = 'Select ' .. query })
      end

      -- Movement keymaps
      local move = require('nvim-treesitter-textobjects.move')
      local move_maps = {
        goto_next_start = {
          [']f'] = '@function.outer',
          [']c'] = '@class.outer',
          [']l'] = '@loop.outer',
          [']s'] = '@conditional.outer',
          [']p'] = '@parameter.outer',
          [']j'] = '@cellseparator',
        },
        goto_next_end = {
          [']F'] = '@function.outer',
          [']C'] = '@class.outer',
          [']L'] = '@loop.outer',
          [']S'] = '@conditional.outer',
          [']P'] = '@parameter.outer',
        },
        goto_previous_start = {
          ['[f'] = '@function.outer',
          ['[c'] = '@class.outer',
          ['[l'] = '@loop.outer',
          ['[s'] = '@conditional.outer',
          ['[p'] = '@parameter.outer',
          ['[j'] = '@cellseparator',
        },
        goto_previous_end = {
          ['[F'] = '@function.outer',
          ['[C'] = '@class.outer',
          ['[L'] = '@loop.outer',
          ['[S'] = '@conditional.outer',
          ['[P'] = '@parameter.outer',
        },
      }
      for fn_name, maps in pairs(move_maps) do
        for key, query in pairs(maps) do
          vim.keymap.set({ 'n', 'x', 'o' }, key, function()
            move[fn_name](query, 'textobjects')
          end, { desc = fn_name:gsub('_', ' ') .. ' ' .. query })
        end
      end

      -- Swap keymaps
      local swap = require('nvim-treesitter-textobjects.swap')
      vim.keymap.set('n', 'gpl', function()
        swap.swap_next('@parameter.inner', 'textobjects')
      end, { desc = 'Swap next parameter' })
      vim.keymap.set('n', 'gph', function()
        swap.swap_previous('@parameter.inner', 'textobjects')
      end, { desc = 'Swap previous parameter' })

      -- TODO: Neovim 0.12 adds built-in 'an'/'in' text objects for incremental selection (PR #34011)
      -- Remove this comment and use the native feature when upgrading to 0.12+

      require('treesitter-context').setup {
        enable = true,
        max_lines = 0,
        mode = 'topline',
        separator = '-',
      }
      require('nvim-ts-autotag').setup {
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      }
    end,
  },
}

-- -- NOTE: This makes textobject moves repeatable
-- local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'
-- vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
-- vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)
