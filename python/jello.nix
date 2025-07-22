pkgs: ps:

  let

    hello = import ../bin/hello.nix { inherit (pkgs) stdenv fetchFromGitHub; };

  in

  with pkgs;

  with ps;

  buildPythonPackage rec {
    pname = "jello";
    version = "1.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "notarealdeveloper";
      repo = "jello";
      rev = "0.0.2";
      sha256 = "sha256-4yUktoHDea6f6Z6MjG7xams1g+ticCV+ecfT9PeZV6A=";
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
