final: prev:

let

  commonOverrides = pyfinal: pyprev: {
    #buildPythonPackage = args:
    #  pyprev.buildPythonPackage (args // { doCheck = false; doInstallCheck = false; });

    #buildPythonApplication = args:
    #  pyprev.buildPythonApplication (args // { doCheck = false; doInstallCheck = false; });

    mypy = pyprev.mypy.overridePythonAttrs (old: {
      env = (old.env or {}) // { MYPY_USE_MYPYC = "0"; };
    });

    charset-normalizer = pyprev.charset-normalizer.overridePythonAttrs (old: {
      env = (old.env or {}) // { CHARSET_NORMALIZER_USE_MYPYC = "0"; };
    });

    cryptography = pyprev.cryptography.overridePythonAttrs (old: {
      env = (old.env or {}) // { PYO3_USE_ABI3_FORWARD_COMPATIBILITY = true; };
    });

    # pr: jeepney seems not to declare their dependency on trio and outcome in their
    # top-level pyproject.toml, though they do declare the deps in the docs subdir.
    # subdirectory. upstream seems to be here.
    # upstream: https://gitlab.com/takluyver/jeepney
    jeepney = pyprev.jeepney.overridePythonAttrs (_old: {
      propagatedBuildInputs = with pyprev; [ trio outcome ];
    });

    # pr: lz4 uses the now removed _compression module in various places.
    # in python>=3.14, this has been moved to compression._common._streams
    # upstream: https://github.com/python-lz4/python-lz4
    lz4 = pyprev.lz4.overridePythonAttrs (old: {
      postPatch = ''
        sed -Ei "s@import _compression@import compression._common._streams as _compression@g" lz4/frame/__init__.py
      '';
    });

    parso = pyprev.parso.overridePythonAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "davidhalter";
        repo  = "parso";
        rev   = "a73af5c709a292cbb789bf6cab38b20559f166c0";
        hash  = "sha256-NNP/gKBA2tvCTV53k8VrnGEYruEsDSVqWVa7uU8Wznc=";
      };
      postPatch = (old.postPatch or "") + ''
        cp parso/python/grammar314.txt parso/python/grammar315.txt
      '';
    });
  };

  # ======================= Python 3.14 =======================
  python314 =
    prev.python314.override {
      packageOverrides = pyfinal: pyprev:
        (commonOverrides pyfinal pyprev) // {
          # put python314-specific attrset of packageOverrides here
        };

    };

  # ======================= Python 3.15 (HEAD-ish) =======================

  passthruFun = prev.callPackage
    (prev.path + "/pkgs/development/interpreters/python/passthrufun.nix")
    { };

  python315-base = prev.callPackage
    (prev.path + "/pkgs/development/interpreters/python/cpython")
    {
      self = final.python315;
      sourceVersion = { major = "3"; minor = "15"; patch = "0"; suffix = "a0"; };
      hash = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
      inherit passthruFun;
    };

  python315' = python315-base.overrideAttrs (old: {
    pname = "python3.15";
    version = "3.15.0a0";
    pythonVersion = "3.15";
    src = prev.fetchFromGitHub {
      owner = "python";
      repo  = "cpython";
      rev = "bb8791c0b75b5970d109e5557bfcca8a578a02af";
      hash = "sha256-ZRgkLnH8VUjqnYp1228QmudMNuKEQgGfK+FbB+H2xT0=";
    };

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
      packageOverrides = pyfinal: pyprev:
        (commonOverrides pyfinal pyprev) // {
          # put python315-specific attrset of packageOverrides here
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

