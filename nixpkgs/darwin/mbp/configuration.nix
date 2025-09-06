{ pkgs, config, nix-homebrew, homebrew-core, homebrew-cask, sops-nix, ... }:
{
  imports = [
    nix-homebrew.darwinModules.nix-homebrew
    ./modules/sops.nix
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
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
      InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15
      ApplePressAndHoldEnabled = false;
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
    screencapture = {
      target = "clipboard";
    };
  };

  # Match existing nixbld group GID to avoid conflicts
  ids.gids.nixbld = 350;

  # Nix configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Enable Touch ID for sudo authentication with tmux support
  # TODO: When upgrading to nix-darwin post-Feb 2025, replace this manual PAM config with:
  # programs.pam-reattach.enable = true;
  # security.pam.services.sudo_local.touchIdAuth = true;
  # See: https://github.com/nix-darwin/nix-darwin/pull/1344
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    text = ''
      # sudo_local: allow touch ID and pam_reattach for tmux compatibility
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so
      auth       sufficient     pam_tid.so
      auth       required       pam_opendirectory.so
      account    required       pam_permit.so
      password   required       pam_deny.so
      session    required       pam_permit.so
    '';
  };

  # Install pam-reattach to enable Touch ID in tmux
  environment.systemPackages = with pkgs; [
    pam-reattach
  ];

  # System-wide fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # User owning the Homebrew prefix
    user = "rakshan";

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
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
      "ghostty"
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
