{ lib , buildPythonPackage , fetchPypi , pip , setuptools , python , ... }:

buildPythonPackage rec {
  pname = "callable_module";
  version = "0.0.1";
  pyproject = true;

  # fetch source
  src = fetchPypi {
    inherit pname version;
    sha256 = "8fe5bcefaa65f986b63b499c8047159307496c4f0d6b812bd654c9697e25541c";
  };

  # PyPI dependencies
  propagatedBuildInputs = [ pip setuptools ];
}
