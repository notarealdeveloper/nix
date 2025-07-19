{ fetchFromGitHub , hello , ... } @ pkgs:

buildPythonPackage rec {
  pname = "jello";
  version = "1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "notarealdeveloper";
    repo = "jello";
    rev = "18d6bc75b6d16133ca8b5ebd3db486da36cbecc9";
    sha256 = "sha256-rnNoGpyab8bbaRA/QuZRIOolv+FTrCGf++IBayVQUMM=";
  };

  nativeBuildInputs = [
    hello
  ];

  propagatedBuildInputs = [
  ];

  # Ensure hello binary is in PATH for tests during build, if any
  shellHook = "export PATH=${hello}/bin:$PATH";
}
