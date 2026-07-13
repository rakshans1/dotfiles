{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hashes;

  # Map nix system -> opencode platform-specific npm package name.
  platformMap = {
    aarch64-darwin = "opencode-darwin-arm64";
    x86_64-darwin = "opencode-darwin-x64";
    x86_64-linux = "opencode-linux-x64";
    aarch64-linux = "opencode-linux-arm64";
  };

  platform = stdenv.hostPlatform.system;
  npmPkg = platformMap.${platform} or (throw "Unsupported system: ${platform}");
in
stdenv.mkDerivation {
  pname = "opencode";
  inherit version;

  # The opencode-ai npm wrapper downloads a prebuilt, self-contained Bun
  # binary via a postinstall script (blocked in the Nix sandbox). Fetch the
  # platform-specific binary package directly instead.
  src = fetchzip {
    url = "https://registry.npmjs.org/${npmPkg}/-/${npmPkg}-${version}.tgz";
    hash = hashes.${platform};
  };

  # Bun-compiled ELF binaries need the dynamic loader patched in on Linux.
  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/opencode $out/bin/opencode
    runHook postInstall
  '';

  meta = {
    description = "The AI coding agent built for the terminal";
    homepage = "https://github.com/sst/opencode";
    changelog = "https://github.com/sst/opencode/releases";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "opencode";
    platforms = builtins.attrNames platformMap;
  };
}
