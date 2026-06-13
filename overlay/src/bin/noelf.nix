{ lib
, stdenv
, fetchFromGitHub
, nasm
, gnumake
}:

stdenv.mkDerivation {

  pname = "noelf";

  version = "latest";

  src = fetchFromGitHub {
    owner = "hello-corporation";
    repo = "noelf";
    rev = "42d3b79ca9d97904410226eae31ca511178b337b";
    hash = "sha256-JrMa5kKPZvzlAsXP4X9eb52VYUNYTIT3BjStPIP3Oog=";
  };

  nativeBuildInputs = [ nasm gnumake ];

  buildPhase = ''
    make
  '';
  
  installPhase = ''
    mkdir -pv $out/bin

    cp -v bin/LD        $out/bin/LD
    cp -v bin/mkdir.bin $out/bin/mkdir.bin
    cp -v bin/rmdir.bin $out/bin/rmdir.bin

    cat > $out/bin/LD-mkdir << EOF
    #!/usr/bin/env bash
    $out/bin/LD $out/bin/mkdir.bin
    EOF

    cat > $out/bin/LD-rmdir << EOF
    #!/usr/bin/env bash
    $out/bin/LD $out/bin/rmdir.bin
    EOF

    chmod +x $out/bin/LD-mkdir
    chmod +x $out/bin/LD-rmdir
  '';

  meta = with lib; {
    description = "A ld for raw machine code, just like the L||D intended";
    platforms = platforms.linux;
  };
}
