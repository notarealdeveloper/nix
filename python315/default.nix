# overlays/python315.nix
# overlay: self = final, prev = super
self: prev:

let
  src315 = prev.fetchFromGitHub {
    owner = "python";
    repo  = "cpython";
    rev   = "7fda8b66debb24e0520b94c3769b648c7305f84e";
    hash  = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
  };

  # Start from python314 wiring, but:
  # - rename to python3.15 (so logs show python3.15> …)
  # - point src/doc at src315
  # - force patches = [] (avoids missing no-ldconfig.patch)
  # - remove EXTERNALLY-MANAGED marker
  # - drop passthru.doc entirely to avoid building docs indirectly
  python315' = prev.python314.overrideAttrs (old: let
    oldPT = old.passthru or {};
  in {
    pname = "python3.15";
    version = "3.15.0a0";
    # Inform some helpers in the python infra:
    pythonVersion = "3.15";

    src = src315;

    # Make sure no 3.14/3.15 patch set is pulled in implicitly.
    patches = [];

    # Remove the EXTERNALLY-MANAGED marker whether it lands in 3.15 or computed dir.
    postInstall = (old.postInstall or "") + ''
      rm -f "$out/lib/python3.15/EXTERNALLY-MANAGED" 2>/dev/null || true
      rm -f "$out/lib/python3."*/EXTERNALLY-MANAGED 2>/dev/null || true
    '';
    postFixup = (old.postFixup or "") + ''
      rm -f "$out/lib/python3.15/EXTERNALLY-MANAGED" 2>/dev/null || true
      rm -f "$out/lib/python3."*/EXTERNALLY-MANAGED 2>/dev/null || true
    '';

    # Don’t expose a doc passthru to avoid accidental doc builds.
    passthru = builtins.removeAttrs oldPT [ "doc" ];
  });

  # Inside the python315 package set, disable tests globally for libs & apps.
  # NOTE: buildPythonPackage/buildPythonApplication are *functions*, so wrap them.
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

  # Optional free-threaded variant; keep if you actually use it.
  python315FreeThreading = python315.override {
    self = self.python315FreeThreading;
    pythonAttr = "python315FreeThreading";
    enableGIL = false;
  };
}

