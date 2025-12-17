inputs:
let
  inherit (inputs.nixCats) utils;
in
{
  pkgs,
  settings,
  categories,
  name,
  extra,
  mkPlugin,
  ...
}@packageDef:
{
  lspsAndRuntimeDeps = {
    general = with pkgs; [
      universal-ctags
      ripgrep
      fd
      tree-sitter
      ast-grep
      imagemagick
      lazygit
      gh

      nix-doc

      # lsps
      lua-language-server
      gopls
      basedpyright
      nixd
      bash-language-server
      dockerfile-language-server
      vscode-langservers-extracted
      typescript-language-server
      copilot-language-server
      rust-analyzer
      tailwindcss-language-server
      lexical
      marksman

      # formatters
      stylua
      nixfmt
      shfmt
      gofumpt
      rustfmt
      ruff
      prettierd
      biome
      typstyle
      yamlfix

      # linters
      rstcheck
      vale
      stylelint
      eslint_d
      hadolint
    ];
  };

  startupPlugins = {
    general = with pkgs.vimPlugins; [
      pkgs.neovimPlugins.lze
      pkgs.neovimPlugins.lzextras
      nui-nvim
      better-escape-nvim
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-treesitter-context
      nvim-highlight-colors
      nvim-lint
      nvim-web-devicons
      render-markdown-nvim
      guess-indent-nvim
      vim-matchup
      transparent-nvim
      pkgs.neovimPlugins.incline-nvim
      pkgs.neovimPlugins.iceberg-nvim
    ];
  };

  optionalPlugins = {
    general = with pkgs.vimPlugins; [
      plenary-nvim
      blink-cmp
      mini-snippets
      blink-compat
      blink-cmp-avante
      pkgs.neovimPlugins.blink-cmp-git
      pkgs.neovimPlugins.blink-cmp-fuzzy-path
      friendly-snippets
      lazydev-nvim
      lspsaga-nvim
      vim-illuminate
      promise-async
      nvim-ufo
      conform-nvim
      nvim-notify
      noice-nvim
      inc-rename-nvim
      indent-blankline-nvim
      which-key-nvim
      gitsigns-nvim
      neogit
      diffview-nvim
      grapple-nvim
      yazi-nvim
      comment-nvim
      nvim-ts-context-commentstring
      mini-indentscope
      mini-ai
      mini-animate
      mini-basics
      mini-icons
      mini-move
      mini-operators
      mini-surround
      treesj
      nvim-autopairs
      copilot-lua
      pkgs.neovimPlugins.copilot-lsp
      avante-nvim
      ChatGPT-nvim
      wtf-nvim
      ssr-nvim
      grug-far-nvim
      vim-repeat
      outline-nvim
      trouble-nvim
      todo-comments-nvim
      nvim-bqf
      marks-nvim
      markdown-preview-nvim
      cloak-nvim
      git-conflict-nvim
      nvim-ts-autotag
      flash-nvim
      tiny-inline-diagnostic-nvim
      zen-mode-nvim
      neotest
      neotest-elixir
      toggleterm-nvim
      nvim-scissors
      pkgs.neovimPlugins.timber-nvim
      pkgs.neovimPlugins.navigator-nvim
      pkgs.neovimPlugins.early-retirement-nvim
      pkgs.neovimPlugins.possession-nvim
      pkgs.neovimPlugins.maximize-nvim
      pkgs.neovimPlugins.custom-theme-nvim
      pkgs.neovimPlugins.sidekick-nvim
      pkgs.neovimPlugins.snacks-nvim
      pkgs.neovimPlugins.octo-nvim
      vim-wakatime
      lualine-nvim
      undotree
    ];
  };

  sharedLibraries = {
    general = with pkgs; [ ];
  };

  environmentVariables = { };

  extraWrapperArgs = { };

  python3.libraries = {
    test = _: [ ];
  };
  extraLuaPackages = {
    general = [ (_: [ ]) ];
  };
}
