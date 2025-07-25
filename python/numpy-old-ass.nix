pkgs: ps:

ps.numpy.overridePythonAttrs (old: rec {
  version = "1.26.4";
  src = pkgs.fetchPypi {
    pname = "numpy";
    inherit version;
    sha256 = "sha256-KgKrqe0S5KxOs+qUIcQgMBoMZGDZgw10qd+H76SRIBA=";
  };
})
