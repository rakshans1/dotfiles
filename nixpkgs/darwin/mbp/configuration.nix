{ pkgs, config, nix-homebrew, homebrew-core, homebrew-cask, homebrew-pomerium, ... }:
{
  imports = [
    nix-homebrew.darwinModules.nix-homebrew
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
  system.primaryUser = "rakshan";

  # User configuration
  users.users.rakshan = {
    name = "rakshan";
    home = "/Users/rakshan";
    shell = pkgs.zsh;
  };

  # Remap Caps Lock to Escape
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  system.defaults = {
    NSGlobalDomain = {
      KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
      InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15
      "com.apple.trackpad.scaling" = 3.0;
    };


    dock = {
      autohide = true;
      show-recents = false;
      orientation = "bottom";
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      FirstClickThreshold = 0; # Click pressure: 0 = light, 1 = medium, 2 = firm
    };
  };

  # Match existing nixbld group GID to avoid conflicts
  ids.gids.nixbld = 350;

  # Enable Touch ID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # User owning the Homebrew prefix
    user = "rakshan";

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "pomerium/tap" = homebrew-pomerium;
    };

    # Enable mutable taps to allow manual tap management
    mutableTaps = false;
  };

  # Optional: Align homebrew taps config with nix-homebrew
  homebrew.taps = builtins.attrNames config.nix-homebrew.taps;

  # Homebrew packages - This is separate from nix-homebrew
  homebrew = {
    enable = true;
    # CLI tools and libraries (brew install)
    brews = [
      "pomerium-cli"
    ];

    # GUI applications (brew install --cask)
    casks = [
      "stats"
      "iterm2"
      "sublime-text"
      "sublime-merge"
      "google-chrome"
      "dbeaver-community"
      "postman"
      "vlc"
      "raycast"
      "discord"
      "cursor-cli"
      "obsidian"
      "omnidisksweeper"
      "monitorcontrol"
    ];

    # Mac App Store apps (requires mas CLI tool)
    masApps = {
      "WhatsApp Messenger" = 310633997;
    };

    # Automatically remove packages not listed above
    onActivation.cleanup = "zap";

    # Auto-update homebrew and packages
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
