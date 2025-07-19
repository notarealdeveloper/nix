pkgs: pkgs.python313.withPackages (ps: with ps; [

  # basics
  ipython
  requests
  beautifulsoup4

  # gmail
  google-auth-oauthlib

  # getbtcprice
  google-api-python-client
  geoip2

])
