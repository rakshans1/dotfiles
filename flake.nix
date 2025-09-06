{
  description = "Home Manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    aiTools.url = "github:numtide/nix-ai-tools";
    ghostty.url = "github:ghostty-org/ghostty";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    private = {
      url = "git+file:///Users/rakshan/dotfiles/private";
      flake = false; # Treat as source, not a flake
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nixpkgsUnstable, darwin, sops-nix, private, ... }: {

    homeConfigurations = {
      linux = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./nixpkgs/home-manager/linux.nix ];
        extraSpecialArgs = {
            pkgsUnstable = inputs.nixpkgsUnstable.legacyPackages.x86_64-linux;
            aiTools = inputs.aiTools.packages.x86_64-linux;
            ghostty = inputs.ghostty.packages.x86_64-linux;
            sops-nix = inputs.sops-nix;
            private = inputs.private;
          };
      };
      mbp = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./nixpkgs/home-manager/mac.nix ];
        extraSpecialArgs = {
            pkgsUnstable = inputs.nixpkgsUnstable.legacyPackages.aarch64-darwin;
            aiTools = inputs.aiTools.packages.aarch64-darwin;
            sops-nix = inputs.sops-nix;
            private = inputs.private;
          };
      };
    };

    darwinConfigurations = {
      mbp = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./nixpkgs/darwin/mbp/configuration.nix
          inputs.sops-nix.darwinModules.sops
        ];
        inputs = { inherit darwin nixpkgs; };
        specialArgs = {
            inherit inputs;
            nix-homebrew = inputs.nix-homebrew;
            homebrew-core = inputs.homebrew-core;
            homebrew-cask = inputs.homebrew-cask;
            sops-nix = inputs.sops-nix;
            private = inputs.private;
          };
      };
    };
  };
}
