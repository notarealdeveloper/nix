# weatherspect.nix
pkgs: (with pkgs;

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

      echo "let's see what we've got"
      ls

      # cuz fuck it, that's why
      chmod -v +x *

      # b/c idk what's in this shit, I'm just here
      mv -v * $out/bin
    '';

    meta = with lib; {
      description = "I'm trying to get ascii weather";
      homepage    = "They all died long ago";
      license     = licenses.wtfpl;
      platforms   = platforms.unix;
    };

  }

)
