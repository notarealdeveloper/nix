# overlay.nix
final: prev: with prev; rec {

  ############################
  ### Existing Executables ###
  ############################

  sl2 = prev.callPackage ./bin/sl2.nix { };

  weatherspect = prev.callPackage ./ports/weatherspect.nix { };

  python-head = prev.callPackage ./ports/python-head.nix { };

  # disable cuda deprecation warning during nix search
  cudaPackages = prev.cudaPackages // {
    cudaFlags = prev.cudaPackages.flags;
    cudaVersion = prev.cudaPackages.cudaMajorMinorVersion;
  };

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
