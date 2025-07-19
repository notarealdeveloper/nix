pkgs: pkgs.python313.withPackages (ps: with ps; [

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

  # These all work:
  #
  # (pkgs.callPackage ./python/callable-module.nix ps)
  #
  # (callPackage ./python/callable-module.nix ps)
  #
  # (import ./python/callable-module.nix ps)

  # This works
  (ps.callPackage ./python/callable-module.nix {})

  # This works, but it's clear we're doing something
  # stupid here. How can we make this more elegant?
  (ps.callPackage ./python/is-instance.nix { callable_module = (ps.callPackage ./python/callable-module.nix {}); })

])
