{
  lib,
  python3,
  fetchFromGitHub,
  llm
}:

python3.pkgs.buildPythonPackage  rec {
  pname = "llm-mistral";
  version = "0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-mistral";
    rev = version;
    hash = "sha256-yVbbHi19EvDDQ0Pi17k0G1SC10EIkSvnNfxWyPTAWTA=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    httpx
    httpx-sse
    ollama
  ];

  optional-dependencies = with python3.pkgs; {
    test = [
      pytest
      pytest-httpx
    ];
  };

  dontCheckRuntimeDeps = true;

  meta = {
    description = "";
    homepage = "https://github.com/simonw/llm-mistral";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "llm-mistral";
  };
}
