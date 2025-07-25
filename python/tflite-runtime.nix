{ pkgs
, lib
, buildPythonPackage
, fetchPypi
, pip
, setuptools
, wheel
, python
, ...
} @ inputs:

buildPythonPackage rec {
  pname = "tflite-runtime";
  version = "2.14.0";
  format = "wheel";

  # fetch source
  src = builtins.fetchurl {
    #inherit pname version;
    url = "https://files.pythonhosted.org/packages/8f/a6/02d68cb62cd221589a0ff055073251d883936237c9c990e34a1d7cecd06f/tflite_runtime-2.14.0-cp311-cp311-manylinux2014_x86_64.whl";
    sha256 = "195ab752e7e57329a68e54dd3dd5439fad888b9bff1be0f0dc042a3237a90e4d";
  };

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.gcc                # for compiling the preload stub
    pkgs.makeWrapper        # for wrapPythonPrograms if needed
  ];

  buildInputs = [
    pkgs.stdenv.cc.cc.lib   # provides libstdc++.so.6
  ];

  dontWrapPythonPrograms = true;

  # Inject a stub for _PyThreadState_UncheckedGet
  postFixup = ''
    echo 'void *_PyThreadState_UncheckedGet(void) { return 0; }' > stub.c
    gcc -shared -fPIC -o $out/lib/fakepy.so stub.c

    # wrap the Python module's loader with LD_PRELOAD
    for f in $out/${python.sitePackages}/tflite_runtime/*.so; do
      echo "Wrapping $f with LD_PRELOAD"
      mv "$f" "$f.orig"
      makeWrapper "$f.orig" "$f" \
        --set LD_PRELOAD "$out/lib/fakepy.so"
    done
  '';

}
