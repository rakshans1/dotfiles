{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hashes;

  platformMap = {
    aarch64-darwin = "macos-aarch64";
  };

  platform = stdenv.hostPlatform.system;
  platformSuffix = platformMap.${platform} or (throw "Unsupported system: ${platform}");
in
stdenv.mkDerivation {
  pname = "grok";
  inherit version;

  src = fetchurl {
    url = "https://storage.googleapis.com/grok-build-public-artifacts/cli/grok-${version}-${platformSuffix}";
    hash = hashes.${platform};
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/grok
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/grok \
      --set GROK_DISABLE_AUTOUPDATER 1 \
      --set GROK_AUTO_UPDATE false \
      --set GROK_TELEMETRY_ENABLED false
  '';

  meta = {
    description = "Grok CLI - xAI's agentic coding tool for the terminal";
    homepage = "https://x.ai/cli";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "grok";
    platforms = [ "aarch64-darwin" ];
  };
}
