{ pkgs, python }:

with python.pkgs;
buildPythonPackage {
  pname = "tflite-runtime";
  version = "2.14.0";
  format = "wheel";

  src = pkgs.fetchurl {
    url = "https://files.pythonhosted.org/packages/8f/a6/02d68cb62cd221589a0ff055073251d883936237c9c990e34a1d7cecd06f/tflite_runtime-2.14.0-cp311-cp311-manylinux2014_x86_64.whl";
    sha256 = "195ab752e7e57329a68e54dd3dd5439fad888b9bff1be0f0dc042a3237a90e4d";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  buildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.python311  # only for libpython3.11.so.1.0
  ];

  dontWrapPythonPrograms = true;

  postFixup = ''
    echo "🔧 Patching RPATH to include Python 3.11 lib"
    for f in $out/${python.sitePackages}/tflite_runtime/*.so; do
      echo "patching $f"
      patchelf --set-rpath ${pkgs.python311}/lib:$(patchelf --print-rpath $f) $f
    done
  '';
}

