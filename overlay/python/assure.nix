{ lib , buildPythonPackage , fetchPypi , pip , setuptools , python , numpy ,  ... }:

buildPythonPackage rec {
  pname = "assure";
  version = "0.0.6";
  pyproject = true;

  # fetch source
  src = fetchPypi {
    inherit pname version;
    sha256 = "050d381e621d8b9250299631bcf8465a0103eeebe0642b1435cc26c214bda3c0";
  };

  # PyPI dependencies
  propagatedBuildInputs = [ pip setuptools numpy ];
}
