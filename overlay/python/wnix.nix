
{ lib
, buildPythonPackage
, fetchPypi
, pip
, setuptools
, pytest
, pandas
, is_instance
, assure
, mmry
, embd
, kern
, ... }:

buildPythonPackage rec {
  pname = "wnix";
  version = "0.0.20";
  pyproject = true;

  # fetch source
  src = fetchPypi {
    inherit pname version;
    sha256 = "c9ecb4e4d513dfd4877ff9e834c440d6553c9f01960c95acea7c3984738da1b4";
  };

  # PyPI dependencies
  propagatedBuildInputs = [
    pip
    setuptools
    pytest
    pandas
    is_instance
    assure
    mmry
    embd
    kern
  ];
}
