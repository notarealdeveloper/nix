{ lib , buildPythonPackage , fetchPypi , setuptools , callable-module, ... }:

buildPythonPackage rec {
  pname = "is_instance";
  version = "0.0.16";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-IuUPSdIwxyBDcDNVoF99CISm7FvqkQq6bqMxHU3bryg=";
  };

  build-system = [ setuptools ];
  propagatedBuildInputs = [ callable-module ];
}
