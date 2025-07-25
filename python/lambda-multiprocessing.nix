{
  lib
, buildPythonPackage
, fetchPypi
, pip
, setuptools
, python
, ...
} @ inputs:

buildPythonPackage rec {
  pname = "lambda-multiprocessing";
  version = "1.1";
  pyproject = true;

  # fetch source
  src = builtins.fetchTarball {
    #inherit pname version;
    url = "https://files.pythonhosted.org/packages/d7/62/3e68a9ae84f9e0a50adf78e37336906cd30b8115d9f5609e31a058b6760e/lambda_multiprocessing-1.1.tar.gz";
    sha256 = "1r23rgv5b6lzjim0bmxajcv3smx4j89bj85ds15mgq9fwgfc06qr";
  };

  build-system = [ setuptools ];

  # PyPI dependencies
  propagatedBuildInputs = [
    pip
    setuptools
  ];
}
