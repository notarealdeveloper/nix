{ lib, stdenv, fetchFromGitHub, perl }:

stdenv.mkDerivation rec {

  pname = "weatherspect";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "notarealdeveloper";
    repo = "weatherspect";
    rev = "f44d7e483d4a7a4c64411fe46ea39a67c7504002";
    hash = "sha256-3aZAoWBBOwRy8eBEIgX+UU7ji0QvEsBfIm1fkNJ3feQ=";
  };

  propagatedBuildInputs = [
    (perl.withPackages (ps: with ps; [
      TermAnimation
      JSON
      LWP
    ]))
  ];

  installPhase = ''
    install -Dm755 weatherspect $out/bin/weatherspect
  '';

  meta = with lib; {
    description = "Look at me. I am de maintainer now.";
    homepage    = "https://github.com/notarealdeveloper/weatherspect";
    license     = licenses.gpl2;
    platforms   = platforms.unix;
  };

}
