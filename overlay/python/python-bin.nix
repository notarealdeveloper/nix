
{ lib
, buildPythonPackage
, fetchPypi
, python-cowsay
, pip
, setuptools
, ... }:

buildPythonPackage rec {
  pname = "python-bin";
  version = "0.0.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "36b61ec88cd0f59dd740403fd6c5bb99ba1ca3cae4199d2c6af1b6fc535e8ef4";
  };

  propagatedBuildInputs = [
    pip
    setuptools
    python-cowsay
  ];

  meta = with lib; {
    description = "It's bin.";
    homepage    = "https://github.com/notarealdeveloper/python-bin";
    license     = licenses.bsd0;
    platforms   = platforms.unix;
  };
}
