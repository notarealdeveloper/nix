{ lib
, stdenv
, fetchFromGitHub
, buildPythonPackage
, setuptools
, wheel
, pip
}:

  let

    hello = import ../bin/hello.nix { inherit stdenv fetchFromGitHub; };

  in

  buildPythonPackage rec {
    pname = "jello";
    version = "0.0.3";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "notarealdeveloper";
      repo = "jello";
      rev = "0.0.3";
      sha256 = "sha256-O19WSAnCtISHOSd5P+b6j//fSoKiiXnNwLbuZ2m2tNs=";
    };

    build-system = [ setuptools wheel ];

    dependencies = [
      hello
    ];

    buildInputs = [
      pip
      setuptools
      hello
    ];

    propagatedBuildInputs = [
      hello
    ];

    #nativeBuildInputs = [ makeWrapper ];

    # Ensure that there are no undeclared deps
    postCheck = ''
      PATH= PYTHONPATH= $out/bin/hello
    '';

    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [ hello ])
    ];

    #postFixup = ''
    #  wrapProgram "$out/bin/jello" \
    #    --prefix PATH : "${hello}/bin" \
    #    --prefix PYTHONPATH : "$PYTHONPATH"
    #'';
  }
