
{ lib
, buildPythonPackage
, fetchPypi
, python-cowsay
, pip
, setuptools
, ... }:

buildPythonPackage rec {
  pname = "python-bin";
  version = "0.0.2";
  pyproject = true;

  src = fetchPypi {
    pname = "python_bin";
    inherit version;
    sha256 = "ae6a69025b600844cf0c30eda9ec2eb2797387a6a74a46ce9c1a51c7ddcd6b6b";
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
