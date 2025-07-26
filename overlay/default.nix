# overlay.nix
final: prev: rec {

  ############################
  ### Existing Executables ###
  ############################

  sl2 = import ./bin/sl2.nix final prev;

  python-head = import ./python/python-head.nix final prev; # work in progress

  #########################
  ### Local Executables ###
  #########################

  hello = import ./bin/hello.nix { inherit (prev) stdenv fetchFromGitHub; };

  yello = import ./bin/yello.nix prev prev.python3;

  ######################
  ### Python Overlay ###
  ######################

  pythonPackagesExtensions = [ (import ./python/extend.nix prev ) ];

}
