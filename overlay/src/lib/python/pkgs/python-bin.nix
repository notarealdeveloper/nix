{ lib , buildPythonPackage , fetchPypi , setuptools , ... }:

buildPythonPackage rec {
  pname = "python_bin";
  version = "0.0.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Z8YZGqe9XjO7pvRNa7564sC59iN1Wj4GWUNEHOcKW/Y=";
  };

  build-system = [ setuptools ];
  propagatedBuildInputs = [ ];

  meta = with lib; {
    description = "It's bin.";
    homepage    = "https://github.com/notarealdeveloper/python-bin";
    license     = licenses.bsd0;
    platforms   = platforms.unix;
  };
}
