inputs:
let inherit (inputs.nixCats) utils;
in {
  rvim = { pkgs, name, ... }@misc: {
    settings = {
      suffix-path = true;
      suffix-LD = true;
      aliases = [ "vim" ];

      wrapRc = true;
      configDirName = "rvim";
      hosts.python3.enable = true;
      hosts.node.enable = true;
    };
    categories = {
      general = true;
      extra = true;
      gitPlugins = true;
    };
    extra = { nixdExtras = { nixpkgs = "import ${pkgs.path} {}"; }; };
  };
}
