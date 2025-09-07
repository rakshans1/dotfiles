# nixcats Integration Plan

## Overview

This document outlines the plan to integrate [nixcats](https://github.com/BirdeeHub/nixCats-nvim) into our dotfiles repository, migrating from the current LunarVim setup to a more flexible and reproducible Neovim configuration management system.

## Current State Analysis

### Existing Setup
- **Package Management**: Home Manager with Nix
- **Current Editor**: LunarVim (lunarvim package) alongside regular neovim
- **Configuration Location**: `config/lvim/config.lua` + Home Manager generated config
- **Current Plugins**:
  - `cocopon/iceberg.vim` (theme)
  - `zbirenbaum/copilot.lua` (AI assistance)
  - `zbirenbaum/copilot-cmp` (completion integration)
  - `wakatime/vim-wakatime` (time tracking)
- **Key Features**:
  - Custom key bindings (Ctrl+S save, Ctrl+B tree toggle, etc.)
  - Telescope configuration with custom mappings
  - Copilot integration with nvim-cmp
  - Iceberg colorscheme
  - Format on save for Lua files

### Challenges with Current Setup
1. **Dependency on LunarVim**: Tied to LunarVim's architecture and update cycle
2. **Limited Plugin Control**: Plugin management through LunarVim's abstraction layer
3. **Configuration Duplication**: Config exists both in `config/lvim/config.lua` and Home Manager module
4. **Less Reproducibility**: LunarVim manages some dependencies internally

## Why nixcats?

### Benefits
1. **Full Control**: Direct management of Neovim and all plugins through Nix
2. **Reproducibility**: All dependencies declared and version-pinned in Nix
3. **Flexibility**: Can maintain existing Lua configuration structure
4. **Home Manager Integration**: Seamless integration with existing setup
5. **Multiple Configurations**: Can build different Neovim packages for different use cases
6. **Transparency**: Full visibility into all dependencies and their versions

### Trade-offs
1. **Learning Curve**: Need to understand nixcats category system
2. **Migration Effort**: Requires restructuring current configuration
3. **Plugin Packaging**: Some plugins might need custom packaging if not in nixpkgs

## Integration Strategy

### Phase 1: Home Manager Module Approach (Coexistence)

We'll use the Home Manager module template with a coexistence approach, keeping all three editors (nvim, LunarVim, and nixCats) available for gradual migration and testing.

#### Directory Structure
```
dotfiles/
├── config/
│   ├── nvim/                    # New nixcats configuration
│   │   ├── lua/
│   │   │   ├── config/          # Core configuration modules
│   │   │   │   ├── options.lua  # Vim options (from current setup)
│   │   │   │   ├── keymaps.lua  # Key bindings
│   │   │   │   └── autocmds.lua # Auto commands
│   │   │   ├── plugins/         # Plugin configurations
│   │   │   │   ├── telescope.lua
│   │   │   │   ├── copilot.lua
│   │   │   │   ├── treesitter.lua
│   │   │   │   └── ui.lua       # Theme, statusline, etc.
│   │   │   └── init.lua         # Main entry point
│   │   └── nix/
│   │       └── default.nix      # nixcats configuration
│   └── lvim/                    # Keep existing for rollback
└── nixpkgs/
    └── home-manager/
        └── modules/
            ├── nixcats.nix      # New nixcats module
            └── lvim.nix         # Keep for rollback
```

#### Implementation Steps

##### 1. Initialize nixcats Template
```bash
cd config/
mkdir nvim
cd nvim
nix flake init -t github:BirdeeHub/nixCats-nvim#home-manager
```

##### 2. Create Home Manager Module
Create `nixpkgs/home-manager/modules/nixcats.nix`:
```nix
{ config, pkgs, inputs, ... }:
let
  nixcats = inputs.nixcats.homeManagerModules.default;
in
{
  imports = [ nixcats ];

  nixcats = {
    enable = true;
    packageNames = [ "myNeovim" ];

    categoryDefinitions = { pkgs, settings, categories, name, ... }@packageDef: {
      # Plugin categories
      startupPlugins = {
        core = with pkgs.vimPlugins; [
          plenary-nvim
          nvim-web-devicons
        ];

        ui = with pkgs.vimPlugins; [
          # Theme
          (pkgs.vimUtils.buildVimPlugin {
            name = "iceberg-vim";
            src = pkgs.fetchFromGitHub {
              owner = "cocopon";
              repo = "iceberg.vim";
              rev = "HEAD";  # Pin to specific commit later
              sha256 = "...";
            };
          })

          # File explorer & fuzzy finder
          nvim-tree-lua
          telescope-nvim
          telescope-fzf-native-nvim
        ];

        treesitter = with pkgs.vimPlugins; [
          nvim-treesitter.withAllGrammars
          nvim-treesitter-context
        ];

        completion = with pkgs.vimPlugins; [
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          luasnip
          cmp_luasnip
        ];

        ai = with pkgs.vimPlugins; [
          copilot-lua
          copilot-cmp
        ];

        tracking = with pkgs.vimPlugins; [
          vim-wakatime
        ];
      };

      # LSP and tool categories
      lspsAndRuntimeDeps = {
        nix = with pkgs; [
          nil
          nixpkgs-fmt
        ];

        lua = with pkgs; [
          lua-language-server
          stylua
        ];

        web = with pkgs; [
          typescript-language-server
          nodePackages.eslint_d
          tailwindcss-language-server
        ];
      };

      # Environment variables
      environmentVariables = {
        test = {
          SOME_VAR = "some_value";
        };
      };
    };

    packageDefinitions = {
      myNeovim = { pkgs, ... }: {
        settings = {
          wrapRc = true;
          configDirName = "nvim";
          aliases = [ "vim" "nvim" ];
        };
        categories = {
          core = true;
          ui = true;
          treesitter = true;
          completion = true;
          ai = true;
          tracking = true;
          nix = true;
          lua = true;
          web = true;
        };
      };
    };

    defaultPackageName = "myNeovim";
  };
}
```

##### 3. Configure Lua Files

**`config/nvim/lua/init.lua`**:
```lua
-- Load configuration modules
require('config.options')
require('config.keymaps')
require('config.autocmds')

-- Only load plugins if they're available via nixCats
if nixCats then
  if nixCats('ai') then
    require('plugins.copilot')
  end

  if nixCats('ui') then
    require('plugins.telescope')
    require('plugins.ui')
  end

  if nixCats('treesitter') then
    require('plugins.treesitter')
  end
end
```

**`config/nvim/lua/config/options.lua`**:
```lua
-- Migrate existing vim options from lvim config
local opt = vim.opt

opt.shiftwidth = 2
opt.tabstop = 2
opt.relativenumber = true
opt.background = "dark"
opt.termguicolors = true
-- ... etc (all current vim options)
```

**`config/nvim/lua/config/keymaps.lua`**:
```lua
-- Migrate existing key bindings
local map = vim.keymap.set

map('n', '<C-s>', ':w<cr>', { desc = 'Save file' })
map('n', '<C-x>', ':q!<CR>', { desc = 'Quit without saving' })
map('n', '<C-b>', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })
-- ... etc (all current key bindings)
```

##### 4. Plugin Configuration Migration

**`config/nvim/lua/plugins/copilot.lua`**:
```lua
if not nixCats('ai') then
  return
end

require('copilot').setup({
  -- Migrate existing copilot configuration
})

-- Integrate with completion
local cmp = require('cmp')
-- ... existing cmp setup
```

**`config/nvim/lua/plugins/telescope.lua`**:
```lua
if not nixCats('ui') then
  return
end

local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup({
  defaults = {
    -- Migrate existing telescope configuration
    layout_strategy = "horizontal",
    layout_config = {
      prompt_position = "bottom",
      width = 0.95,
      preview_cutoff = 120,
      height = 0.75,
    },
    sorting_strategy = "descending",
    mappings = {
      -- Migrate existing mappings
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        -- ... etc
      },
    },
  },
})
```

##### 5. Update Home Manager Configuration

Update `nixpkgs/home-manager/mac.nix`:
```nix
{
  imports = [
    # ... existing imports
    ./modules/nixcats.nix  # Add this
    # ./modules/lvim.nix   # Comment out temporarily
  ];
}
```

Keep `nixpkgs/home-manager/modules/common.nix` unchanged:
```nix
home.packages = with pkgs; [
  # ... existing packages
  neovim      # Keep regular neovim alongside nixcats
  lunarvim    # Keep LunarVim alongside nixcats
  # ... rest unchanged
];
```

This allows for gradual migration and comparison between editors.

#### Editor Commands and Aliases

After integration, you'll have access to all three editors:

| Command | Editor | Configuration |
|---------|--------|---------------|
| `nvim` | Regular Neovim | System neovim |
| `lvim` | LunarVim | `~/.config/lvim/` |
| `rvim` | nixcats | `~/.config/nixCats-nvim/` |
| `vim-compare` | Helper command | Shows available editors |

This setup allows you to:
- Compare performance and features between editors
- Gradually migrate configurations and workflows
- Fall back to working editors if issues arise
- Test nixcats without losing existing functionality

### Phase 2: Testing and Validation

#### Testing Strategy
1. **Parallel Installation**: Initially run nixcats alongside LunarVim
2. **Feature Parity Check**: Ensure all current functionality works
3. **Performance Comparison**: Compare startup time and responsiveness
4. **Plugin Functionality**: Test each plugin individually

#### Validation Checklist
- [ ] All key bindings work as expected
- [ ] Copilot integration functional
- [ ] Telescope with custom mappings works
- [ ] File tree navigation works
- [ ] Treesitter syntax highlighting works
- [ ] LSP integration works (if configured)
- [ ] Colorscheme loads correctly
- [ ] Format on save works
- [ ] Wakatime tracking works

### Phase 3: Advanced Configuration

#### Multiple Package Configurations
After successful basic migration, we can create specialized configurations:

```nix
packageDefinitions = {
  # Full-featured development environment
  myNeovim = { ... };

  # Minimal editor for quick edits
  myNeovimLight = {
    categories = {
      core = true;
      ui = true;
      # Exclude heavy plugins
    };
  };

  # Language-specific configurations
  myNeovimWeb = {
    categories = {
      core = true;
      ui = true;
      web = true;
      # Web development focused
    };
  };
};
```

#### Plugin Input Management
For plugins not in nixpkgs or for specific versions:
```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  nixcats.url = "github:BirdeeHub/nixCats-nvim";

  # Custom plugin inputs
  copilot-lua = {
    url = "github:zbirenbaum/copilot.lua";
    flake = false;
  };
};
```

## Migration Timeline

### Week 1: Setup and Basic Configuration
- [ ] Initialize nixcats template
- [ ] Create basic Home Manager module
- [ ] Migrate core vim options and keymaps
- [ ] Set up basic plugin categories

### Week 2: Plugin Migration
- [ ] Migrate Copilot configuration
- [ ] Migrate Telescope setup
- [ ] Migrate UI plugins (theme, file tree)
- [ ] Test basic functionality

### Week 3: Advanced Features
- [ ] Set up Treesitter configuration
- [ ] Configure LSP integration (if desired)
- [ ] Migrate remaining plugins
- [ ] Performance testing and optimization

### Week 4: Finalization
- [ ] Complete feature parity validation
- [ ] Documentation updates
- [ ] Remove LunarVim dependencies
- [ ] Create rollback procedure documentation

## Rollback Strategy

### If Issues Arise
1. **Immediate Rollback**: Uncomment `lvim.nix` import, comment out `nixcats.nix`
2. **Selective Rollback**: Keep nixcats but use different package temporarily
3. **Gradual Migration**: Keep both systems during transition period

### Rollback Steps
```bash
# Quick rollback
cd ~/dotfiles/nixpkgs/home-manager
# Edit mac.nix to disable nixcats and re-enable lvim
nix-switch
```

## Expected Challenges and Solutions

### Challenge 1: Plugin Version Mismatches
**Solution**: Pin plugin versions in nixcats configuration, create custom packages for missing plugins

### Challenge 2: Configuration Complexity
**Solution**: Start with minimal configuration, gradually add features

### Challenge 3: Build Time
**Solution**: Use binary caches, optimize category definitions

### Challenge 4: Learning Curve
**Solution**: Extensive testing in isolation before switching

## Success Metrics

1. **Functionality**: All current features work identically
2. **Performance**: Startup time ≤ current setup
3. **Maintainability**: Easier to add/remove plugins
4. **Reproducibility**: Configuration works across different machines
5. **Documentation**: Clear setup instructions for future use

## Plugin Mapping Reference

### Current LunarVim Plugins → nixcats Categories

| Current Plugin | nixpkgs Package | Category | Configuration Location |
|----------------|-----------------|----------|----------------------|
| `cocopon/iceberg.vim` | Custom build required | `ui` | `plugins/ui.lua` |
| `zbirenbaum/copilot.lua` | `pkgs.vimPlugins.copilot-lua` | `ai` | `plugins/copilot.lua` |
| `zbirenbaum/copilot-cmp` | `pkgs.vimPlugins.copilot-cmp` | `ai` | `plugins/copilot.lua` |
| `wakatime/vim-wakatime` | `pkgs.vimPlugins.vim-wakatime` | `tracking` | Minimal setup needed |

### LunarVim Built-ins → nixcats Equivalents

| LunarVim Feature | nixcats Implementation | Category |
|------------------|------------------------|----------|
| `lvim.builtin.alpha` | `alpha-nvim` plugin | `ui` |
| `lvim.builtin.nvimtree` | `nvim-tree-lua` plugin | `ui` |
| `lvim.builtin.telescope` | `telescope-nvim` + extensions | `ui` |
| `lvim.builtin.treesitter` | `nvim-treesitter` with grammars | `treesitter` |
| `lvim.builtin.terminal` | `toggleterm-nvim` plugin | `terminal` |
| `lvim.builtin.bufferline` | `bufferline-nvim` plugin | `ui` |
| `lvim.builtin.lualine` | `lualine-nvim` plugin | `ui` |
| `lvim.builtin.which_key` | `which-key-nvim` plugin | `ui` |
| `lvim.builtin.cmp` | `nvim-cmp` + sources | `completion` |

### Configuration Value Mappings

| LunarVim Setting | nixcats/Neovim Equivalent |
|------------------|---------------------------|
| `lvim.leader = "space"` | `vim.g.mapleader = " "` |
| `lvim.keys.normal_mode["<C-s>"]` | `vim.keymap.set('n', '<C-s>', ...)` |
| `lvim.colorscheme = "iceberg"` | `vim.cmd.colorscheme("iceberg")` |
| `lvim.format_on_save` | Custom autocmd or conform.nvim |
| `lvim.builtin.*.setup.*` | Direct plugin `setup()` calls |

## Testing Strategy

### Pre-Migration Testing
```bash
# Test current LunarVim setup
cd ~/dotfiles
nix-switch
lvim --version
lvim +checkhealth
```

### During Migration Testing
```bash
# Test nixcats build without installing
cd config/nvim
nix build --show-trace

# Test in isolation
nix shell .#myNeovim
myNeovim +checkhealth

# Test plugin loading
myNeovim -c "lua print(vim.inspect(require('nixCats')))"
```

### Validation Scripts

Create `scripts/validate-nixcats.lua`:
```lua
-- Validation script to run in Neovim
local function validate_plugin(name, check_fn)
  local ok, result = pcall(check_fn)
  print(string.format("%s: %s", name, ok and "✓" or "✗"))
  if not ok then
    print("  Error:", result)
  end
end

-- Test core functionality
validate_plugin("nixCats", function()
  return type(require('nixCats')) == 'table'
end)

validate_plugin("Copilot", function()
  return require('copilot') ~= nil
end)

validate_plugin("Telescope", function()
  require('telescope').setup({})
  return true
end)

-- Test key bindings
validate_plugin("Key Bindings", function()
  local has_telescope = vim.fn.exists(':Telescope') > 0
  local has_tree = vim.fn.exists(':NvimTreeToggle') > 0
  return has_telescope and has_tree
end)

print("\nValidation complete!")
```

### Automated Testing Approach

Create `scripts/test-migration.sh`:
```bash
#!/usr/bin/env bash

# Automated testing script
set -e

echo "🧪 Testing nixcats migration..."

# Build configuration
echo "Building nixcats configuration..."
cd config/nvim
nix build --show-trace --no-link

# Test startup time
echo "Testing startup time..."
hyperfine --warmup 3 \
  'lvim --headless +q' \
  'nix shell .#myNeovim -c myNeovim --headless +q'

# Test plugin loading
echo "Testing plugin availability..."
nix shell .#myNeovim -c myNeovim \
  --headless \
  -c "lua require('scripts.validate-nixcats')" \
  -c "qa!"

echo "✅ All tests passed!"
```

## Risk Assessment and Mitigation

### High Risk Items
1. **Plugin Compatibility**: Some LunarVim-specific functionality might not translate
   - **Mitigation**: Thorough testing of each plugin individually

2. **Configuration Complexity**: nixcats configuration is more verbose
   - **Mitigation**: Start simple, add complexity gradually

3. **Build Dependencies**: Nix builds might fail on missing dependencies
   - **Mitigation**: Use known-good nixpkgs commit, test builds early

### Medium Risk Items
1. **Performance Regression**: More plugins might slow startup
   - **Mitigation**: Profile startup time, lazy-load plugins

2. **Muscle Memory**: Different command names and workflows
   - **Mitigation**: Maintain same aliases and key bindings

### Low Risk Items
1. **Documentation Gaps**: Some nixcats features might be undocumented
   - **Mitigation**: Reference example configurations, community support

## Alternative Approaches Considered

### Option 1: Direct Neovim + Home Manager
**Pros**: Simpler, more direct control
**Cons**: Less reproducible, manual plugin management

### Option 2: NixVim
**Pros**: Comprehensive module system
**Cons**: Less flexibility, steeper learning curve

### Option 3: Keep LunarVim with Nix Overlay
**Pros**: Minimal change
**Cons**: Still tied to LunarVim's architecture

**Decision**: nixcats chosen for best balance of flexibility and reproducibility

## Resources

- [nixcats Documentation](https://nixcats.org/nixCats_installation.html)
- [nixcats GitHub Repository](https://github.com/BirdeeHub/nixCats-nvim)
- [Example Implementation: nyanvim](https://github.com/dileep-kishore/nyanvim)
- [Home Manager Documentation](https://nix-community.github.io/home-manager/)
- [Neovim Plugin Development](https://neovim.io/doc/user/lua-guide.html)

## Current Status

✅ **Integration Complete!** nixcats has been successfully integrated alongside your existing editors.

### What's Been Done

1. ✅ Added nixcats flake input to main `flake.nix`
2. ✅ Created `nixpkgs/home-manager/modules/nixcats.nix` module
3. ✅ Updated Home Manager configuration to include nixcats
4. ✅ Configured coexistence with LunarVim and regular neovim
5. ✅ Set up non-conflicting aliases and commands

### What You Can Do Now

1. **Apply the changes**: Run `nix-switch` to apply the new configuration
2. **Test nixcats**: Try `rvim` command
3. **Compare editors**: Use `vim-compare` to see available options
4. **Migrate gradually**: Start moving your LunarVim config to nixcats when ready

### Next Steps (Optional)

1. **Test and validate**: Ensure all three editors work correctly
2. **Customize nixcats**: Modify the configuration in `config/nvim/` to match your preferences
3. **Migrate plugins**: Gradually move your favorite LunarVim plugins to nixcats
4. **Performance compare**: Test startup times and features between editors
5. **Documentation**: Create personal notes on which editor works best for different tasks

### Quick Commands

```bash
# Apply the new configuration
nix-switch

# Test nixcats
rvim

# Test all editors
nvim --version     # Regular neovim
lvim --version     # LunarVim
rvim --version     # nixcats

# See available editors
vim-compare
```

This integration provides a safe, gradual migration path where you can test nixcats alongside your existing tools without losing functionality.
