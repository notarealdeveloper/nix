{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, pytest
, filetype
, pypandoc
, pypdf
, validators
, requests
, beautifulsoup4
, pillow
, av
, transformers
, assure
, mmry
, ... }:

buildPythonPackage rec {
  pname = "kern";
  version = "0.0.14";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-za/vIs3HlJDojIQIBbxG4t8RWnvNEJliI84/l7G5vuc=";
  };

  pythonRemoveDeps = [ "bs4" ];

  build-system = [ setuptools ];

  checkInputs = [ pytest ];

  propagatedBuildInputs = [
    filetype
    pypandoc
    pypdf
    validators
    requests
    beautifulsoup4
    pillow
    av
    transformers
    assure
    mmry
  ];

}
