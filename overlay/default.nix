# overlay.nix
final: prev: rec {

  sl2 = import ./bin/sl2.nix final prev;

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

    configureFlags = (old.configureFlags or []) ++ [
      "--with-openssl=${prev.openssl.dev}"
    ];

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

    #postInstall = "runHook postInstall";
    postInstall = "";

    propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [
      prev.openssl
    ];

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
