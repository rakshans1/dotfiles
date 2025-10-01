#!/bin/bash

# Simple setup script for remaining configurations
# Most dotfiles are now managed by Nix Home Manager

set -e

echo "🎯 Dotfiles Setup"
echo "================="
echo ""
echo "ℹ️  Most configuration files are managed by Nix Home Manager."
echo "   Run 'nix-switch' to apply Nix-managed configurations."
echo ""

# Ensure .config directory exists
mkdir -p "$HOME/.config"

# Handle Karabiner configuration (requires symlinking due to TypeScript build process)
if [ -d "$(pwd)/config/karabiner" ]; then
  if [ ! -e "$HOME/.config/karabiner" ]; then
    echo "🔗 Linking Karabiner configuration..."
    ln -s "$(pwd)/config/karabiner" "$HOME/.config/karabiner"
    echo "   ✅ Karabiner configuration linked"
  else
    echo "   ℹ️  Karabiner configuration already exists"
  fi
fi

# Platform-specific setup
setup_linux() {
  echo ""
  echo "🐧 Linux setup..."

  # Install Nerd Fonts
  if [ ! -d "$HOME/.local/share/fonts/FiraCode" ]; then
    echo "📦 Installing FiraCode Nerd Font..."
    mkdir -p "$HOME/.local/share/fonts/FiraCode"
    cd /tmp
    wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
    unzip -q FiraCode.zip -d "$HOME/.local/share/fonts/FiraCode"
    fc-cache -f "$HOME/.local/share/fonts/FiraCode" 2>/dev/null || true
    echo "   ✅ FiraCode font installed"
    cd - >/dev/null
  fi
}

setup_mac() {
  echo ""
  echo "🍎 macOS setup..."
  echo "   ℹ️  macOS configurations are handled by nix-darwin"
  echo "   ℹ️  Run 'darwin-rebuild switch --flake .' for system settings"
}

# Platform detection and setup
case "$(uname)" in
Linux*) setup_linux ;;
Darwin*) setup_mac ;;
*) echo "❌ Unsupported platform" ;;
esac

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "  • Run 'nix-switch' to apply Home Manager configurations"
echo "  • Run 'darwin-rebuild switch --flake .' for macOS system settings (macOS only)"
echo "  • Restart your shell or run 'source ~/.zshrc'"
