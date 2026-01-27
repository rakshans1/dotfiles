{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  jq,
  pkg-config,
  ripgrep,
  libsecret,
}:

buildNpmPackage rec {
  pname = "gemini-cli";
  version = "0.25.2";

  nodejs = nodejs_22;

  src = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "v${version}";
    hash = "sha256-2Fl6bkoAgu+KvwVIkQEIAPYKQRYyEQPWMRv3vsfnNA4=";
  };

  npmDepsHash = "sha256-4peAAxCws5IjWaiNwkRBiaL+n1fE+zsK0qbk1owueeY=";

  nativeBuildInputs = [
    jq
    pkg-config
  ];
  buildInputs = [
    ripgrep
    libsecret
  ];

  # Remove node-pty dependency which causes build issues
  postPatch = ''
    ${jq}/bin/jq 'del(.optionalDependencies."node-pty")' package.json > package.json.tmp && mv package.json.tmp package.json
    ${jq}/bin/jq 'del(.optionalDependencies."node-pty")' packages/core/package.json > packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json
  '';

  dontNpmBuild = true;

  postInstall = ''
    # Remove workspace symlinks (they point to non-existent directories after bundle)
    rm -rf $out/lib/node_modules/@google/gemini-cli/node_modules/@google/gemini-cli
    rm -rf $out/lib/node_modules/@google/gemini-cli/node_modules/@google/gemini-cli-core
    rm -rf $out/lib/node_modules/@google/gemini-cli/node_modules/@google/gemini-cli-a2a-server
    rm -rf $out/lib/node_modules/@google/gemini-cli/node_modules/@google/gemini-cli-test-utils
    rm -rf $out/lib/node_modules/@google/gemini-cli/node_modules/gemini-cli-vscode-ide-companion

    # Remove broken symlinks in .bin directory
    rm -f $out/lib/node_modules/@google/gemini-cli/node_modules/.bin/gemini-cli-a2a-server

    # Wrap binary to include ripgrep in PATH
    wrapProgram $out/bin/gemini \
      --prefix PATH : ${lib.makeBinPath [ ripgrep ]}
  '';

  meta = {
    description = "AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = lib.licenses.asl20;
    mainProgram = "gemini";
    maintainers = [ ];
  };
}
