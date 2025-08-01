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
      owner   = "notarealdeveloper";
      repo    = "weatherspect";
      rev     = "0143c4aa9a71f020dd073e10939c9e8242a11403";
      sha256  = "sha256-rTZTNcnehL6PR5VagCMTs1MnRCap/XXjxQMSZyBMiuE=";
    };

    propagatedBuildInputs = [
      perlEnv
    ];

    installPhase = ''
      mkdir -pv $out/bin
      chmod -v +x weatherspect
      cp -v weatherspect $out/bin
    '';

    meta = with lib; {
      description = "Look at me. I am de maintainer now.";
      homepage    = "https://knowyourmeme.com/memes/look-at-me-im-the-captain-now";
      license     = licenses.gpl2;
      platforms   = platforms.unix;
    };

  }
