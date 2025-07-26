
{ lib
, buildPythonPackage
, fetchurl
, fetchPypi
, pip
, setuptools
, filetype
, pypandoc
, pypdf
, validators
, requests
, beautifulsoup4
, pytest
, pillow
, av
, transformers
, assure
, mmry
, ... }:

buildPythonPackage rec {
  pname = "kern";

  # fetch source tar.gz
  version = "0.0.14";
  pyproject = true;
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-za/vIs3HlJDojIQIBbxG4t8RWnvNEJliI84/l7G5vuc=";
  };

  # fetch wheel
  #version = "0.0.13";
  #format = "wheel";
  #src = fetchurl {
  #  url = "https://files.pythonhosted.org/packages/ad/33/5750d1e6e68cea51a481e1f89ae79a67435f779ac4c0d37451e77aad2788/kern-0.0.13-py3-none-any.whl";
  #  sha256 = "f31e02e5d79ae81a829c2c46bdef42ce72cf242c91455341f79ec8769355db8d";
  #};

  buildInputs = [
    pip
    setuptools
    pytest
  ];

  # PyPI dependencies
  propagatedBuildInputs = [
    filetype
    pypandoc
    pypdf
    validators
    requests
    beautifulsoup4
    pytest
    pillow
    av
    transformers
    assure
    mmry
  ];

  pythonRemoveDeps = [ "bs4" ];

}
