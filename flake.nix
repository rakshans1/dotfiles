{
  description = "Home Manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    homebrew-pomerium = {
      url = "github:pomerium/homebrew-tap";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nixpkgsUnstable, darwin, ... }: {

    homeConfigurations = {
      linux = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./nixpkgs/home-manager/linux.nix ];
        extraSpecialArgs = { pkgsUnstable = inputs.nixpkgsUnstable.legacyPackages.x86_64-linux; };
      };
      mbp = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./nixpkgs/home-manager/mac.nix ];
        extraSpecialArgs = { pkgsUnstable = inputs.nixpkgsUnstable.legacyPackages.aarch64-darwin; };
      };
      mbpi = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-darwin;
        modules = [ ./nixpkgs/home-manager/maci.nix ];
        extraSpecialArgs = { pkgsUnstable = inputs.nixpkgsUnstable.legacyPackages.x86_64-darwin; };
      };
    };

    darwinConfigurations = {
      # nix build .#darwinConfigurations.mbp2021.system
      # ./result/sw/bin/darwin-rebuild switch --flake .
      mbp = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./nixpkgs/darwin/mbp/configuration.nix
        ];
        inputs = { inherit darwin nixpkgs; };
        specialArgs = {
          inherit inputs;
          nix-homebrew = inputs.nix-homebrew;
          homebrew-core = inputs.homebrew-core;
          homebrew-cask = inputs.homebrew-cask;
          homebrew-pomerium = inputs.homebrew-pomerium;
        };
      };
    };
  };
}
