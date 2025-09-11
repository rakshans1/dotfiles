require('lze').load {
  {
    'neotest',
    keys = {
      {
        '<leader>tn',
        function()
          require('neotest').run.run()
        end,
        desc = 'Test nearest',
      },
      {
        '<leader>tf',
        function()
          require('neotest').run.run(vim.fn.expand '%')
        end,
        desc = 'Test file',
      },
      {
        '<leader>t',
        function()
          require('neotest').output.toggle()
        end,
        desc = 'Test Panel',
      },
      {
        '<leader>tp',
        function()
          require('neotest').output_panel.toggle()
        end,
        desc = 'Test Panel',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.open()
        end,
        desc = 'Test Summary',
      },
    },
    load = function(name)
      require('lzextras').loaders.multi {
        name,
        'neotest-elixir',
        'plenary.nvim',
      }
    end,
    after = function(_)
      require('neotest').setup {
        adapters = {
          require 'neotest-elixir',
        },
      }
    end,
  },
}

