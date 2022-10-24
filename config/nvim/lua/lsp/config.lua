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
  "elixir-ls",
  "rust_analyzer"
}

local skipped_filetypes = { "markdown", "rst", "plaintext" }

local join_paths = require("utils").join_paths

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
        local code = d.code or (d.user_data and d.user_data.lsp.code)
        if code then
          return string.format("%s [%s]", d.message, code):gsub("1. ", "")
        end
        return d.message
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
  automatic_configuration = {
    ---@usage list of servers that the automatic installer will skip
    skipped_servers = skipped_servers,
    ---@usage list of filetypes that the automatic installer will skip
    skipped_filetypes = skipped_filetypes,
  },
  buffer_mappings = {
    normal_mode = {
      ["K"] = { "vim.lsp.buf.hover", "Show hover" },
      ["gd"] = { "vim.lsp.bug.definition", "Goto Definition" },
      ["gD"] = { "<cmd>vsplit | vim.lsp.buf.definition<CR>", "Goto declaration" },
      ["gr"] = { vim.lsp.buf.references, "Goto references" },
      ["gi"] = { vim.lsp.buf.implementation, "Goto Implementation" },
      ["gp"] = {
        function()
          require("lsp.peek").Peek "definition"
        end,
        "Peek definition",
      },
      ["gl"] = {
        function()
          local config = rvim.lsp.diagnostics.float
          config.scope = "line"
          vim.diagnostic.open_float(0, config)
        end,
        "Show line diagnostics",
      },
      ["<C-k>"] = {
        vim.lsp.buf.signature_help, "Show signature help"
      },
      ["<space>rn"] = {
        vim.lsp.buf.rename, "Rename"
      },
      ["<space>ca"] = {
        vim.lsp.buf.code_action, "Code action"
      }
    },
    insert_mode = {},
    visual_mode = {},
  },
  buffer_options = {
    --- enable completion triggered by <c-x><c-o>
    omnifunc = "v:lua.vim.lsp.omnifunc",
    --- use gq for formatting
    formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
  },
  installer = {
    setup = {
      ensure_installed = {},
      automatic_installation = {
        exclude = {},
      },
    },
  },
  nlsp_settings = {
    setup = {
      config_home            = join_paths(get_config_dir(), "lsp-settings"),
      append_default_schemas = true,
      local_settings_dir     = ".vim/lsp-settings",
      ignored_servers        = {},
      loader                 = "json"
    }
  },
  null_ls = {
    setup = {},
    config = {},
  },
  ---@deprecated use automatic_configuration.skipped_servers instead
  override = {},
}
