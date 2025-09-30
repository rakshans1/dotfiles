{ lib
, buildNpmPackage
, fetchzip
, nodejs_22
}:

buildNpmPackage rec {
  pname = "codex";
  version = "0.42.0";

  nodejs = nodejs_22;

  src = fetchzip {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}.tgz";
    hash = "sha256-QICOcndHwZ7AjwPka8HgsoeO42SA70ZD7nSF5uIqPp4=";
  };

  npmDepsHash = "sha256-SH25yKhdg+5A2Ims9sP7fAw7M7wxctxJIdrySxKMS6w=";
  makeCacheWritable = true;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/node_modules/@openai/codex
    cp -r . $out/lib/node_modules/@openai/codex/

    # Create symlink for the binary
    ln -s $out/lib/node_modules/@openai/codex/bin/codex.js $out/bin/codex
    chmod +x $out/bin/codex

    runHook postInstall
  '';

  meta = {
    description = "OpenAI Codex CLI tool";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.mit;
    mainProgram = "codex";
    maintainers = [ ];
  };
}