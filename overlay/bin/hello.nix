{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "hello";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "doubleunix";
    repo = "hello";
    rev = "aea1e7c2100d5c1c3c3bcf910c00a247930135e6";
    sha256 = "sha256-618aXlt3g4X15/1SFJiXj6mGxwZ094aiNJCSvJjBxYs=";
  };
  buildInputs = [ stdenv.cc ];
  buildPhase = "make";
  installPhase = ''
    mkdir -pv $out/bin
    cp -v hello $out/bin/
  '';
}
