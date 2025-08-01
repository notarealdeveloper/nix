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
    hash  = "";
  };

  nativeBuildInputs = [
    (perl.withPackages (ps: with ps; [
      TermAnimation
    ]))
  ];

  installPhase = ''
  '';

  meta = with lib; {
    description = "I'm trying to get ascii weather";
    homepage    = "They all died long ago";
    license     = licenses.wtfpl;
    platforms   = platforms.unix;
  };
}

