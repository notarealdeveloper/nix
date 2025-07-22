pkgs:

  let

    hello = (import ./hello.nix { inherit (pkgs) stdenv fetchFromGitHub; });
    jello = with pkgs; (import ../python/jello.nix pkgs python313Packages);

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
