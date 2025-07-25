# overlay.nix
final: prev: rec {

  sl2 = prev.sl.overrideAttrs (old: {
    pname = "sl2";
    installPhase = ''
      runHook preInstall

      mkdir -pv     $out/{bin,share/man/man1}
      mv -v sl      $out/bin/sl2
      mv -v sl.1    $out/share/man/man1/sl2.1

      runHook postInstall
    '';

    src = prev.fetchFromGitHub {
      owner = "mtoyoda";
      repo  = "sl";
      rev   = "923e7d7ebc5c1f009755bdeb789ac25658ccce03";
      sha256  = "173gxk0ymiw94glyjzjizp8bv8g72gwkjhacigd1an09jshdrjb4";
    };
  });


  python-head = prev.python314.overrideAttrs (old: rec {
    pname   = "python-head";
    sourceVersion = {
      major = "3";
      minor = "15";
      patch = "0";
      suffix = "a1";
    };
    version = "${sourceVersion.major}.${sourceVersion.minor}.${sourceVersion.patch}${sourceVersion.suffix}";
    pythonVersion = "${sourceVersion.major}.${sourceVersion.minor}";
    src = prev.fetchFromGitHub {
      owner = "python";
      repo  = "cpython";
      rev = "777159fa318f39c36ad60039cdf35a8dbb319637";
      hash  = "sha256-tXxYVCnwqp11PD5nQaLTHySVv0xf+4wuLN1eC4JiRBw=";
    };

    # make patchPhase a no-op
    patches = [];
    # nixpkgs python also sticks stuff here
    postPatch = "";
    patchPhase = ''
      runHook prePatch
      # nothing
      runHook postPatch
    '';

    doCheck = false;

    postInstall = "runHook postInstall";

  });

  #########################
  ### Local Executables ###
  #########################

  hello = (import ./bin/hello.nix { inherit (prev) stdenv fetchFromGitHub; });

  yello = (import ./bin/yello.nix prev prev.python3);

  ######################
  ### Python Overlay ###
  ######################

  # 1) Register your extension so *every* pythonXPackages set sees it.
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [ (import ./python/extend.nix prev) ];

  # 2) (Optional) Expose them at top-level too, like normal pkgs:
  inherit (final.python3Packages) callable_module is_instance assure mmry embd kern wnix jello;

}
