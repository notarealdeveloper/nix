final: prev:

let
  lib   = final.lib;
  llvm  = final.llvmPackages;
  pyDrv = final.python315;
in
{
  python315Packages = prev.python315Packages.overrideScope (finalPy: prevPy: {
    tensorflow = finalPy.toPythonModule (final.buildBazelPackage {
      pname = "tensorflow";
      version = "git-f39ff4e";

      src = final.fetchFromGitHub {
        owner = "tensorflow";
        repo  = "tensorflow";
        rev   = "f39ff4efaac6c84ec5ae2698ecfdd2d4a099f0f1";
        hash  = "sha256-g+RnrMOkN6sWOtCh0tBULz40+VNVHFjgr45+Qq+nBH4=";
      };

      bazel = final.bazel_6;

      vendorHash = lib.fakeHash;
      fetchAttrs = {
        hash = lib.fakeHash;
        dontConfigure = true;
      };

      nativeBuildInputs = [
        llvm.clang
        finalPy.wheel
        finalPy.setuptools
        finalPy.pip
        final.which
        final.coreutils
        final.gnugrep
        final.gnused
        final.gawk
      ];

      buildInputs = [ final.zlib ];

      buildAttrs = {
        targets = [ "//tensorflow/tools/pip_package:wheel" ];
        buildFlags = [
          "--config=opt"
          "--repo_env=PYTHON_BIN_PATH=${pyDrv.interpreter}"
          "--repo_env=CC=${llvm.clang}/bin/clang"
        ];

        installPhase = ''
          mkdir -p "$out"
          WHEEL="$(find bazel-bin bazel-out -type f -name 'tensorflow-*.whl' -print -quit || true)"
          [ -n "$WHEEL" ] || { echo "wheel not found"; exit 1; }
          ${pyDrv.interpreter} -m pip install --no-deps --prefix "$out" "$WHEEL"
          mkdir -p "$out/nix-support"
          echo tensorflow > "$out/nix-support/python-imports"
        '';
      };

      pythonImportsCheck = [ "tensorflow" ];
    });
  });
}

