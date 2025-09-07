require('lze').load {
  {
    'ChatGPT.nvim',
    event = 'DeferredUIEnter',
    after = function(_)
      require('chatgpt').setup {
        openai_params = { model = 'gpt-4.1-mini' },
      }
    end,
  },
}
