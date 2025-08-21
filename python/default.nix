# overlay: final = self, prev = super
final: prev:

let

  commonOverrides = selfP: superP: {
    buildPythonPackage = args:
      superP.buildPythonPackage (args // { doCheck = false; doInstallCheck = false; });

    buildPythonApplication = args:
      superP.buildPythonApplication (args // { doCheck = false; doInstallCheck = false; });

    mypy = superP.mypy.overridePythonAttrs (old: {
      env = (old.env or {}) // { MYPY_USE_MYPYC = "0"; };
    });

    charset-normalizer = superP.charset-normalizer.overridePythonAttrs (old: {
      env = (old.env or {}) // { CHARSET_NORMALIZER_USE_MYPYC = "0"; };
    });

    jeepney = superP.jeepney.overridePythonAttrs (_old: {
      propagatedBuildInputs = with superP; [ trio outcome ];
    });

    cryptography = superP.cryptography.overridePythonAttrs (old: {
      env = (old.env or {}) // { PYO3_USE_ABI3_FORWARD_COMPATIBILITY = true; };
    });

    lz4 = superP.lz4.overridePythonAttrs (_old: {
      postPatch = ''
        sed -Ei "s@import _compression@import compression._common._streams as _compression@g" lz4/frame/__init__.py
      '';
    });
  };

  # Shared newer parso source (used by BOTH 3.14 and 3.15)
  parsoSrc = prev.fetchFromGitHub {
    owner = "davidhalter";
    repo  = "parso";
    rev   = "a73af5c709a292cbb789bf6cab38b20559f166c0";
    hash  = "sha256-NNP/gKBA2tvCTV53k8VrnGEYruEsDSVqWVa7uU8Wznc=";
  };

  # ======================= Python 3.14 =======================
  python314 =
    prev.python314.override {
      packageOverrides = selfP: superP:
        (commonOverrides selfP superP) // {
          parso = superP.parso.overridePythonAttrs (_old: {
            src = parsoSrc;           # newer parso for 3.14
            # no grammar copy needed on 3.14
          });
        };
    };

  # ======================= Python 3.15 (HEAD-ish) =======================
  cpython315Src = prev.fetchFromGitHub {
    owner = "python";
    repo  = "cpython";
    rev   = "7fda8b66debb24e0520b94c3769b648c7305f84e";
    hash  = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
  };

  passthruFun = prev.callPackage
    (prev.path + "/pkgs/development/interpreters/python/passthrufun.nix")
    { };

  python315-base = prev.callPackage
    (prev.path + "/pkgs/development/interpreters/python/cpython")
    {
      self = final.python315;  # standard threading package set
      sourceVersion = { major = "3"; minor = "15"; patch = "0"; suffix = "a0"; };
      hash = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
      inherit passthruFun;
    };

  python315' = python315-base.overrideAttrs (old: {
    pname = "python3.15";
    version = "3.15.0a0";
    pythonVersion = "3.15";
    src = cpython315Src;

    patches = [];
    postPatch = "";

    # Remove the EXTERNALLY-MANAGED file (defensive)
    postInstall = (old.postInstall or "") + ''
      rm -f "$out/lib/python3."*/EXTERNALLY-MANAGED
    '';
    postFixup = (old.postFixup or "") + ''
      rm -f "$out/lib/python3."*/EXTERNALLY-MANAGED
    '';

    # Avoid building docs
    passthru = builtins.removeAttrs (old.passthru or {}) [ "doc" ];
  });

  python315 =
    (python315'.override {
      packageOverrides = selfP: superP:
        (commonOverrides selfP superP) // {
          parso = superP.parso.overridePythonAttrs (old: {
            src = parsoSrc;           # newer parso for 3.15
            postPatch = (old.postPatch or "") + ''
              cp parso/python/grammar314.txt parso/python/grammar315.txt
            '';
          });
        };
    });

in {
  # 3.14 exports
  python314 = python314;
  python314Packages = python314.pkgs;
  python314FreeThreading = python314.override {
    self = final.python314FreeThreading;
    pythonAttr = "python314FreeThreading";
    enableGIL = false;
  };

  # 3.15 exports
  python315 = python315;
  python315Packages = python315.pkgs;
  python315FreeThreading = python315.override {
    self = final.python315FreeThreading;
    pythonAttr = "python315FreeThreading";
    enableGIL = false;
  };
}

