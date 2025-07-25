
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

  # fetch source
  src = builtins.fetchurl {
    url = "https://files.pythonhosted.org/packages/fb/76/e246c39d92929655bac8878d76406d6fb0293c678237e55621e7ece4a269/tflite_runtime-2.14.0-cp311-cp311-manylinux_2_34_armv7l.whl";
    sha256 = "c4e66a74165b18089c86788400af19fa551768ac782d231a9beae2f6434f7949";
  };

  build-system = [ setuptools wheel ];

  # PyPI dependencies
  propagatedBuildInputs = [
    pip
    setuptools
  ];
}
