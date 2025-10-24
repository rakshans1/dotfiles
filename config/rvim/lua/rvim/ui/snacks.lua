require('lze').load {
  {
    'snacks.nvim',
    after = function(_)
      local snacks = require 'snacks'
      local snacks_dashboard = require 'rvim.ui.snacks-dashboard'
      require 'rvim.ui.snacks-rename'

      snacks.setup {
        styles = {
          float = { wo = { winblend = 0 } },
          lazygit = {
            border = 'rounded',
            backdrop = false,
          },
          git = { backdrop = false },
        },
        bigfile = { enabled = true },
        gitbrowse = { enabled = true },
        lazygit = {
          enabled = true,
          win = { position = 'float' },
        },
        quickfile = { enabled = false },
        dashboard = snacks_dashboard.dashboard,
        notifier = {
          enabled = true,
        },
        image = {
          enabled = true,
          doc = { inline = false, float = true },
        },
        statuscolumn = {
          enabled = false,
          left = { 'mark', 'sign' },
          right = { 'fold', 'git' },
          folds = { open = true, git_hl = true },
        },
        terminal = {
          enabled = true,
          win = { position = 'float' },
        },
        picker = {
          actions = {
            set_glob_pattern = function(picker)
              require('snacks').input({
                prompt = 'Glob pattern: ',
              }, function(pattern)
                if pattern and pattern ~= '' then
                  picker.opts.args = picker.opts.args or {}
                  table.insert(picker.opts.args, '--glob=' .. pattern)
                  picker:find()
                end
              end)
            end,
            copy_file_path = {
              action = function(_, item)
                if not item then
                  return
                end

                -- Get git root
                local git_root = vim.fn.systemlist(
                  'git -C '
                    .. vim.fn.shellescape(vim.fn.fnamemodify(item.file, ':h'))
                    .. ' rev-parse --show-toplevel'
                )[1]
                local path_from_git_root = ''
                if
                  git_root
                  and git_root ~= ''
                  and not git_root:match '^fatal:'
                then
                  local abs_path = vim.fn.fnamemodify(item.file, ':p')
                  path_from_git_root = abs_path:sub(#git_root + 2) -- +2 to skip the trailing slash
                end

                local vals = {
                  ['BASENAME'] = vim.fn.fnamemodify(item.file, ':t:r'),
                  ['EXTENSION'] = vim.fn.fnamemodify(item.file, ':t:e'),
                  ['FILENAME'] = vim.fn.fnamemodify(item.file, ':t'),
                  ['PATH'] = item.file,
                  ['PATH (CWD)'] = vim.fn.fnamemodify(item.file, ':.'),
                  ['PATH (GIT ROOT)'] = path_from_git_root,
                  ['PATH (HOME)'] = vim.fn.fnamemodify(item.file, ':~'),
                  ['URI'] = vim.uri_from_fname(item.file),
                }

                local options = vim.tbl_filter(function(val)
                  return vals[val] ~= ''
                end, vim.tbl_keys(vals))
                if vim.tbl_isempty(options) then
                  vim.notify('No values to copy', vim.log.levels.WARN)
                  return
                end
                table.sort(options)
                vim.ui.select(options, {
                  prompt = 'Choose to copy to clipboard:',
                  format_item = function(list_item)
                    return ('%s: %s'):format(list_item, vals[list_item])
                  end,
                }, function(choice)
                  local result = vals[choice]
                  if result then
                    vim.fn.setreg('+', result)
                    require('snacks').notify.info('Yanked `' .. result .. '`')
                  end
                end)
              end,
            },
            search_in_directory = {
              action = function(_, item)
                if not item then
                  return
                end
                local dir = vim.fn.fnamemodify(item.file, ':p:h')
                require('snacks').picker.grep {
                  cwd = dir,
                  cmd = 'rg',
                  args = {},
                  show_empty = true,
                  hidden = true,
                  ignored = true,
                  follow = false,
                  supports_live = true,
                }
              end,
            },
          },
          win = {
            input = {
              keys = {
                ['<S-k>'] = { 'history_back', mode = { 'n' } },
                ['<S-j>'] = { 'history_forward', mode = { 'n' } },
                ['t'] = { 'tab' },
                ['f'] = {
                  'set_glob_pattern',
                  mode = { 'n' },
                  desc = 'Set glob pattern',
                },
                ['v'] = { 'edit_vsplit' },
              },
            },
            list = {
              keys = {
                ['t'] = { 'tab' },
                ['v'] = { 'edit_vsplit' },
                ['y'] = { 'copy_file_path', desc = 'Copy file path' },
                ['s'] = { 'search_in_directory', desc = 'Search in directory' },
              },
            },
          },
        },
      }
    end,
  },
}
