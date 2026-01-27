{
  description = "Neovim configuration using nixCats";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Pinned nixpkgs for marksman - workaround for Swift build failure
    # https://github.com/NixOS/nixpkgs/issues/483584
    nixpkgs-marksman.url = "github:nixos/nixpkgs/70801e06d9730c4f1704fbd3bbf5b8e11c03a2a7";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    plugins-lze = {
      url = "github:BirdeeHub/lze";
      flake = false;
    };
    plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      flake = false;
    };
    plugins-iceberg-nvim = {
      url = "github:oahlen/iceberg.nvim";
      flake = false;
    };
    plugins-incline-nvim = {
      url = "github:b0o/incline.nvim";
      flake = false;
    };
    plugins-possession-nvim = {
      url = "github:jedrzejboczar/possession.nvim";
      flake = false;
    };
    plugins-early-retirement-nvim = {
      url = "github:chrisgrieser/nvim-early-retirement";
      flake = false;
    };
    plugins-maximize-nvim = {
      url = "github:declancm/maximize.nvim";
      flake = false;
    };
    plugins-navigator-nvim = {
      url = "github:numToStr/Navigator.nvim";
      flake = false;
    };
    plugins-custom-theme-nvim = {
      url = "github:Djancyp/custom-theme.nvim";
      flake = false;
    };
    plugins-timber-nvim = {
      url = "github:Goose97/timber.nvim";
      flake = false;
    };
    plugins-snacks-nvim = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
    plugins-sidekick-nvim = {
      url = "github:folke/sidekick.nvim";
      flake = false;
    };
    plugins-octo-nvim = {
      url = "github:pwntester/octo.nvim";
      flake = false;
    };
    plugins-blink-cmp-git = {
      url = "github:Kaiser-Yang/blink-cmp-git";
      flake = false;
    };
    plugins-blink-cmp-fuzzy-path = {
      url = "github:newtoallofthis123/blink-cmp-fuzzy-path";
      flake = false;
    };
    plugins-copilot-lsp = {
      url = "github:copilotlsp-nvim/copilot-lsp";
      flake = false;
    };
  };

  # see :help nixCats.flake.outputs
  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (inputs.nixCats) utils;
      luaPath = ./.;
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
      extra_pkg_config = {
        allowUnfree = true;
      };
      # Capture pinned nixpkgs for marksman overlay (Swift build fix)
      # https://github.com/NixOS/nixpkgs/issues/483584
      nixpkgs-marksman = inputs.nixpkgs-marksman;
      dependencyOverlays =
        # (import ./overlays inputs) ++
        [
          (utils.standardPluginOverlay inputs)
          # Pin marksman to working nixpkgs (Swift build fix)
          (final: prev: {
            marksman =
              (import nixpkgs-marksman { system = prev.system; }).marksman;
          })
        ];
      categoryDefinitions = import ./categories.nix inputs;
      packageDefinitions = import ./packages.nix inputs;

      defaultPackageName = "rvim";
    in
    forEachSystem (
      system:
      let
        nixCatsBuilder = utils.baseBuilder luaPath {
          inherit
            nixpkgs
            system
            dependencyOverlays
            extra_pkg_config
            ;
        } categoryDefinitions packageDefinitions;
        defaultPackage = nixCatsBuilder defaultPackageName;

        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = utils.mkAllWithDefault defaultPackage;
        devShells = {
          default = pkgs.mkShell {
            name = defaultPackageName;
            packages = [ defaultPackage ];
            inputsFrom = [ ];
            shellHook = "";
          };
        };
      }
    )
    // (
      let
        nixosModule = utils.mkNixosModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
        homeModule = utils.mkHomeModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
      in
      {
        overlays = utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions defaultPackageName;

        nixosModules.default = nixosModule;
        homeModules.default = homeModule;

        inherit homeModule;
        inherit (utils) templates;
      }
    );
}
