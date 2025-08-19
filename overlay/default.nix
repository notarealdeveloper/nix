# overlay.nix
final: prev: with prev; rec {

  ############################
  ### Existing Executables ###
  ############################

  sl2 = import ./bin/sl2.nix final prev;

  weatherspect = prev.callPackage ./ports/weatherspect.nix { };

  python-head = prev.callPackage ./ports/python-head.nix { };

  #########################
  ### Local Executables ###
  #########################

  hello = prev.callPackage ./bin/hello.nix { };

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

  bye = derivation {
    name = "bye";
    system = prev.system;
    builder = "${final.bash}/bin/bash";
    args = ["-c" ''
      ${final.coreutils}/bin/mkdir -pv $out
      ${final.coreutils}/bin/echo "Goodbye World, I'm moving to Nix!" > $out/file
    ''];
  };

  saybye = derivation {
    name = "saybye";
    system = prev.system;
    builder = "${prev.bash}/bin/bash";
    args = ["-c" ''
      ${final.coreutils}/bin/mkdir -pv $out/bin
      ${final.coreutils}/bin/printf "#!/bin/sh\n\n${final.coreutils}/bin/cat ${bye}/file" > $out/bin/saybye
      ${final.coreutils}/bin/chmod +x $out/bin/saybye
    ''];
  };
}
