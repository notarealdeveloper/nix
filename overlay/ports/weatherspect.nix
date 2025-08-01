{ lib, stdenv, fetchFromGitHub, perl }:

stdenv.mkDerivation rec {

  pname = "weatherspect";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "notarealdeveloper";
    repo = "weatherspect";
    rev = "54cf9e6a0c7eca95a307115da9afd3bc5dbf3daa";
    hash = "sha256-4iT0i4CnrVyBRhWUmpK+nPLGR9kXXqAr5V6JwPoAGCE=";
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
