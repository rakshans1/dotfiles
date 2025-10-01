{
  config,
  pkgs,
  neovim,
  ...
}:

{
  imports = [ neovim.homeModules.default ];

  rvim = {
    enable = true;
  };
}
