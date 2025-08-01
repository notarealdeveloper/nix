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
      repo  = "weatherspect";
      rev   = "c39bbae22feb240968a1b02b05ba019e6678a57c";
      hash  = "sha256-LwKn9FBuCND1QCCbXzf7MM6J4km7PrbyYBPN5iBRNpM=";
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
