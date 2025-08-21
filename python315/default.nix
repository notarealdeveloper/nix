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

  # cpython helper expected by the builder (note: passthrufun.nix)
  passthruFun = prev.callPackage
    (prev.path + "/pkgs/development/interpreters/python/passthrufun.nix")
    { };

  python315-src = prev.callPackage
    (prev.path + "/pkgs/development/interpreters/python/cpython")
    {
      self = self.python315;
      sourceVersion = { major = "3"; minor = "15"; patch = "0"; suffix = "a0"; };
      hash = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
      inherit passthruFun;
    };

  python315-build = python315-src.overrideAttrs (old: {
    pname = "python3.15";
    version = "3.15.0a0";
    pythonVersion = "3.15";

    src = src;

    # The cpython patches don't apply cleanly on HEAD, skip 'em
    patches = [];
    postPatch = "";

    # Remove the EXTERNALLY-MANAGED file
    postInstall = (old.postInstall or "") + ''
      rm -f "$out/lib/python3.15/EXTERNALLY-MANAGED"
    '';
    postFixup = (old.postFixup or "") + ''
      rm -f "$out/lib/python3.15/EXTERNALLY-MANAGED"
    '';

    # Drop doc passthru so nothing drags Sphinx/docs
    passthru = builtins.removeAttrs (old.passthru or {}) [ "doc" ];
  });

  python315 = python315-build.override {
    packageOverrides = selfP: superP: {
      # Inside the 3.15 package set, disable tests globally
      buildPythonPackage = args:
        superP.buildPythonPackage (args // { doCheck = false; doInstallCheck = false; });
      buildPythonApplication = args:
        superP.buildPythonApplication (args // { doCheck = false; doInstallCheck = false; });

      # Force mypy to skip mypyc, it takes infinity time to build
      # and the goddamn types aren't even real anyway.
      mypy = superP.mypy.overridePythonAttrs (old: {
        env = { MYPY_USE_MYPYC = "0"; };
      });

      charset-normalizer = superP.charset-normalizer.overridePythonAttrs (old: {
        env = (old.env or {}) // {
          CHARSET_NORMALIZER_USE_MYPYC = "0";
        };
      });

      parso = superP.parso.overridePythonAttrs (old: {
        postPatch = ''
          cp parso/python/grammar314.txt parso/python/grammar315.txt
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

