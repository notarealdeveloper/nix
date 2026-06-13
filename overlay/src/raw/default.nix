#######################
### Raw derivations ###
#######################

final: prev:

with prev;

rec {

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
    builder = "${prev.bash}/bin/bash";
    args = ["-c" ''
      export PATH="${prev.coreutils}/bin:$PATH"
      mkdir -pv $out
      echo "Goodbye World, I'm moving to Nix!" > $out/file
    ''];
  };

  saybye = derivation {
    name = "saybye";
    system = prev.system;
    builder = "${prev.bash}/bin/bash";
    args = ["-c" ''
      export PATH="${prev.coreutils}/bin:$PATH"
      mkdir -pv $out/bin
      cat > $out/bin/saybye << EOF
      #!/bin/sh
      cat "${bye}/file"
      EOF
      chmod +x $out/bin/saybye
    ''];
  };

}
