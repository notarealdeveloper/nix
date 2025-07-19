{ lib, python313Packages, fetchFromGitHub, buildEnv, callPackage, hello, ... }:

let
  jello_lib = python313Packages.buildPythonApplication rec {
    pname = "jello";
    version = "1.0";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "notarealdeveloper";
      repo = "jello";
      rev = "18d6bc75b6d16133ca8b5ebd3db486da36cbecc9";
      sha256 = "sha256-rnNoGpyab8bbaRA/QuZRIOolv+FTrCGf++IBayVQUMM=";
    };
    nativeBuildInputs = with python313Packages; [ pip setuptools ];
    propagatedBuildInputs = [ hello ];
  };
in
buildEnv {
  name = "jello";
  paths = [ jello_lib hello ];
}
