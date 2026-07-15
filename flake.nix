{
  description = "Home Manager flake";

  inputs = {
    # Cooled NixOS 26.05 stable: 7-day cooldown buffer for supply-chain safety
    # https://determinate.systems/blog/nixpkgs-cooldown/
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-26.05-chilled/0.1";
    # Cooled nixpkgs-unstable: 7-day cooldown buffer for supply-chain safety
    # https://determinate.systems/blog/nixpkgs-cooldown/
    nixpkgsUnstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    ghostty.url = "github:ghostty-org/ghostty";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
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
      flake = false;
    };
    neovim = {
      url = "path:./config/rvim";
    };
    expert = {
      url = "github:elixir-lang/expert";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixpkgsUnstable,
      darwin,
      sops-nix,
      ...
    }:
    {

      homeConfigurations = {
        linux = home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./nixpkgs/home-manager/linux.nix ];
          extraSpecialArgs = {
            pkgsUnstable = import inputs.nixpkgsUnstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
            ghostty = inputs.ghostty.packages.x86_64-linux;
            sops-nix = inputs.sops-nix;
            private = inputs.private;
          };
        };
        mbp = home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
          modules = [ ./nixpkgs/home-manager/mac.nix ];
          extraSpecialArgs = {
            pkgsUnstable = import inputs.nixpkgsUnstable {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
            sops-nix = inputs.sops-nix;
            private = inputs.private;
            neovim = inputs.neovim;
            expert = inputs.expert.packages.aarch64-darwin;
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
            nix-homebrew = inputs.nix-homebrew;
            homebrew-core = inputs.homebrew-core;
            homebrew-cask = inputs.homebrew-cask;
            sops-nix = inputs.sops-nix;
            private = inputs.private;
            pkgsUnstable = import inputs.nixpkgsUnstable {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
          };
        };
      };
    };
}
