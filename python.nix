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

  # This doesn't work
  # python313Packages.callPackage ./python/callable-module.nix {}

  # This doesn't work
  # callPackage ./python/callable-module.nix ps

  # This works
  # (pkgs.callPackage ./python/callable-module.nix ps)

  # This works too
  # (callPackage ./python/callable-module.nix ps)

  # This works!
  #(import ./python/callable-module.nix ps)

  # This works
  (ps.callPackage ./python/callable-module.nix {})

  # This doesn't work, because it needs to depend on
  # the output of the previous line. How to do that
  # in the most scalable elegant way that doesn't
  # require any hacks or kludges that will cause
  # problems down the road?
  (ps.callPackage ./python/is-instance.nix {})

])
