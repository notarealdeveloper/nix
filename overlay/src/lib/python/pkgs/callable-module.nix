{ lib , buildPythonPackage , fetchPypi , setuptools , ... }:

buildPythonPackage rec {
  pname = "callable_module";
  version = "0.0.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-s/hclZHslyzngQJWMt8KLglh8J4chsTusA4xqlyUOC0=";
  };

  build-system = [ setuptools ];
  propagatedBuildInputs = [ ];
}
