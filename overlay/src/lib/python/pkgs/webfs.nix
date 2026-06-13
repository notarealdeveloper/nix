{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, pytest
, requests
, colorama
, beautifulsoup4
, mmry
, ... }:

buildPythonPackage rec {
  pname = "webfs";
  version = "0.0.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-pA/2DILvbPYzUVxQnRRp/Cwj3RLPlTmffXcOuNz+5S8=";
  };

  pythonRemoveDeps = [ "bs4" ];

  build-system = [ setuptools ];

  checkInputs = [ pytest ];

  propagatedBuildInputs = [
    requests
    colorama
    beautifulsoup4
    mmry
  ];

}
