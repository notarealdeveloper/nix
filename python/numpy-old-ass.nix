pkgs: ps:

with ps;
buildPythonPackage {
  pname = "numpy";
  version = "1.26.4";
  src = pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-KgKrqe0S5KxOs+qUIcQgMBoMZGDZgw10qd+H76SRIBA=";
  };
}
