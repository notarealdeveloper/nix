pkgs: (

  let

    python = pkgs.python311;
    build = python.pkgs.buildPythonPackage;
    fetch = pkgs.fetchPypi;

  in python.withPackages (ps: with ps; [

    tflite-runtime

    (build {
      pname = "numpy";
      version = "1.26.4";
      pyproject = true;
      build-system = [ setuptools ];
      src = fetch {
        inherit pname version;
        sha256 = "sha256-+DQHyKzDJbkX8r8dDG+vDn2WcQ9RK9kIjjXksK0m/xM=";
      };
    })

    (build {
      pname = "pandas";
      version = "1.5.3";
      pyproject = true;
      build-system = [ setuptools ];
      src = fetch {
        inherit pname version;
        sha256 = "sha256-dKP9flp+wFLxgyc9x7Cs06hj7fdSD106F2XAT/2zsLE=";
      };
      propagatedBuildInputs = [ numpy cython ];
    })

    (build {
      pname = "scikit-learn";
      version = "1.4.0";
      pyproject = true;
      build-system = [ setuptools ];
      src = fetch {
        inherit pname version;
        sha256 = "sha256-dRxMRzYr+9qLbpxC7a2bTjG+9l2lJ5XLrT9XjmsFqFE=";
      };
      propagatedBuildInputs = [ numpy scipy ];
    })

    (build {
      pname = "lightgbm";
      version = "4.6.0";
      pyproject = true;
      build-system = [ setuptools ];
      src = fetch {
        inherit pname version;
        sha256 = "sha256-yxxZcg61aTicC6dNFPUjUbVzr0ifIwAyocnzFPi6t/4=";
      };
      nativeBuildInputs = with pkgs; [ cmake ninja pkg-config gcc ];
      propagatedBuildInputs = [ numpy ];
    })

    (build {
      pname = "lambda-multiprocessing";
      version = "0.5";
      pyproject = true;
      build-system = [ setuptools ];
      src = fetch {
        inherit pname version;
        sha256 = "sha256-WykGJZ3SYeToDSXPCYZxZoCMv25+ERw67L7FzskmCT4=";
      };
    })

  ])
)
