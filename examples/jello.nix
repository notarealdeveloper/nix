{ pkgs, lib, python313Packages, fetchFromGitHub, hello }:

pkgs.buildPythonApplication rec {
  pname = "jello";
  version = "1.0";
  pyproject = true;
  src = fetchFromGitHub {
    owner = "notarealdeveloper";
    repo = "jello";
    rev = "18d6bc75b6d16133ca8b5ebd3db486da36cbecc9";
    sha256 = "sha256-rnNoGpyab8bbaRA/QuZRIOolv+FTrCGf++IBayVQUMM=";
  };

  propagatedBuildInputs = [ hello ];

  # Additional paths for wrapping the jello executable:
  makeWrapperArgs = [
    "--prefix" "PATH" ":" "${lib.makeBinPath [hello]}"
  ];
}
