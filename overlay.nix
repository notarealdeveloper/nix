# overlay.nix
final: prev: rec {

  sl2 = prev.sl.overrideAttrs (_: {
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

  #########################
  ### Local Executables ###
  #########################

  hello = (import ./bin/hello.nix { inherit (final) stdenv fetchFromGitHub; });

  yello = (import ./bin/yello.nix final final.python3);

  ######################
  ### Python Overlay ###
  ######################

  # 1) Register your extension so *every* pythonXPackages set sees it.
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [ (import ./python/extend.nix { inherit (prev) fetchFromGitHub; }) ];

  # 2) (Optional) Expose them at top-level too, like normal pkgs:
  inherit (final.python3Packages) callable_module is_instance assure mmry embd kern wnix jello;

}
