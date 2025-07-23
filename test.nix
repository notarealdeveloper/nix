pkgs: python: python.withPackages (ps:

  let

    jello = ps.callPackage ./python/jello.nix {
      inherit (pkgs) lib stdenv fetchFromGitHub;
      inherit (ps) buildPythonPackage setuptools wheel;
    };

  in

    with ps; [

    ipython
    jello

  ])
