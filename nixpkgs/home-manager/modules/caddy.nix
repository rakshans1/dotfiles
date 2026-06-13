{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  caddyDir = "${home}/dotfiles/private/caddy";
  caddyConfig = "${caddyDir}/Caddyfile";
  logDir = "${home}/Library/Logs/caddy";
in
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.activation.caddyLogDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${lib.escapeShellArg logDir}
    '';

    launchd.agents.caddy = {
      enable = true;
      config = {
        Label = "com.rakshan.caddy";
        ProgramArguments = [
          "${pkgs.caddy}/bin/caddy"
          "run"
          "--config"
          caddyConfig
        ];
        WorkingDirectory = caddyDir;
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${logDir}/caddy.out.log";
        StandardErrorPath = "${logDir}/caddy.err.log";
        EnvironmentVariables = {
          HOME = home;
          XDG_CONFIG_HOME = "${home}/.config";
          XDG_DATA_HOME = "${home}/.local/share";
        };
      };
    };
  };
}
