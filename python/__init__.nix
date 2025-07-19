pkgs: pkgs.python313.withPackages (ps:

  let

    callable_module = ps.callPackage ./callable-module.nix {};
    is_instance     = ps.callPackage ./is-instance.nix { inherit callable_module; };
    assure          = ps.callPackage ./assure.nix {};
    mmry            = ps.callPackage ./mmry.nix {};
    embd            = ps.callPackage ./embd.nix { inherit is_instance assure mmry; };

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

  ])
