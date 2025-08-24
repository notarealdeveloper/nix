# overlays/tensorflow-test.nix
# Drop this file into your overlays list (e.g., in flake.nix or configuration.nix),
# then build:  nix build .#python315Packages.tensorflow --show-trace
final: prev:

let
  lib  = final.lib;
  llvm = final.llvmPackages;
  pyset = prev.python315Packages;                       # previous python package set
  interpreter = (pyset.interpreter or pyset.python);    # python executable (handles both shapes)
in
{
  python315Packages = prev.python315Packages.overrideScope (finalPy: prevPy: {
    # Replace the wheel-based tensorflow with a Bazel-from-source build
    tensorflow = finalPy.toPythonModule (final.buildBazelPackage {
      pname = "tensorflow";
      version = "git-f39ff4e";

      src = final.fetchFromGitHub {
        owner = "tensorflow";
        repo  = "tensorflow";
        rev   = "f39ff4efaac6c84ec5ae2698ecfdd2d4a099f0f1";
        hash  = "sha256-g+RnrMOkN6sWOtCh0tBULz40+VNVHFjgr45+Qq+nBH4=";
      };

      # Try bazel_6 first; if TF complains, switch to final.bazel_7.
      bazel = final.bazel_6;

      # First build will fail with a vendor hash mismatch; paste suggested hash here and rebuild.
      vendorHash = lib.fakeHash;

      # Some nixpkgs versions expect this attr; harmless if unused.
      fetchAttrs = { };

      nativeBuildInputs = [
        llvm.clang
        finalPy.wheel
        finalPy.setuptools
        finalPy.pip
      ];

      buildInputs = [
        final.zlib
        # Add jpeg/png/etc. here as the build requests them:
        # final.libjpeg_turbo final.libpng
      ];

      # Bazel-specific controls
      buildAttrs = {
        targets = [ "//tensorflow/tools/pip_package:wheel" ];
        buildFlags = [
          "--config=opt"
          "--repo_env=PYTHON_BIN_PATH=${interpreter}"
          "--repo_env=CC=${llvm.clang}/bin/clang"
          # Uncomment/tune if needed:
          # "--repo_env=TF_NEED_CUDA=0"
          # "--repo_env=TF_ENABLE_XLA=0"
          # "--subcommands"
        ];

        # Install the produced wheel into $out for this Python
        installPhase = ''
          mkdir -p "$out"
          WHEEL="$(find bazel-bin bazel-out -type f -name 'tensorflow-*.whl' -print -quit || true)"
          [ -n "$WHEEL" ] || { echo "wheel not found"; exit 1; }
          ${interpreter} -m pip install --no-deps --prefix "$out" "$WHEEL"

          # Hint for nixpkgs' python import check
          mkdir -p "$out/nix-support"
          echo tensorflow > "$out/nix-support/python-imports"
        '';
      };

      # Lightweight smoke test
      pythonImportsCheck = [ "tensorflow" ];
    });
  });
}

