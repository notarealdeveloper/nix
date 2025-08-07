
{ lib
, buildPythonPackage
, fetchPypi
, ... }:

buildPythonPackage rec {
  pname = "python-cowsay";
  version = "1.2.1";
  pyproject = true;

  src = fetchPypi {
    pname = "python_cowsay";
    inherit version;
    sha256 = "e4d6ff9794cbf776129ffbef9addcda0021ad4e63b6cd8cbe9c12ea415311139";
  };

  propagatedBuildInputs = [
  ];
}
