final: prev:

let

  commonOverrides = pyfinal: pyprev: {

    buildPythonPackage = args:
      pyprev.buildPythonPackage (args // { doCheck = false; doInstallCheck = false; });

    buildPythonApplication = args:
      pyprev.buildPythonApplication (args // { doCheck = false; doInstallCheck = false; });

    cython = pyprev.cython.overrideAttrs (old: rec {
      version = "3.1.3";
      pyproject = true;
      src = prev.fetchFromGitHub {
        owner = "cython";
        repo = "cython";
        tag = version;
        hash = "sha256-9pnBkGz/QC8m8uPMziQWAvl9zEzuLn9naNDVFmFbJKA=";
      };
    });

    pandas = pyprev.pandas.overridePythonAttrs (old: rec {
      version = "2.3.2";
      pyproject = true;
      src = prev.fetchFromGitHub {
        owner = "pandas-dev";
        repo = "pandas";
        rev = "188b2dae7df85a9c9945db39c5a23d23b1d4ce2e";
        hash = "sha256-Q18XQjpK1O0DpKfrNxbd0iikWl2eIQdW/b+VNIXxlKE=";
      };
      env = (old.env or {}) // { VERSIONEER_OVERRIDE = version; };
      patches = [];
      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail "==" ">="

        # You don't need a dynamic version, asshole
        sed -i "/^dynamic.*/,/]/c\version = '${version}'" pyproject.toml

        echo "__version__ = '${version}'" > _version_meson.py

        # As soon as they mention this "versioneer" bullshit,
        # delete everything else in their pyproject.toml out of spite
        #sed -i "/tool.versioneer/,/\$\$/c/" pyproject.toml
        #cat pyproject.toml

        # Create a simpler generate_version.py, because their
        # dumb meson shit wants to call it
        #
        # This doesn't work for some reason
        # sed -i "s@^main[(][)]@@" generate_version.py
        # printf '\ndef main():\n    print("${version}")\n\nmain()\n' >> generate_version.py
        #
        # Ah, much better.
        #printf '#!${prev.python3}/bin/python\nprint("${version}")\n' > generate_version.py
        #chmod +x generate_version.py
        #cat generate_version.py
        #echo "HERE WE GO"
        #./generate_version.py
        #echo "LOOKS GOOD, BUILDING PANDAS"
      '';
    });

    seaborn = pyprev.seaborn.overridePythonAttrs (old: {
      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail "numpy>=1.20,!=1.24.0" "numpy" \
          --replace-fail "pandas>=1.2" "pandas" \
          --replace-fail "matplotlib>=3.4,!=3.6.1" "matplotlib" \
      '';
    });

    mypy = pyprev.mypy.overridePythonAttrs (old: {
      env = (old.env or {}) // { MYPY_USE_MYPYC = "0"; };
    });

    charset-normalizer = pyprev.charset-normalizer.overridePythonAttrs (old: {
      env = (old.env or {}) // { CHARSET_NORMALIZER_USE_MYPYC = "0"; };
    });

    # required by yt-dlp, even with tests disabled.
    cryptography = pyprev.cryptography.overridePythonAttrs (old: {
      env = (old.env or {}) // { PYO3_USE_ABI3_FORWARD_COMPATIBILITY = true; };
    });

    #bcrypt = pyprev.bcrypt.overridePythonAttrs (old: {
    #  env = (old.env or {}) // { PYO3_USE_ABI3_FORWARD_COMPATIBILITY = true; };
    #});

    # required by yt-dlp, even with tests disabled.
    #
    # pr: jeepney seems not to declare their dependency on trio and outcome in their
    # top-level pyproject.toml, though they do declare the deps in the docs subdir.
    # subdirectory. upstream seems to be here.
    # upstream: https://gitlab.com/takluyver/jeepney
    jeepney = pyprev.jeepney.overridePythonAttrs (_old: {
      propagatedBuildInputs = with pyprev; [ trio outcome ];
    });

    /*
    # pr: lz4 uses the now removed _compression module in various places.
    # in python>=3.14, this has been moved to compression._common._streams
    # the required patch should be something like this
    # upstream: https://github.com/python-lz4/python-lz4
    lz4 = pyprev.lz4.overridePythonAttrs (old: {
      postPatch = ''
        sed -Ei "s@(    )(import _compression)@\1import compression._common._streams as _compression@g" lz4/frame/__init__.py
      '';
    });
    */

    # pr: if sys.version_info > anything we currently recognize,
    # then use a file called grammarlatest.txt
    # upstream: https://github.com/davidhalter/parso
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
    
    ipython = pyprev.ipython.overridePythonAttrs (old: {

      src = prev.fetchFromGitHub {
        owner = "ipython";
        repo = "ipython";
        rev = "ad948680afaefee8cf530052807e2367db3826b3";
        hash = "sha256-ywi9dUDLikxPkBqYefslsEqJMK0/T5WxP6xycm7QXxg=";
      };

      /*
      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "tests/test_run.py" # only fails on free threading?
        "tests/test_oinspect.py"
        "tests/test_text.py"
        "tests/test_pretty.py"
        "tests/test_pycolorize.py"
        "tests/test_debugger.py"
        "tests/test_completer.py"
        "tests/test_interactiveshell.py"
        "tests/test_sysinfo.py"
        "IPython/utils/sysinfo.py"
        "IPython/extensions/tests/test_deduperreload.py"
      ];
    */
    });

  };

  freeThreadingOverrides = pyfinal: pyprev: {

  };

  # ======================= Python 3.13 =======================
  python313 =
    prev.python313.override {
      packageOverrides = pyfinal: pyprev:
        (commonOverrides pyfinal pyprev) // {
          # put python313-specific attrset of packageOverrides here
        };

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

  # 3.13 exports
  python313FreeThreading = python313.override {
    self = final.python313FreeThreading;
    pythonAttr = "python313FreeThreading";
    enableGIL = false;
    packageOverrides = pyfinal: pyprev:
      (commonOverrides pyfinal pyprev) //
      (freeThreadingOverrides pyfinal pyprev) //
      { };
  };

  # 3.14 exports
  python314 = python314;
  python314Packages = python314.pkgs;
  python314FreeThreading = python314.override {
    self = final.python314FreeThreading;
    pythonAttr = "python314FreeThreading";
    enableGIL = false;
    packageOverrides = pyfinal: pyprev:
      (commonOverrides pyfinal pyprev) //
      (freeThreadingOverrides pyfinal pyprev) //
      { };
  };

  # 3.15 exports
  python315 = python315;
  python315Packages = python315.pkgs;
  python315FreeThreading = python315.override {
    self = final.python315FreeThreading;
    pythonAttr = "python315FreeThreading";
    enableGIL = false;
    packageOverrides = pyfinal: pyprev:
      (commonOverrides pyfinal pyprev) //
      (freeThreadingOverrides pyfinal pyprev) //
      { };
  };
}

