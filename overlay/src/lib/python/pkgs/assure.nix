{ lib , buildPythonPackage , fetchFromGitHub , setuptools , numpy ,  ... }:

buildPythonPackage rec {
  pname = "assure";
  version = "latest";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "notarealdeveloper";
    repo = "assure";
    rev = "06f06ba86493307f5bf88ee87a59f2ac523d03d1";
    hash = "sha256-2+8swEzpawC/CwuBTSCA0D1SaZ8J3e6iPVCzMJORA6s=";
  };

  build-system = [ setuptools ];
  propagatedBuildInputs = [ numpy ];
}
