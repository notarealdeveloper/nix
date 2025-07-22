pkgs: pkgs.python313.withPackages (ps:

  let

    callable_module = ps.callPackage ./callable-module.nix {};
    is_instance     = ps.callPackage ./is-instance.nix { inherit callable_module; };
    assure          = ps.callPackage ./assure.nix {};
    mmry            = ps.callPackage ./mmry.nix {};
    embd            = ps.callPackage ./embd.nix { inherit is_instance assure mmry; };
    kern            = ps.callPackage ./kern.nix { inherit assure mmry; };
    wnix            = ps.callPackage ./wnix.nix { inherit assure mmry is_instance embd kern; };
    #jello           = ps.callPackage ./jello.nix { inherit pkgs ps; };

    jello = ps.callPackage ./jello.nix {
      inherit (pkgs) lib stdenv fetchFromGitHub;
      inherit (ps) buildPythonPackage setuptools wheel;
    };

  in

    with ps; [

    # basics
    ipython
    requests
    beautifulsoup4
    yt-dlp
    build
    twine
    pytest
    editdistance
    multiprocess

    # numerical
    numpy
    scipy
    pandas
    matplotlib
    seaborn
    scikit-learn
    torch

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
    kern
    wnix

    # import vs exec issue
    jello
  ]
)
