local servers = {}

servers.lua_ls = {
  filetypes = { 'lua' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      formatters = { ignoreComments = true },
      signatureHelp = { enabled = true },
      diagnostics = {
        globals = { 'rvim', 'vim' },
        disable = { 'missing-fields' },
      },
      telemetry = { enabled = false },
    },
  },
}

servers.basedpyright = {
  settings = {
    basedpyright = {
      analysis = { typeCheckingMode = 'standard' },
    },
  },
}

servers.nixd = {
  filetypes = { 'nix' },
  settings = {
    nixd = {
      nixpkgs = { expr = 'import <nixpkgs> {}' },
      options = {
        nixos = {
          expr = '(builtins.getFlake "github:dileep-kishore/nixos-hyprland").nixosConfigurations.tsuki.options',
        },
        home_manger = {
          expr = '(builtins.getFlake "github:dileep-kishore/nixos-hyprland").homeConfigurations."g8k@lap135849".options',
        },
      },
    },
  },
}

servers.gopls = {}

servers.astro = {}

servers.bashls = {}

servers.dockerls = {}

servers.biome = {}

servers.jsonls = {}

servers.harper_ls = {
  filetypes = { 'markdown', 'gitcommit', 'typst', 'html', 'text' },
}

servers.ltex_plus = {
  filetypes = {
    'bib',
    'org',
    'plaintex',
    'rst',
    'rnoweb',
    'tex',
    'pandoc',
    'quarto',
    'rmd',
    'context',
  },
  settings = {
    check_frequency = 'save',
  },
}

servers.texlab = {}

servers.marksman = {}

-- NOTE: julials must be installed manually
-- julia --project=~/.julia/environments/nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")'
-- julia --project=~/.julia/environments/nvim-lspconfig -e 'using Pkg; Pkg.update()'
servers.julials = {}

servers.ts_ls = {}

servers.ts_ls = {}

servers.rust_analyzer = {}

servers.svelte = {}

servers.tailwindcss = {}

servers.tinymist = {}

servers.cssls = {}

servers.html = {}

servers.lexical = {
  cmd = { "/Users/rakshan/projects/elixir/lexical/start_lexical.sh"}
}

return servers
