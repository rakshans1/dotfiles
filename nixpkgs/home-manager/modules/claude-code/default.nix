{
  lib,
  buildNpmPackage,
  fetchzip,
  nodejs_22,
}:
buildNpmPackage rec {
  pname = "claude-code";
  version = "2.0.9";

  nodejs = nodejs_22;

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-eBhg8RCATVIgC5Dex+cTnLDzLKfnJI8M7eOSGDE4bAw=";
  };

  npmDepsHash = "sha256-6WSPAPPpFJagF8J3gaXZdpm4RtH9k6lCe16bWarUjtk=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  AUTHORIZED = "1";

  # Disable auto-updates during installation
  postInstall = ''
    wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1 \
      --unset DEV
  '';

  meta = {
    description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
    homepage = "https://github.com/anthropics/claude-code";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    maintainers = [ ];
  };
}
