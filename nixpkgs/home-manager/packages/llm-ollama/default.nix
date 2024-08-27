{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage  rec {
  pname = "llm-ollama";
  version = "unstable";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "taketwo";
    repo = "llm-ollama";
    rev = "bb3e92b3b2c2a859f1aa4f8ef93bfc397e4a8633";
    hash = "sha256-QxmFgiy+Z5MNtnf2nvGndZk2MMuMhkOfofUsxCoh7J0=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    pydantic
  ];

  optional-dependencies = with python3.pkgs; {
    test = [
      pytest
    ];
  };

  dontCheckRuntimeDeps = true;

  meta = {
    description = "";
    homepage = "https://github.com/taketwo/llm-ollama";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "llm-ollama";
  };
}
