inputs: let
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
  } @ packageDef: {
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
        dockerfile-language-server-nodejs
        vscode-langservers-extracted
        typescript-language-server
        rust-analyzer
        tailwindcss-language-server
        lexical

        # formatters
        stylua
        alejandra
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
        friendly-snippets
        lazydev-nvim
        lspsaga-nvim
        vim-illuminate
        promise-async
        nvim-ufo
        conform-nvim
        snacks-nvim
        nvim-notify
        noice-nvim
        inc-rename-nvim
        indent-blankline-nvim
        which-key-nvim
        gitsigns-nvim
        diffview-nvim
        neogit
        octo-nvim
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
        neogen
        avante-nvim
        ChatGPT-nvim
        wtf-nvim
        ssr-nvim
        grug-far-nvim
        img-clip-nvim
        vim-repeat
        outline-nvim
        trouble-nvim
        todo-comments-nvim
        refactoring-nvim
        nvim-bqf
        marks-nvim
        markdown-preview-nvim
        cloak-nvim
        git-conflict-nvim
        nvim-ts-autotag
        flash-nvim
        tiny-inline-diagnostic-nvim
        zen-mode-nvim
        pkgs.neovimPlugins.navigator-nvim
        pkgs.neovimPlugins.early-retirement-nvim
        pkgs.neovimPlugins.obsidian-nvim
        pkgs.neovimPlugins.possession-nvim
        pkgs.neovimPlugins.maximize-nvim
        pkgs.neovimPlugins.custom-theme-nvim
      ];
    };

    sharedLibraries = {general = with pkgs; [];};

    environmentVariables = {};

    extraWrapperArgs = {};

    python3.libraries = {test = _: [];};
    extraLuaPackages = {general = [(_: [])];};
  }
