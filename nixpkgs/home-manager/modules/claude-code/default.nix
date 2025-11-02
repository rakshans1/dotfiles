{
  lib,
  buildNpmPackage,
  writableTmpDirAsHomeHook,
  fetchzip,
  nodejs_22,
}:
buildNpmPackage rec {
  pname = "claude-code";
  version = "2.0.31";

  nodejs = nodejs_22;

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-KQRc9h2DG1bwWvMR1EnMWi9qygPF0Fsr97+TyKef3NI=";
  };

  npmDepsHash = "sha256-mjX4ZN1DlG1tZuMdvDt1Yq4uxDTbhvbPwd4FCaLElQ4=";

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

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
  ];

  meta = {
    description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
    homepage = "https://github.com/anthropics/claude-code";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    maintainers = [ ];
  };
}
