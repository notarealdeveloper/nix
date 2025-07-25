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

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.stdenv.cc.cc.lib ];

  # Optional: helpful for debugging
  postFixup = ''
    echo "🔧 Final RPATHs:"
    find $out -type f -exec file {} \; | grep ELF | awk '{print $1}' | sed 's/://g' | xargs -n1 patchelf --print-rpath || true
  '';

  propagatedBuildInputs = [
    pkgs.stdenv.cc.cc.lib
  ];

  #propagatedBuildInputs = [ ]; # not needed unless runtime Python deps

}
