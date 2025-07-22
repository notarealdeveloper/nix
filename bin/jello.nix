pkgs:

  let

    hello = (import ./hello.nix { inherit (pkgs) stdenv fetchFromGitHub; });
    jello = (import ../python/jello.nix pkgs);

  in

  with pkgs;

  stdenv.mkDerivation {
    pname = "jello";
    version = "0.0.2";
    propagatedBuildInputs = [
      hello
      python313Packages (ps: [ jello ps ])
    ];
    dontUnpack = true;
  }
