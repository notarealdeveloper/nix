# overlay: self = final, prev = super
self: prev:

let

  # cpython upstream HEAD (or close to it)
  src = prev.fetchFromGitHub {
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
      self = self.python315;  # standard threading used by nixpkgs
      sourceVersion = { major = "3"; minor = "15"; patch = "0"; suffix = "a0"; };
      hash = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
      inherit passthruFun;
    };

  python315' = python315-base.overrideAttrs (old: {
    pname = "python3.15";
    version = "3.15.0a0";
    pythonVersion = "3.15";

    src = src;

    patches = [];
    postPatch = "";

    # Remove the EXTERNALLY-MANAGED file that breaks pip (it's still broken though)
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

  python315 = python315'.override {

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
          cp parso/python/grammar314.txt parso/python/grammar315.txt
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
          sed -i "s@import _compression@import compression@g" lz4/frame/__init__.py
        '';
      });
    };
  };

in {
  python315 = python315;
  python315Packages = python315.pkgs;
  python315FreeThreading = python315.override {
    self = self.python315FreeThreading;
    pythonAttr = "python315FreeThreading";
    enableGIL = false;
  };
}

