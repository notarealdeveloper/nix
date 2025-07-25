# python/tflite-runtime.nix
{ pkgs, python }:

let
  evilStub = pkgs.stdenv.mkDerivation {
    pname = "evil-py-unchecked-stub";
    version = "1.0";

    src = pkgs.writeText "evil_stub.c" ''
      #include <Python.h>
      __attribute__((visibility("default")))
      PyThreadState* _PyThreadState_UncheckedGet(void) {
          return PyThreadState_Get();
      }
    '';

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ ];

    buildPhase = ''
      gcc -shared -fPIC $src -o libevil.so \
        -I $(python -c "import sysconfig; print(sysconfig.get_path('include'))") \
        -Wl,--unresolved-symbols=ignore-in-object-files
    '';

    installPhase = ''
      mkdir -p $out/lib
      mv libevil.so $out/lib/
    '';
  };

in pkgs.buildPythonPackage {
  pname = "tflite-runtime";
  version = "2.14.0";
  format = "wheel";

  src = pkgs.fetchurl {
    url = "https://files.pythonhosted.org/packages/8f/a6/02d68cb62cd221589a0ff055073251d883936237c9c990e34a1d7cecd06f/tflite_runtime-2.14.0-cp311-cp311-manylinux2014_x86_64.whl";
    sha256 = "195ab752e7e57329a68e54dd3dd5439fad888b9bff1be0f0dc042a3237a90e4d";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  buildInputs = [ pkgs.stdenv.cc.cc.lib pkgs.python311 ]; # get libstdc++ and libpython3.11.so

  dontWrapPythonPrograms = true;

  postFixup = ''
    echo "🔧 Patching RPATH to include Python 3.11 lib and evil stub"
    for f in $out/${python.sitePackages}/tflite_runtime/*.so; do
      echo "patching $f"
      patchelf \
        --set-rpath ${pkgs.python311}/lib:${evilStub}/lib:$(patchelf --print-rpath $f) \
        $f
    done
  '';
}

