pkgs: python: python.withPackages (ps:

  with pkgs;

  let

    hello = import ./hello.nix { inherit stdenv fetchFromGitHub; };

    jello = (import ../python/jello.nix {
      inherit (pkgs) lib stdenv fetchFromGitHub;
      inherit (ps) buildPythonPackage setuptools wheel pip;
    });

  in

  stdenv.mkDerivation {
    pname = "yello";
    version = "1.0";

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${hello}/bin/hello $out/bin/hello
      ln -s ${jello}/bin/jello $out/bin/jello
    '';

    # runtime dependencies:
    buildInputs = [
      hello
      jello
    ];
  }
)
