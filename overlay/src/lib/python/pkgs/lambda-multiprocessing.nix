{ lib , buildPythonPackage , fetchPypi , setuptools , ...  }:

buildPythonPackage rec {
  pname = "lambda-multiprocessing";
  version = "1.1";
  pyproject = true;

  src = fetchPypi {
    pname = "lambda_multiprocessing";
    inherit version;
    sha256 = "1r23rgv5b6lzjim0bmxajcv3smx4j89bj85ds15mgq9fwgfc06qr";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [ ];
}
