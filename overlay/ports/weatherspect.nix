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

    buildInputs = [
      (perl.withPackages (ps: with ps; [
        LWP
        TermAnimation
      ]))
    ];

    installPhase = ''
      mkdir -pv $out/bin

      # cuz fuck it, that's why
      chmod -v +x weatherspect

      # b/c idk what's in this shit, I'm just here
      mv -v weatherspect $out/bin

      rm -v *
      here="$PWD"
      cd ..
      rm -rfv "$here"
    '';

    meta = with lib; {
      description = "I'm trying to get ascii weather";
      homepage    = "They all died long ago";
      license     = licenses.wtfpl;
      platforms   = platforms.unix;
    };

  }

)
