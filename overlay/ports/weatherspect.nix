# weatherspect.nix
{ lib
, fetchFromGitHub
, perl
}:

stdenv.mkDerivation rec {

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
      TermAnimation
    ]))
  ];

  installPhase = ''
    mkdir -pv $out/bin
    mv -v * $out/bin    # b/c idk what's in this shit, I'm just here
  '';

  meta = with lib; {
    description = "I'm trying to get ascii weather";
    homepage    = "They all died long ago";
    license     = licenses.wtfpl;
    platforms   = platforms.unix;
  };

}

