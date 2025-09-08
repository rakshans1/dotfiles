local snacks = require 'snacks'
vim.api.nvim_create_autocmd('User', {
  pattern = 'OilActionsPost',
  callback = function(event)
    if event.data.actions.type == 'move' then
      snacks.rename.on_rename_file(
        event.data.actions.src_url,
        event.data.actions.dest_url
      )
    end
  end,
})
