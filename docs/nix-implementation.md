# Nix Implementation

Modern **flake-based Nix configuration** with Home Manager and Darwin integration for **cross-platform dotfiles management**.

## Architecture Overview

- **Flake-based**: `flake.nix` with pinned inputs and reproducible builds
- **Home Manager**: User-level package and configuration management
- **Nix-Darwin**: macOS system-level configuration
- **Cross-platform**: Linux and macOS (Apple Silicon + Intel) support
- **Modular Design**: Reusable modules for different components

## Flake Structure

### Inputs
```nix
# Core Nix ecosystem
nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";           # Stable packages
nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # Latest packages
home-manager.url = "github:nix-community/home-manager/release-25.05";
darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";

# Specialized tools
aiTools.url = "github:numtide/nix-ai-tools";                  # AI CLI tools
sops-nix.url = "github:Mic92/sops-nix";                       # Secret management

# macOS integration
nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
homebrew-core/cask.url = "github:homebrew/homebrew-*";

# Private repository
private.url = "git+file:///Users/rakshan/dotfiles/private";
```

### Outputs
- **homeConfigurations**: `linux`, `mbp` (user-level configs)
- **darwinConfigurations**: `mbp` (system-level macOS config)

## Module Architecture

### Home Manager Modules (`nixpkgs/home-manager/modules/`)
- `common.nix` - Cross-platform packages and basic configuration
- `zsh.nix` - Shell configuration with plugins and environment
- `tmux.nix` - Terminal multiplexer configuration
- `sops.nix` - Secret management integration
- `home-manager.nix` - Home Manager base configuration

### Platform Configurations
- `nixpkgs/home-manager/mac.nix` - macOS Home Manager entry point
- `nixpkgs/home-manager/linux.nix` - Linux Home Manager entry point
- `nixpkgs/darwin/mbp/configuration.nix` - macOS system configuration

### Package Management Strategy

**Multi-source Approach**:
- **Stable** (`nixpkgs`): Core system tools, development tools
- **Unstable** (`nixpkgsUnstable`): Latest versions when needed
- **AI Tools** (`aiTools`): Specialized AI/ML command-line tools
- **Platform-specific**: macOS-only packages (`mas`, `coreutils`) vs Linux-only packages

**Package Categories**:
```nix
# Core utilities: fd, ripgrep, fzf, bat, jq, zoxide, eza
# Development: neovim, nodejs, rust toolchain, git, kubectl
# Media: ffmpeg, yt-dlp, tesseract
# Nix tools: nixpkgs-fmt, nix-init
# Cloud: awscli2, caddy, cloudflared
# AI/ML: ollama, python with llm packages, claude-code, gemini-cli
# Security: age, sops, ssh-to-age
```

## Key Features

### Cross-Platform Support
```nix
# Platform detection and conditional packages
lib.optionals stdenv.isDarwin [
  mas coreutils pngpaste blueutil  # macOS-specific
] ++ lib.optionals stdenv.isLinux [
  # Linux-specific packages
]
```

### Homebrew Integration
- **nix-homebrew**: Declarative Homebrew management
- **Brewfile equivalent**: Casks managed through Nix
- **App Store integration**: `mas` for Mac App Store apps

### Development Environment
- **direnv**: Automatic environment loading with Nix support
- **Multiple language support**: Node.js, Rust, Python with packages
- **Editor integration**: Neovim, LunarVim with formatters

## Daily Commands

```bash
# Apply Home Manager configuration
nix-switch

# Update flake dependencies
nix-update

# Check flake health
nix flake check

# Build without switching (testing)
nix build .#homeConfigurations.mbp.activationPackage --no-link
```

## Configuration Workflow

### Adding Packages
1. **Edit module**: Add package to appropriate module (usually `common.nix`)
2. **Apply changes**: `nix-switch`
3. **Version control**: Commit changes to track configuration history

### Platform-Specific Configuration
```nix
# In mac.nix or linux.nix
imports = [
  ./modules/common.nix      # Cross-platform base
  ./modules/zsh.nix        # Shell configuration
  ./modules/tmux.nix       # macOS-specific (tmux enabled)
];
```

### Module Development
- **Modular approach**: Each tool/feature gets its own module
- **Reusability**: Modules can be imported across configurations
- **Parameterization**: Use function arguments for customization

## Advanced Features

### Input Following
```nix
# Ensure consistent package versions across inputs
inputs.nixpkgs.follows = "nixpkgs";
```

### ExtraSpecialArgs
```nix
# Pass additional inputs to Home Manager modules
extraSpecialArgs = {
  pkgsUnstable = inputs.nixpkgsUnstable.legacyPackages.aarch64-darwin;
  aiTools = inputs.aiTools.packages.aarch64-darwin;
  sops-nix = inputs.sops-nix;
  private = inputs.private;
};
```

### System Integration
- **Darwin configuration**: System-level settings, services, and Homebrew
- **Home Manager**: User-level packages and dotfiles
- **Unified management**: Both managed through same flake

## Benefits

- **Reproducibility**: Exact same environment across machines
- **Rollbacks**: Easy to revert to previous configurations
- **Modularity**: Reusable components and easy customization
- **Cross-platform**: Single configuration for macOS and Linux
- **Package management**: Declarative package installation and updates
- **Version control**: Configuration history and collaboration-friendly

## Troubleshooting

- **Build errors**: Check `nix flake check` for syntax issues
- **Missing packages**: Verify package exists in chosen nixpkgs channel
- **Permission issues**: Ensure proper file permissions for flake files
- **Darwin activation**: May require `sudo` for system-level changes
- **Cache issues**: Use `nix-collect-garbage` to clean old generations

## Future Enhancements

- **NixOS support**: Extend to full NixOS configurations
- **Remote deployment**: Deploy configurations to remote machines
- **CI integration**: Automated testing of configurations
- **Template system**: Generate new machine configurations from templates
