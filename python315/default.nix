# overlay: self = final, prev = super
self: prev:

let
  # CPython 3.15 source you pinned
  src315 = prev.fetchFromGitHub {
    owner = "python";
    repo  = "cpython";
    rev   = "7fda8b66debb24e0520b94c3769b648c7305f84e";
    hash  = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
  };

  # cpython helper expected by the builder (note: passthrufun.nix)
  passthruFun = prev.callPackage
    (prev.path + "/pkgs/development/interpreters/python/passthrufun.nix")
    { };

  # Instantiate CPython for 3.15 (so the derivation name/labels are 3.15)
  python315-base = prev.callPackage
    (prev.path + "/pkgs/development/interpreters/python/cpython")
    {
      self = self.python315;  # standard threading used by nixpkgs
      sourceVersion = { major = "3"; minor = "15"; patch = "0"; suffix = "a0"; };
      # only used if a release tarball is auto-fetched
      hash = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
      inherit passthruFun;
    };

  # Finalize: set src, kill patches, remove EXTERNALLY-MANAGED, drop doc passthru
  python315' = python315-base.overrideAttrs (old: {
    pname = "python3.15";
    version = "3.15.0a0";
    # some infra also consults this var:
    pythonVersion = "3.15";

    src = src315;

    # nixpkgs 3.1x patchset doesn’t apply cleanly to this 3.15 commit
    patches = [];

    # >>> Skip the mime-types placeholder substitution and any other old postPatch bits
    postPatch = "";

    # Remove the EXTERNALLY-MANAGED marker in either minor-dir shape
    postInstall = (old.postInstall or "") + ''
      rm -f "$out/lib/python3.15/EXTERNALLY-MANAGED" 2>/dev/null || true
      rm -f "$out/lib/python3."*/EXTERNALLY-MANAGED 2>/dev/null || true
    '';
    postFixup = (old.postFixup or "") + ''
      rm -f "$out/lib/python3.15/EXTERNALLY-MANAGED" 2>/dev/null || true
      rm -f "$out/lib/python3."*/EXTERNALLY-MANAGED 2>/dev/null || true
    '';

    # Drop doc passthru so nothing drags Sphinx/docs
    passthru = builtins.removeAttrs (old.passthru or {}) [ "doc" ];
  });

  # Inside the 3.15 package set, disable tests globally (functions are wrapped)
  python315 = python315'.override {
    packageOverrides = selfP: superP: {
      buildPythonPackage = args:
        superP.buildPythonPackage (args // { doCheck = false; doInstallCheck = false; });
      buildPythonApplication = args:
        superP.buildPythonApplication (args // { doCheck = false; doInstallCheck = false; });

      # >>> Force mypy to skip mypyc (pure-Python build)
      mypy = superP.mypy.overridePythonAttrs (old: {
        env = (old.env or {}) // {
          MYPY_USE_MYPYC = "0";   # mypy’s build script honors this
        };
        # (Optional) also ensure nothing sneaks in from env
        preBuild = (old.preBuild or "") + ''
          export MYPY_USE_MYPYC=0
        '';
      });

    };
  };

in {
  python315 = python315;
  python315Packages = python315.pkgs;

  # Optional: free-threaded variant (only if you actually need it)
  python315FreeThreading = python315.override {
    self = self.python315FreeThreading;
    pythonAttr = "python315FreeThreading";
    enableGIL = false;
  };
}

