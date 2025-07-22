pkgs: with pkgs; (pypkgs: with pypkgs;
  
  let

    # non-python dependency
    hello = (import ./hello.nix { inherit (pkgs) stdenv fetchFromGitHub; });

  in

  [buildPythonPackage rec {
    pname = "jello";
    version = "1.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "notarealdeveloper";
      repo = "jello";
      rev = "4d7b0eec71d3a2794df789cde6441e7397d3ff8f";
      sha256 = "sha256-bhwppgatuij1Mkl7YzD7jZnW/4gMGBs+/63g8c9MR9Q=";
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

    # Ensure that there are no undeclared deps
    postCheck = ''
      PATH= PYTHONPATH= $out/bin/hello
    '';

    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [
        hello
      ])
    ];
  }]
)
