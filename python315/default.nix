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

  # Start from python314 (so all wiring exists), then switch its source/version-ish.
  # Also force patches=[] to dodge the missing no-ldconfig.patch for 3.15.
  python315' = prev.python314.overrideAttrs (old: let
    oldPT = old.passthru or {};
    newDoc =
      if oldPT ? doc then oldPT.doc.overrideAttrs (_: { src = src315; }) else null;
  in {
    src = src315;
    passthru = oldPT // (if oldPT ? doc then { doc = newDoc; } else {});

    # Prevent cpython/default.nix from auto-selecting 3.15 patch set
    patches = [];

    # remove the EXTERNALLY-MANAGED marker regardless of minor dir details
    postInstall = (old.postInstall or "") + ''
      rm -f "$out/lib/python3.15/EXTERNALLY-MANAGED" 2>/dev/null || true
      rm -f "$out/lib/python3."*/EXTERNALLY-MANAGED 2>/dev/null || true
    '';
    postFixup = (old.postFixup or "") + ''
      rm -f "$out/lib/python3.15/EXTERNALLY-MANAGED" 2>/dev/null || true
      rm -f "$out/lib/python3."*/EXTERNALLY-MANAGED 2>/dev/null || true
    '';

    # (optional cosmetics; not required)
    version = "3.15.0a0";
    pythonVersion = "3.15";
  });

  # Disable tests for everything built under python315’s package set:
  # Wrap the builder *functions* (no .override needed).
  python315 = python315'.override {
    packageOverrides = selfP: superP: {
      buildPythonPackage = args:
        superP.buildPythonPackage (args // { doCheck = false; doInstallCheck = false; });
      buildPythonApplication = args:
        superP.buildPythonApplication (args // { doCheck = false; doInstallCheck = false; });
    };
  };

in {
  python315 = python315;
  python315Packages = python315.pkgs;

  # Optional: free-threaded variant, if you actually need it
  python315FreeThreading = python315.override {
    self = self.python315FreeThreading;
    pythonAttr = "python315FreeThreading";
    enableGIL = false;
  };
}

