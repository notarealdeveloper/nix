pkgs: ps:

  let

    hello = (import ./hello.nix { inherit (pkgs) stdenv fetchFromGitHub; });
    jello = (import ../python/jello.nix {
      inherit (pkgs) lib stdenv fetchFromGitHub;
      inherit (ps) buildPythonPackage setuptools wheel;
    });
  in

  with pkgs;

  stdenv.mkDerivation {
    pname = "jello";
    version = "0.0.2";
    propagatedBuildInputs = [
      hello
      jello
    ];
    dontUnpack = true;
  }
