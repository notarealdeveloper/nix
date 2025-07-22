{ stdenv, fetchFromGitHub, python313Packages }:

let
  hello = import ./hello.nix { inherit stdenv fetchFromGitHub; };

  jello = with python313Packages; buildPythonApplication rec {
    pname = "jello";
    version = "1.0";
    format = "pyproject";

    build-system = [ setuptools wheel ];

    src = fetchFromGitHub {
      owner = "notarealdeveloper";
      repo = "jello";
      rev = "0.0.2";
      sha256 = "4yUktoHDea6f6Z6MjG7xams1g+ticCV+ecfT9PeZV6A=";
    };

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

    # wrap CLI to find both python module & hello binary
    postFixup = ''
      for bin in "$out/bin/"*; do
        wrapProgram "$bin" \
          --prefix PATH ":" "${hello}/bin" \
          --prefix PYTHONPATH ":" "$(python313Packages.python.sitePackages)"
      done
    '';
  };
in

stdenv.mkDerivation {
  pname = "wello";
  version = "1.0";
  nativeBuildInputs = [];  # no build in this step
  dontBuild = true;        # no build phases

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${hello}/bin/hello $out/bin/hello
    ln -s ${jello}/bin/jello $out/bin/jello
  '';

  # runtime dependencies:
  buildInputs = [ hello jello ];
}
