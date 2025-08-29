# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages system configuration files, shell settings, and development environment setup across macOS and Linux systems. It uses symlinks to deploy configuration files and includes automated setup scripts for new machines.

## Key Architecture Components

### Configuration Management
- **Setup Scripts**: `setup.sh` creates symlinks for dotfiles to `~/`, `setup-new-machine.sh` handles complete new system setup
- **Modular Install Scripts**: Located in `install/` directory for specific tools (brew, node, vim, etc.)
- **Platform Detection**: Scripts automatically detect macOS vs Linux and apply appropriate configurations

### Nix Integration
- **Flake Configuration**: `flake.nix` defines Home Manager configurations for different systems
- **Home Manager Modules**: In `nixpkgs/home-manager/` for declarative package management
- **Multiple Targets**: Supports `linux`, `mbp` (Apple Silicon), and `mbpi` (Intel Mac) configurations

### Karabiner Configuration System
- **TypeScript-based Rules**: `config/karabiner/rules.ts` generates Karabiner configuration
- **Hyper Key Setup**: Caps Lock → Hyper key with sublayers for efficient keyboard shortcuts
- **Build Process**: Uses `tsm` to compile TypeScript rules to JSON configuration

### Configuration File Structure
- **Shell**: tmux, zsh aliases/functions in `shell/`
- **Git**: Global git configuration in `git/`
- **RC Files**: Application-specific configs (ripgrep, iex) in `rc/`
- **Platform-specific**: Linux mime types, macOS-specific settings

## Common Commands

### Initial Setup
```bash
# Clone with submodules
git clone https://github.com/rakshans1/dotfiles.git ~/dotfiles
cd ~/dotfiles
git submodule init && git submodule update

# Apply dotfiles to existing system
./setup.sh

# Complete new machine setup
./setup-new-machine.sh
```

### Nix/Home Manager
```bash
# Apply Home Manager configuration (macOS Apple Silicon)
nix-switch

# Update flake dependencies
nix-update
```

### Karabiner Configuration
```bash
# Build Karabiner rules (in config/karabiner/)
karabiner-build
```

## Development Notes

- **Symlink Strategy**: The repository uses symlinks rather than copying files, allowing live editing of configs
- **Cross-platform Support**: Scripts detect platform and apply appropriate configurations
- **Modular Design**: Each tool/application has its own install script and configuration section
- **TypeScript for Karabiner**: Complex keyboard mappings are generated from TypeScript for maintainability
- **Home Manager Integration**: Modern Nix-based package management alongside traditional shell scripts

## File Naming Conventions

- Setup scripts are executable shell scripts in repository root
- Configuration files maintain their standard names (without leading dots) in subdirectories
- Symlinks add the dot prefix when linking to home directory
