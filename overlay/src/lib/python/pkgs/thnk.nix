{
  lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, pytest
, jax
, tmstr
, is-instance
, ...
} @ inputs:

buildPythonPackage rec {
  pname = "thnk";
  version = "0.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "notarealdeveloper";
    repo = "think";
    rev = "02aa4f318f27c655c900200d3f2e7ad9a5fa2cba";
    hash = "sha256-BOZMaxUrr0DWFiSPE5XVghFq7bF+ya4IAzizHxdbCz4=";
  };

  build-system = [ setuptools ];

  checkInputs = [ pytest ];

  propagatedBuildInputs = [
    jax
    tmstr
    is-instance
  ];
}
