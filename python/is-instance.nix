{ lib , buildPythonPackage , fetchPypi , pip , setuptools , python , callable_module, ... }:

buildPythonPackage rec {
  pname = "is_instance";
  version = "0.0.12";
  pyproject = true;

  # fetch source
  src = fetchPypi {
    inherit pname version;
    sha256 = "e7224eba995d6ffa6a3025ca8ac77d482538b7a37b9381ff1922ab98c42f9f55";
  };

  # PyPI dependencies
  propagatedBuildInputs = [ pip setuptools callable_module ];
}
