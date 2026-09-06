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

  # Caddy with Cloudflare DNS plugin for Let's Encrypt DNS-01 on private hosts
  # (e.g. Tailscale-only m.rakshanshetty.in — no public HTTP challenge).
  caddyPkg = pkgs.caddy.withPlugins {
    # v0.2.4+ accepts new Cloudflare token prefixes (cfat_/cfut_)
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
    hash = "sha256-pRrLBlYRaAyMYwPXeTy4WqWNRu/L9K6Mn2src11dGh8=";
  };

  # Launchd cannot load env from files; export the SOPS token then exec Caddy.
  caddyRun = pkgs.writeShellScript "caddy-run" ''
    set -euo pipefail
    token_file="${config.sops.secrets.cloudflare_caddy_dns_token.path}"
    if [[ -f "$token_file" ]]; then
      # Scoped to Caddy ACME DNS-01 — not a generic Cloudflare token env name.
      export CLOUDFLARE_CADDY_DNS_TOKEN="$(cat "$token_file")"
    fi
    exec ${caddyPkg}/bin/caddy run --config ${lib.escapeShellArg caddyConfig}
  '';
in
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = [ caddyPkg ];

    home.activation.caddyLogDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${lib.escapeShellArg logDir}
    '';

    launchd.agents.caddy = {
      enable = true;
      config = {
        Label = "com.rakshan.caddy";
        ProgramArguments = [ "${caddyRun}" ];
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
