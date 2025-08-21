# overlay: final = self, prev = super
final: prev:

let
  # ---- common packageOverrides used by both 3.14 and 3.15 ----
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

    parso = superP.parso.overridePythonAttrs (_old: {
      src = prev.fetchFromGitHub {
        owner = "davidhalter";
        repo = "parso";
        rev = "a73af5c709a292cbb789bf6cab38b20559f166c0";
        hash = "sha256-NNP/gKBA2tvCTV53k8VrnGEYruEsDSVqWVa7uU8Wznc=";
      };
      # no postPatch here; 3.15 adds grammar copy below
    });

    jeepney = superP.jeepney.overridePythonAttrs (_old: {
      propagatedBuildInputs = with superP; [ trio outcome ];
    });

    cryptography = superP.cryptography.overridePythonAttrs (old: {
      env = (old.env or {}) // { PYO3_USE_ABI3_FORWARD_COMPATIBILITY = true; };
    });

    lz4 = superP.lz4.overridePythonAttrs (_old: {
      postPatch = ''
        sed -Ei "s@import _compression@import compression@g" lz4/frame/__init__.py
        sed -Ei "s@_(compression[.])@\1@g" lz4/frame/__init__.py
      '';
    });
  };

  # ======================= Python 3.14 =======================
  python314 =
    prev.python314.override {
      packageOverrides = selfP: superP:
        (commonOverrides selfP superP);
    };

  # ======================= Python 3.15 (HEAD-ish) =======================
  # cpython upstream HEAD (or close to it)
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
      self = final.python315;  # standard threading used by nixpkgs
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

    # Remove the EXTERNALLY-MANAGED file that breaks pip (defensive)
    postInstall = (old.postInstall or "") + ''
      rm -f "$out/lib/python3.15/EXTERNALLY-MANAGED" 2>/dev/null || true
      rm -f "$out/lib/python3."*/EXTERNALLY-MANAGED 2>/dev/null || true
    '';
    postFixup = (old.postFixup or "") + ''
      rm -f "$out/lib/python3.15/EXTERNALLY-MANAGED" 2>/dev/null || true
      rm -f "$out/lib/python3."*/EXTERNALLY-MANAGED 2>/dev/null || true
    '';

    # Don't let the docs drag us down
    passthru = builtins.removeAttrs (old.passthru or {}) [ "doc" ];
  });

  python315 =
    (python315'.override {
      packageOverrides = selfP: superP:
        (commonOverrides selfP superP) // {
          # Only for 3.15: make a grammar315.txt until upstream releases it
          parso = superP.parso.overridePythonAttrs (old: {
            inherit (old) src;
            postPatch = (old.postPatch or "") + ''
              cp parso/python/grammar314.txt parso/python/grammar315.txt
            '';
          });
        };
    });

in {
  # 3.14
  python314 = python314;
  python314Packages = python314.pkgs;
  python314FreeThreading = python314.override {
    self = final.python314FreeThreading;
    pythonAttr = "python314FreeThreading";
    enableGIL = false;
  };

  # 3.15
  python315 = python315;
  python315Packages = python315.pkgs;
  python315FreeThreading = python315.override {
    self = final.python315FreeThreading;
    pythonAttr = "python315FreeThreading";
    enableGIL = false;
  };
}

