{
  lib,
  stdenv,
  fetchurl,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version platforms;

  platform = stdenv.hostPlatform.system;
  release = platforms.${platform} or (throw "Unsupported system: ${platform}");
in
stdenv.mkDerivation {
  pname = "antigravity-cli";
  inherit version;

  src = fetchurl {
    inherit (release) url hash;
  };

  sourceRoot = ".";

  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 antigravity $out/bin/agy
    runHook postInstall
  '';

  meta = {
    description = "Antigravity CLI - Google's agentic coding tool for the terminal";
    homepage = "https://antigravity.google/product/antigravity-cli/";
    changelog = "https://antigravity.google/docs/cli";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "agy";
    platforms = [ "aarch64-darwin" ];
  };
}
