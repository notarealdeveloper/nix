{ lib , buildPythonPackage , fetchPypi , pip , setuptools , python , ... }:

buildPythonPackage rec {
  pname = "mmry";
  version = "0.0.9";
  pyproject = true;

  # fetch source
  src = fetchPypi {
    inherit pname version;
    sha256 = "4e43c9ea6ccd1c1a6ed4f91abc408ec753658eb32660d84a8785c3dd8cea0a4a";
  };

  # PyPI dependencies
  propagatedBuildInputs = [ pip setuptools ];
}
