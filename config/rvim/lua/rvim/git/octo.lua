require('lze').load {
  {
    'octo.nvim',
    -- event = { 'DeferredUIEnter' },
    cmd = { 'Octo' },
    after = function(_)
      require('octo').setup {
        suppress_missing_scope = { projects_v2 = true },
      }
    end,
  },
}
