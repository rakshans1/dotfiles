{
  description = "Home Manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =  inputs @ { self, nixpkgs, home-manager, nixpkgsUnstable, darwin, ... }: {

    homeConfigurations = {
      mbp = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./nixpkgs/home-manager/mac.nix ];
        extraSpecialArgs = { pkgsUnstable = inputs.nixpkgsUnstable.legacyPackages.aarch64-darwin; };
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
      };
    };
  };
}
