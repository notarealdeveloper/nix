
{
  lib
, buildPythonPackage
, fetchPypi
, pip
, setuptools
, wheel
, python
, ...
} @ inputs:

buildPythonPackage rec {
  pname = "tflite-runtime";
  version = "2.14.0";
  format = "wheel";

  src = builtins.fetchurl {
    url = "https://files.pythonhosted.org/packages/3a/d0/edc009c27b406c4f9cbc79274d6e46d634d139075492ad055e3d68445925/numpy-1.26.4-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
    sha256 = "666dbfb6ec68962c033a450943ded891bed2d54e6755e35e5835d63f4f6931d5";
  };

  build-system = [ setuptools wheel ];

  # PyPI dependencies
  propagatedBuildInputs = [
    pip
    setuptools
  ];
}
