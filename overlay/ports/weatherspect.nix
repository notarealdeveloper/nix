# weatherspect.nix
{ lib, stdenv, fetchFromGitHub, perl }:

  stdenv.mkDerivation rec {

    pname = "weatherspect";
    version = "2.0";

    src = fetchFromGitHub {
      owner = "notarealdeveloper";
      repo  = "weatherspect";
      rev   = version;
      hash  = "sha256-xqUJvRakUNlsKpeuB1DpH2cIA3W9EAeSL8Gygki7PAA=";
    };

    propagatedBuildInputs = [
      (perl.withPackages (ps: with ps; [
        TermAnimation
        LWP
        JSON
      ]))
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
