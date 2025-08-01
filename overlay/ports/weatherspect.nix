# weatherspect.nix
{ lib
, stdenvNoCC
, fetchFromGitHub
, perl
}:

stdenvNoCC.mkDerivation rec {
  pname = "weatherspect";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "AnotherFoxGuy";
    repo  = "weatherspect";
    rev   = version;
    hash  = "sha256-rTZTNcnehL6PR5VagCMTs1MnRCap/XXjxQMSZyBMiuE=";
  };

  nativeBuildInputs = [
    (perl.withPackages (ps: with ps; [
      JSON
      TermAnimation
      LWP
    ]))
  ];

  installPhase = ''
    install -Dm755 weatherspect $out/bin/weatherspect
    patchShebangs $out/bin
  '';

  meta = with lib; {
    description = "A virtual weather environment in ASCII";
    homepage    = "https://github.com/AnotherFoxGuy/weatherspect";
    license     = licenses.gpl2Only;
    platforms   = platforms.unix;
  };
}

