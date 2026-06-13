{
  lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, pytest
, pandas
, sentence-transformers
, is-instance
, assure
, mmry
, ...
} @ inputs:

buildPythonPackage rec {
  pname = "embd";
  version = "0.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "notarealdeveloper";
    repo = "embd";
    tag = version;
    hash = "sha256-KCvt3DrqsjEl8cSra1x+ukr5F4oRMWOU2QOJLbRKkCk=";
  };

  build-system = [ setuptools ];

  checkInputs = [ pytest ];

  propagatedBuildInputs = [
    pandas
    sentence-transformers
    is-instance
    assure
    mmry
  ];
}
