# overlay.nix
final: prev: with prev; rec {

  ############################
  ### Existing Executables ###
  ############################

  sl2 = import ./bin/sl2.nix final prev;

  python-head = import ./python/python-head.nix final prev; # work in progress

  #########################
  ### Local Executables ###
  #########################

  hello = import ./bin/hello.nix { inherit (prev) stdenv fetchFromGitHub; };

  yello = import ./bin/yello.nix prev python3;

  ######################
  ### Python Overlay ###
  ######################

  pythonPackagesExtensions = [ (import ./python/extend.nix prev ) ];

  #######################
  ### Raw derivations ###
  #######################
  hi = stdenv.mkDerivation {
    name = "hi";
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -pv $out
      echo "Hello World!" > $out/file
    '';
  };

  sayhi = stdenv.mkDerivation {
    name = "sayhi";
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -pv $out/bin
      printf "#!/bin/sh\n\ncat ${hi}/file" > $out/bin/sayhi
      chmod +x $out/bin/sayhi
    '';
  };
}
