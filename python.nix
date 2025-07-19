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

])
