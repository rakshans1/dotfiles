local skipped_servers = {
  "angularls",
  "ccls",
  "cssmodules_ls",
  "denols",
  "emmet_ls",
  "eslint",
  "eslintls",
  "grammarly",
  "graphql",
  "pylsp",
  "quick_lint_js",
  "stylelint_lsp",
  "tailwindcss",
}

local skipped_filetypes = { "markdown", "rst", "plaintext" }

return {
  templates_dir = join_paths(get_runtime_dir(), "site", "after", "ftplugin"),
  diagnostics = {
    signs = {
      active = true,
      values = {
        { name = "DiagnosticSignError", text = "" },
        { name = "DiagnosticSignWarn", text = "" },
        { name = "DiagnosticSignHint", text = "" },
        { name = "DiagnosticSignInfo", text = "" },
      },
    },
    virtual_text = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
      format = function(d)
        local t = vim.deepcopy(d)
        local code = d.code or (d.user_data and d.user_data.lsp.code)
        if code then
          t.message = string.format("%s [%s]", t.message, code):gsub("1. ", "")
        end
        return t.message
      end,
    },
  },
  document_highlight = true,
  code_lens_refresh = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
  },
  peek = {
    max_height = 15,
    max_width = 30,
    context = 10,
  },
  on_attach_callback = nil,
  on_init_callback = nil,
  automatic_servers_installation = true,
  automatic_configuration = {
    ---@usage list of servers that the automatic installer will skip
    skipped_servers = skipped_servers,
    ---@usage list of filetypes that the automatic installer will skip
    skipped_filetypes = skipped_filetypes,
  },
  buffer_mappings = {
    normal_mode = {
      ["K"] = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Show hover" },
      ["gd"] = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Goto Definition" },
      ["gD"] = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Goto declaration" },
      ["gr"] = { "<cmd>lua vim.lsp.buf.references()<CR>", "Goto references" },
      ["gI"] = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Goto Implementation" },
      ["gs"] = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "show signature help" },
      ["gp"] = { "<cmd>lua require'rvim.lsp.peek'.Peek('definition')<CR>", "Peek definition" },
      ["gl"] = {
        "<cmd>lua require'rvim.lsp.handlers'.show_line_diagnostics()<CR>",
        "Show line diagnostics",
      },
    },
    insert_mode = {},
    visual_mode = {},
  },
  null_ls = {
    setup = {},
    config = {},
  },
  ---@deprecated use automatic_configuration.skipped_servers instead
  override = {},
}

