{ lib
, stdenv
, fetchFromGitHub
, buildBazelPackage
, buildPythonPackage
, python            # <-- pass your CPython HEAD / 3.15-alpha here
, bazel             # <-- pass a bazel that works with TF HEAD (e.g. bazel_7)
, which
, setuptools
, wheel
, packaging
, absl-py
, numpy
, protobuf          # python protobuf pkg name in nixpkgs is usually `protobuf`
, typing-extensions ? python.pkgs.typing-extensions
}:

assert stdenv.hostPlatform.system == "x86_64-linux";

let

  src = fetchFromGitHub {
    owner = "tensorflow";
    repo = "tensorflow";
    rev = "0cf856b84852256751dc8b21debacf847a97e432";
    hash = "sha256-NwClel4DO85NTQiJYC2bPDYifygJ/8F9iC0HS6pPE/0=";
  };

  # minimal py deps to let configure + wheel build run
  pyEnv = python.withPackages (ps: with ps; [
    setuptools wheel packaging absl-py numpy protobuf typing-extensions
  ]);

  tfSrc = buildBazelPackage {
    pname = "tensorflow-head-src";
    version = "unstable-${lib.substring 0 8 src.rev}";
    inherit src bazel;

    nativeBuildInputs = [ which pyEnv ];

    # keep bazel from refusing to run if versions drift
    TF_IGNORE_MAX_BAZEL_VERSION = true;

    # non-interactive ./configure (CPU-only, no extras)
    PYTHON_BIN_PATH           = pyEnv.interpreter;
    USE_DEFAULT_PYTHON_LIB_PATH = "1";
    TF_NEED_CUDA              = "0";
    TF_ENABLE_XLA             = "0";
    TF_NEED_GCP               = "0";
    TF_NEED_HDFS              = "0";
    TF_NEED_ROCM              = "0";
    TF_DOWNLOAD_CLANG         = "0";
    TF_SET_ANDROID_WORKSPACE  = "0";
    CC_OPT_FLAGS              = "-march=native";

    # Make the script pick up our answers
    configurePhase = ''
      runHook preConfigure
      ./configure
      runHook postConfigure
    '';

    hardeningDisable = [ "format" ];
    bazelBuildFlags  = [ "--config=opt" ];
    bazelTargets     = [ "//tensorflow/tools/pip_package:build_pip_package" ];

    # You will need to replace the fake hash after the first run
    fetchAttrs = { sha256 = lib.fakeSha256; };

    buildAttrs = {
      outputs = [ "out" "python" ];
      installPhase = ''
        mkdir -p "$out" "$python"
        bazel-bin/tensorflow/tools/pip_package/build_pip_package --src "$PWD/dist"
        cp -Lr dist "$python"
      '';
      requiredSystemFeatures = [ "big-parallel" ];
    };

    meta.platforms = [ "x86_64-linux" ];
  };
in

# Install the wheel produced above into a Python package output
buildPythonPackage {
  pname   = "tensorflow-head";
  version = tfSrc.version;

  # We're installing from a wheel dir we just created, so use a custom install
  format = "other";
  src    = tfSrc.python;

  # Minimal runtime propagation; start tiny and add back if needed
  propagatedBuildInputs = [ numpy absl-py protobuf typing-extensions packaging ];

  # Pip is available via the python builder; no extra deps needed.
  installPhase = ''
    runHook preInstall
    # install whatever wheel was produced into $out
    ${python.interpreter} -m pip install --no-index --find-links "$src/dist" --prefix "$out" tensorflow*
    runHook postInstall
  '';

  # Keep this strict; if import fails you’ll know early.
  pythonImportsCheck = [ "tensorflow" ];

  meta.platforms = [ "x86_64-linux" ];
}

