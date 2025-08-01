# weatherspect.nix
{ lib, stdenv, fetchFromGitHub, perl }:

let

  perlEnv = perl.withPackages (ps: with ps; [
    TermAnimation
    JSON
    LWP
  ]);

in

  stdenv.mkDerivation rec {

    pname = "weatherspect";
    version = "2.0";

    src = fetchFromGitHub {
      owner = "notarealdeveloper";
      repo = "weatherspect";
      rev = "136bb28bce77b06ca72e87cfba256066ac8fef4e";
      hash = "sha256-92bX+pRnzwgXoEEz4oRqcQDV+sP+ruCVZmzbagh9YLQ=";
    };

    propagatedBuildInputs = [
      perlEnv
    ];

    installPhase = ''
      install -Dm755 weatherspect $out/bin/weatherspect
    '';

    meta = with lib; {
      description = "Look at me. I am de maintainer now.";
      homepage    = "https://knowyourmeme.com/memes/look-at-me-im-the-captain-now";
      license     = licenses.gpl2;
      platforms   = platforms.unix;
    };

  }
