{
  lib,
  buildNpmPackage,
  fetchzip,
  nodejs_22,
}:

buildNpmPackage rec {
  pname = "codex";
  version = "0.98.0";

  nodejs = nodejs_22;

  src = fetchzip {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}.tgz";
    hash = "sha256-YIQ+Q4eXwMOSUj3IQ8mSc9HgjZPkVPtUpnvjbnB0MSk=";
  };

  npmDepsHash = "sha256-iBj+PX+JG8VK9EBB3picoCvMQmpWBld/4F9r7SQsu9c=";
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
