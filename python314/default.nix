# overlay: self = final, prev = super
self: prev:

let

  python314 = prev.python314.override {

    packageOverrides = selfP: superP: {

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

      parso = superP.parso.overridePythonAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "davidhalter";
          repo = "parso";
          rev = "a73af5c709a292cbb789bf6cab38b20559f166c0";
          hash = "sha256-NNP/gKBA2tvCTV53k8VrnGEYruEsDSVqWVa7uU8Wznc=";
        };
        postPatch = ''
          # cp parso/python/grammar314.txt parso/python/grammar315.txt
        '';
      });

      jeepney = superP.jeepney.overridePythonAttrs (old: {
        propagatedBuildInputs = with superP; [ trio outcome ];
      });

      cryptography = superP.cryptography.overridePythonAttrs (old: {
        env = (old.env or {}) // { PYO3_USE_ABI3_FORWARD_COMPATIBILITY = true; };
      });

      lz4 = superP.lz4.overridePythonAttrs (old: {
        postPatch = ''
          sed -Ei "s@import _compression@import compression@g" lz4/frame/__init__.py
          sed -Ei "s@_(compression[.])@\1@g" lz4/frame/__init__.py
        '';
      });
    };
  };

in {
  python314 = python314;
  python314Packages = python314.pkgs;
  python314FreeThreading = python314.override {
    self = self.python314FreeThreading;
    pythonAttr = "python314FreeThreading";
    enableGIL = false;
  };
}

