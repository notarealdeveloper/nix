pkgs: pkgs.python313.withPackages (ps:

  let

    callable_module = ps.callPackage ./python/callable-module.nix {};
    is_instance     = ps.callPackage ./python/is-instance.nix { inherit callable_module; };
    assure          = ps.callPackage ./python/assure.nix {};
    mmry            = ps.callPackage ./python/mmry.nix {};
    embd            = ps.callPackage ./python/embd.nix { inherit is_instance assure mmry; };

    hello = pkgs.callPackage ./examples/hello {
      inherit (pkgs) stdenv fetchFromGitHub;
    };

    jello = ps.callPackage ./examples/jello {
      inherit (pkgs) lib fetchFromGitHub hello;
      inherit (ps) buildPythonPackage setuptools wheel;
    };

  in

    with ps; [

    # basics
    ipython
    requests
    beautifulsoup4

    # numerical
    numpy
    scipy
    pandas
    matplotlib
    seaborn

    # gmail
    google-auth-oauthlib

    # getbtcprice
    google-api-python-client
    geoip2

    # external
    callable_module
    is_instance
    assure
    mmry
    embd

    # cross-language dependency example
    jello

  ])
