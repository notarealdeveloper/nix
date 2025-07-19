{
  lib
, buildPythonPackage
, fetchPypi
, pip
, setuptools
, python
, pytest
, sentence-transformers
, is_instance
, assure
, mmry
, ...
} @ inputs:

buildPythonPackage rec {
  pname = "embd";
  version = "0.1.4";
  pyproject = true;
    
  # fetch source
  src = fetchPypi {
    inherit pname version;
    sha256 = "17c2042080a9f657220e0ffc7c83c62e17cd3dce4c093d82ae40543b925c38aa";
  };

  # PyPI dependencies

  # TODO: Learn how to express these range requirements
  #
  #  "is_instance >= 0.0.5",
  #  "assure >= 0.0.5",
  #  "mmry >= 0.0.5",

  propagatedBuildInputs = [
    pip
    setuptools
    pytest
    sentence-transformers
    is_instance
    assure
    mmry
  ];
}
