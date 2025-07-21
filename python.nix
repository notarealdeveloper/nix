pkgs: pkgs.python313.withPackages (ps:

  let

    callable_module = ps.callPackage ./python/callable-module.nix {};
    is_instance     = ps.callPackage ./python/is-instance.nix { inherit callable_module; };
    assure          = ps.callPackage ./python/assure.nix {};
    mmry            = ps.callPackage ./python/mmry.nix {};
    embd            = ps.callPackage ./python/embd.nix { inherit is_instance assure mmry; };
    kern            = ps.callPackage ./python/kern.nix { inherit assure mmry; };
    wnix            = ps.callPackage ./python/wnix.nix { inherit assure mmry is_instance embd kern; };

    hello = pkgs.callPackage ./examples/hello {
      inherit (pkgs) stdenv fetchFromGitHub;
    };

    jello = ps.callPackage ./examples/jello {
      inherit (pkgs) lib fetchFromGitHub;
      inherit (ps) buildPythonPackage setuptools wheel;
      inherit hello;
    };

  in

    with ps; [

    # basics
    ipython
    requests
    beautifulsoup4
    yt-dlp  # note: cross language dependency on ffmpeg
    build
    twine
    pytest

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
    kern
    wnix

    # cross language dependencies
    jello

    auditwheel  # patchelf
    #cx-freeze   # patchelf
    #anytree     # graphviz -> should install .../bin/nop
    #dot2tex     # graphviz ...
    #gprof2dot   # graphviz ...
    #pycflow2dot # graphviz ...
    #pydeps      # graphviz ...
    #pydot       # graphviz ...
    #pygraphviz  # graphviz ...
    #xdot        # graphviz ...

  ])
