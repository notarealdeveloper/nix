{
  lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, pytz
, ...
} @ inputs:

buildPythonPackage rec {
  pname = "tmstr";
  version = "0.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "notarealdeveloper";
    repo = "tmstr";
    rev = "9a8f97984cbad260374509bf8e40bffb41b20d0d";
    hash = "sha256-5WTTNXUqK/P4iqeHSBP4zBUEh91RSvPcUA54fCvnOnI=";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    pytz
  ];
}
