pkgs: python:

python.buildPythonPackage {
  pname = "numpy";
  version = "1.26.4";
  src = pkgs.fetchPypi {
    inherit pname;
    sha256 = "666dbfb6ec68962c033a450943ded891bed2d54e6755e35e5835d63f4f6931d5";
  };
}
