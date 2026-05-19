{ config, ... }:
{
  xdg.configFile."kanata/kanata.kbd".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/kanata/kanata.kbd";
}
