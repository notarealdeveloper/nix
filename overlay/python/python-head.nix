final: prev:

  prev.python314.overrideAttrs (old: rec {
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

    postInstall = "";

  });

